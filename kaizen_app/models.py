from django.db import models
from django.contrib.auth.models import User
from datetime import datetime
from django.utils import timezone


class Image(models.Model):
    image = models.ImageField(upload_to="kaizen_images/")
    description = models.TextField(blank=True)


class KaizenSheet(models.Model):
    title = models.CharField(max_length=255, unique=True)
    
    AREA_GROUPING_CHOICES = [
        ('ASSEMBLY MECH', 'ASSEMBLY MECH'),
        ('CSG, QA, METHODS, MAINTENACE & STORES', 'CSG, QA, METHODS, MAINTENACE & STORES'),
        ('ELECTRICAL', 'ELECTRICAL'),
        ('M/C SHOP, PAINTSHOP & DISPATCH', 'M/C SHOP, PAINTSHOP & DISPATCH'),
        ('OFFICE', 'OFFICE'),
        ('SCM', 'SCM'),
        ('TECH SUPPORT GROUP', 'TECH SUPPORT GROUP'),
    ]

    # Add new field
    area_grouping = models.CharField(
        max_length=100,
        choices=AREA_GROUPING_CHOICES,
        null=True,
        blank=True
    )
    area_implemented = models.CharField(max_length=100, null=True, blank=True)
    area_grouping = models.CharField(max_length=100, choices=AREA_GROUPING_CHOICES, null=True, blank=True)
    start_date = models.DateField()
    end_date = models.DateField()
    problem = models.TextField()
    idea_solved = models.TextField()
    standardization = models.TextField()
    deployment = models.TextField()
    is_temporary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    project_leader = models.CharField(
        max_length=255, blank=True, null=True
    )  # Make nullable
    team_member1_id = models.CharField(max_length=50, blank=True, null=True)
    team_member1 = models.CharField(max_length=255, blank=True, null=True)
    team_member2_id = models.CharField(max_length=50, blank=True, null=True)
    team_member2 = models.CharField(max_length=255, blank=True, null=True)

    savings_start_month = models.CharField(
        max_length=20, blank=True, null=True
    )  # Changed from DateField
    estimated_savings = models.DecimalField(
        max_digits=12, decimal_places=2, default=0
    )
    realized_savings = models.DecimalField(
        max_digits=12, decimal_places=2, default=0
    )
    handwritten_sheet = models.ImageField(
        upload_to="kaizen/handwritten/",
        blank=True,
        null=True,
        verbose_name="Handwritten Kaizen Sheet",
    )
    is_handwritten = models.BooleanField(default=False)

    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("hod_approved", "HOD Approved"),
        ("finance_pending", "Finance Review Pending"),
        ("finance_approved", "Finance Approved"),
        ("finance_rejected", "Finance Rejected"),
        ("coordinator_approved", "Fully Approved"),
    ]

    approval_status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="pending"
    )
    hod_approved = models.BooleanField(default=False)
    coordinator_approved = models.BooleanField(default=False)
    hod_approved_at = models.DateTimeField(null=True, blank=True)
    coordinator_approved_at = models.DateTimeField(null=True, blank=True)
    hod_approved_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="hod_approved_sheets",
    )
    coordinator_approved_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="coordinator_approved_sheets",
    )

    finance_approved = models.BooleanField(default=False)
    finance_approved_at = models.DateTimeField(null=True, blank=True)
    finance_approved_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="finance_approved_sheets",
    )

    submission_department = models.CharField(max_length=100)

    def save(self, *args, **kwargs):
        if not self.pk:  # Only on creation
            self.submission_department = self.employee.profile.department
        super().save(*args, **kwargs)

    @property
    def is_editable(self):
        return self.approval_status == "pending"

    @property
    def get_approval_status_display(self):
        if self.approval_status == "coordinator_approved":
            return "Approved"
        elif self.approval_status == "hod_approved":
            return "Coordinator Approval Pending"
        elif self.approval_status == "pending":
            return "No Approval"
        return "Rejected"

    def needs_finance_approval(self):
        try:
            cost_before = float(self.cost_before_implementation or 0)
            cost_after = float(self.cost_after_implementation or 0)
            return abs(cost_before - cost_after) > 100000
        except ValueError:
            return False

    def approve_by_hod(self, hod_user):
        self.hod_approved = True
        self.hod_approved_by = hod_user
        self.hod_approved_at = timezone.now()

        # Update status based on handwritten or cost
        if self.is_handwritten or (
            45000 < self.get_cost_difference() <= 100000
        ):
            self.approval_status = "coordinator_pending"
        else:
            self.approval_status = "completed"

        self.save()

    def approve_by_finance(self, finance_user):
        if self.approval_status == "finance_pending":
            self.finance_approved = True
            self.finance_approved_by = finance_user
            self.finance_approved_at = datetime.now()
            self.approval_status = "finance_approved"  # Set to finance_approved
            self.save()

    def reject_by_finance(self, finance_user):
        if self.approval_status == "finance_pending":
            self.finance_approved = False
            self.finance_approved_by = finance_user
            self.finance_approved_at = datetime.now()
            self.approval_status = "finance_rejected"  # Set to finance_rejected
            self.save()

    def approve_by_coordinator(self, coordinator_user):
        # Check if sheet needs finance approval
        if self.needs_finance_approval():
            if self.approval_status == "hod_approved":
                self.approval_status = "finance_pending"
                self.save()
                return
            elif self.approval_status != "finance_approved":
                return

        # If no finance approval needed or already finance approved
        self.coordinator_approved = True
        self.coordinator_approved_by = coordinator_user
        self.coordinator_approved_at = datetime.now()
        self.approval_status = "coordinator_approved"
        self.save()

    def get_cost_impact(self):
        """
        Returns cost impact details including:
        - If it's a saving or increase
        - Absolute difference for approval routing
        - Display message
        """
        try:
            before = float(self.cost_before_implementation or 0)
            after = float(self.cost_after_implementation or 0)
            difference = before - after
            abs_difference = abs(difference)

            return {
                'is_saving': difference > 0,
                'difference': abs_difference,
                'heading': 'Cost Savings' if difference > 0 else 'Cost Increase',
                'message': f"₹{difference:,.2f} Saved" if difference > 0 else f"₹{abs_difference:,.2f} Increased Cost",
                'before': before,
                'after': after
            }
        except (ValueError, TypeError):
            return {
                'is_saving': False,
                'difference': 0,
                'heading': 'Invalid Cost Data',
                'message': 'Unable to calculate cost impact',
                'before': 0,
                'after': 0
            }

    def needs_finance_approval(self):
        return self.get_cost_impact()['difference'] > 100000

    def needs_coordinator_approval(self):
        if self.is_handwritten:
            return True
        diff = self.get_cost_impact()['difference']
        return 45000 < diff <= 100000

    def needs_only_hod_approval(self):
        if self.is_handwritten:
            return False
        diff = self.get_cost_impact()['difference']
        return 0 < diff <= 45000

    # For backwards compatibility
    def get_cost_difference(self):
        return self.get_cost_impact()['difference']

    def get_approval_status_display(self):
        try:
            # Add handwritten sheet logic
            if self.is_handwritten:
                if not self.hod_approved:
                    return "HOD Approval Pending"
                return (
                    "Completed"
                    if self.coordinator_approved
                    else "Coordinator Approval Pending"
                )

            cost_diff = self.get_cost_difference()

            if cost_diff == 0 and not self.is_handwritten:
                return "No approval needed"

            if cost_diff <= 45000 and not self.is_handwritten:
                return (
                    "Completed" if self.hod_approved else "HOD Approval Pending"
                )

            if cost_diff <= 100000 or self.is_handwritten:
                if not self.hod_approved:
                    return "HOD Approval Pending"
                return (
                    "Completed"
                    if self.coordinator_approved
                    else "Coordinator Approval Pending"
                )

            # Above 100k
            if not self.hod_approved:
                return "HOD Approval Pending"
            if not self.finance_approved:
                return "Finance Approval Pending"
            if not self.coordinator_approved:
                return "Coordinator Approval Pending"
            return "Completed"

        except (ValueError, TypeError):
            return "Invalid Cost Values"

    def get_available_departments(self):
        return (
            Profile.objects.filter(user_type="hod")
            .exclude(department=self.employee.profile.department)
            .values_list("department", flat=True)
        )

    # Serial Key - unique and auto-generated
    serial_key = models.CharField(max_length=15, unique=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.serial_key:
            self.serial_key = self.generate_serial_key()
        super().save(*args, **kwargs)

    def generate_serial_key(self):
        current_year = datetime.now().year
        year_suffix = str(current_year)[-2:]
        latest_kaizen = KaizenSheet.objects.all().order_by("id").last()

        if latest_kaizen and latest_kaizen.serial_key:
            try:
                last_number = int(latest_kaizen.serial_key.split("-")[-1])
            except ValueError:
                last_number = 0
            new_number = f"{last_number + 1:04d}"
        else:
            new_number = "0001"

        serial_key = f"KAI-{year_suffix}-{new_number}"
        return serial_key

    before_improvement_image = models.ImageField(
        upload_to="kaizen/before/", blank=True, null=True
    )
    after_improvement_image = models.ImageField(
        upload_to="kaizen/after/", blank=True, null=True
    )

    impacts_safety = models.BooleanField(default=False)
    impacts_quality = models.BooleanField(default=False)
    impacts_productivity = models.BooleanField(default=False)
    impacts_delivery = models.BooleanField(default=False)
    impacts_cost = models.BooleanField(default=False)
    impacts_morale = models.BooleanField(default=False)
    impacts_environment = models.BooleanField(default=False)

    safety_benefits_description = models.TextField(blank=True, null=True)
    safety_uom = models.CharField(max_length=255, blank=True, null=True)
    safety_before_implementation = models.TextField(blank=True, null=True)
    safety_after_implementation = models.TextField(blank=True, null=True)

    quality_benefits_description = models.TextField(blank=True, null=True)
    quality_uom = models.CharField(max_length=255, blank=True, null=True)
    quality_before_implementation = models.TextField(blank=True, null=True)
    quality_after_implementation = models.TextField(blank=True, null=True)

    productivity_benefits_description = models.TextField(blank=True, null=True)
    productivity_uom = models.CharField(max_length=255, blank=True, null=True)
    productivity_before_implementation = models.TextField(blank=True, null=True)
    productivity_after_implementation = models.TextField(blank=True, null=True)

    delivery_benefits_description = models.TextField(blank=True, null=True)
    delivery_uom = models.CharField(max_length=255, blank=True, null=True)
    delivery_before_implementation = models.TextField(blank=True, null=True)
    delivery_after_implementation = models.TextField(blank=True, null=True)

    cost_benefits_description = models.TextField(blank=True, null=True)
    cost_uom = models.CharField(max_length=255, blank=True, null=True)
    cost_before_implementation = models.TextField(blank=True, null=True)
    cost_after_implementation = models.TextField(blank=True, null=True)

    morale_benefits_description = models.TextField(blank=True, null=True)
    morale_uom = models.CharField(max_length=255, blank=True, null=True)
    morale_before_implementation = models.TextField(blank=True, null=True)
    morale_after_implementation = models.TextField(blank=True, null=True)

    environment_benefits_description = models.TextField(blank=True, null=True)
    environment_uom = models.CharField(max_length=255, blank=True, null=True)
    environment_before_implementation = models.TextField(blank=True, null=True)
    environment_after_implementation = models.TextField(blank=True, null=True)

    before_improvement_text = models.TextField(blank=True, null=True)
    after_improvement_text = models.TextField(blank=True, null=True)

    cost_calculation = models.FileField(
        upload_to="kaizen/cost_calculations/",
        blank=True,
        null=True,
        verbose_name="Cost Calculation File",
    )

    standardization_file = models.FileField(
        upload_to="kaizen/standardization/", blank=True, null=True
    )
    employee = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="kaizen_sheets_created"
    )
    implemented_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        related_name="kaizen_sheets_implemented",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    employee_active = models.BooleanField(default=True)
    employee_info = models.JSONField(null=True, blank=True)

    class Meta:
        ordering = ["-start_date"]

    def __str__(self):
        return f"Kaizen Sheet: {self.title} by {self.employee.username}"


# models.py
class Profile(models.Model):
    DEPARTMENT_CHOICES = [
        ("ASSLY MECH- VMC GROUP - RAPC", "ASSLY MECH- VMC GROUP - RAPC"),
        ("ASSLY MECH- BB -SA- HS & IT", "ASSLY MECH- BB -SA- HS & IT"),
        ("ASSLY MECH- HMC GROUP", "ASSLY MECH- HMC GROUP"),
        ("ASSLY MECH- L VMC GROUP", "ASSLY MECH- L VMC GROUP"),
        ("ASSLY MECH- LINE ASSLY 1 & 2", "ASSLY MECH- LINE ASSLY 1 & 2"),
        ("ASSLY MECH- LINE ASSLY 3 & 4", "ASSLY MECH- LINE ASSLY 3 & 4"),
        ("ASSLY MECH- VMC GROUP - 2", "ASSLY MECH- VMC GROUP - 2"),
        ("ASSLY MECH- VMC GROUP - 1", "ASSLY MECH- VMC GROUP - 1"),
        ("ASSLY MECH- VMC GROUP - LAPC", "ASSLY MECH- VMC GROUP - LAPC"),
        ("BASE BUILD- SA- SPINDLE", "BASE BUILD- SA- SPINDLE"),
        ("CSG", "CSG"),
        ("EEP", "EEP"), 
        ("ELCT- DESIGN", "ELCT- DESIGN"),
        ("ELCT- FINAL ASSLY (HMC)", "ELCT- FINAL ASSLY (HMC)"),
        ("ELCT- FINAL ASSLY (LVMC)", "ELCT- FINAL ASSLY (LVMC)"),
        ("ELCT- FINAL ASSLY (EXPORT)", "ELCT- FINAL ASSLY (EXPORT)"),
        ("ELCT- FINAL ASSLY (SKI)", "ELCT- FINAL ASSLY (SKI)"),
        ("ELCT- LINE ASSLY (SKI)", "ELCT- LINE ASSLY (SKI)"),
        ("ELCT- METHODS", "ELCT- METHODS"),
        ("ELCT- PLANNING", "ELCT- PLANNING"),
        ("ELCT- PROCUREMENT", "ELCT- PROCUREMENT"), 
        ("ELCT- SUB ASSLY (SKI)", "ELCT- SUB ASSLY (SKI)"),
        ("EXPORT ASSEMBLY", "EXPORT ASSEMBLY"),
        ("FINAL ASSLY- SA", "FINAL ASSLY- SA"),
        ("FINANCE & ACCOUNTS", "FINANCE & ACCOUNTS"),
        ("FIXTURE DESIGN", "FIXTURE DESIGN"),
        ("HRD", "HRD"),
        ("ISG", "ISG"),
        ("MACHINE SHOP", "MACHINE SHOP"),
        ("MAINTENANCE", "MAINTENANCE"),
        ("METHODS ENGG", "METHODS ENGG"),
        ("PAINT SHOP & PACKING- DISPATCH", "PAINT SHOP & PACKING- DISPATCH"),
        ("PROD PLANNING & CONTROL", "PROD PLANNING & CONTROL"),
        ("PRODUCT DESIGN- HMC GROUP", "PRODUCT DESIGN- HMC GROUP"),
        ("PRODUCT DESIGN- VMC GROUP", "PRODUCT DESIGN- VMC GROUP"),
        ("PROJECTS", "PROJECTS"),
        ("QUALITY- CIP, CMM & CALIBRATION", "QUALITY- CIP, CMM & CALIBRATION"),
        ("QUALITY- FNL INSPTN, LASER & BALL BAR", "QUALITY- FNL INSPTN, LASER & BALL BAR"),
        ("QUALITY- INWARD INSPECTION", "QUALITY- INWARD INSPECTION"),
        ("R & D", "R & D"),
        ("SCM- A CLASS", "SCM- A CLASS"),
        ("SCM- B & C CLASS", "SCM- B & C CLASS"),
        ("SCM- BROUGHTOUT", "SCM- BROUGHTOUT"),
        ("SCM- COSTING & INVENTORY CONTROL", "SCM- COSTING & INVENTORY CONTROL"),
        ("SCM- HMC EXCLUSIVE", "SCM- HMC EXCLUSIVE"),
        ("SCM- PE (CASTING/ FOUNDRY)", "SCM- PE (CASTING/ FOUNDRY)"),
        ("SCM- PROCESS ENGG", "SCM- PROCESS ENGG"),
        ("SCM- SHEET METAL", "SCM- SHEET METAL"),
        ("SCM- FIXTURES", "SCM- FIXTURES"),
        ("STORES", "STORES"),
        ("SUB ASSEMBLY- FIXTURE", "SUB ASSEMBLY- FIXTURE"),
        ("TRYOUTS", "TRYOUTS"),
        ("TSG- APPLICATION ENGINEERING", "TSG- APPLICATION ENGINEERING"),
        ("TSG- AUTOMATION", "TSG- AUTOMATION"),
        ("TSG- DIE & MOULD", "TSG- DIE & MOULD"),
        ("TSG- EXPORT", "TSG- EXPORT"),
        ("TSG- MARKETING & BRANDING", "TSG- MARKETING & BRANDING"),
        ("TSG- SALES & EXECUTION", "TSG- SALES & EXECUTION"),
        ("SUB_ASSLY - RAPC,LAPC, SLIDE ASSEMBLY", "SUB_ASSLY - RAPC,LAPC, SLIDE ASSEMBLY"),
    ]

    last_department_change = models.DateTimeField(default=timezone.now)
    last_password_change = models.DateTimeField(null=True, blank=True)

    def save(self, *args, **kwargs):
        if self.pk:  # If this is an update
            old_profile = Profile.objects.get(pk=self.pk)
            if old_profile.department != self.department:
                self.last_department_change = timezone.now()
        super().save(*args, **kwargs)

    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,
        related_name='profiles'
    )
    
    USER_TYPES = (
        ("employee", "Employee"),
        ("coordinator", "Coordinator"),
        ("hod", "Hod"),
        ("hod_coordinator", "HOD Coordinator"),
        ("finance", "Finance and Accounts"),
        ("admin", "Admin"),
    )
    
    user_type = models.CharField(
        max_length=20, 
        choices=USER_TYPES,
        default="employee"
    )
    
    department = models.CharField(
        max_length=100, 
        choices=DEPARTMENT_CHOICES, 
        blank=True, 
        null=True
    )
    
    employee_id = models.CharField(
        max_length=50,
        null=True,
        blank=True,
        help_text="Employee identification number"
    )

    def clean(self):
        """Add validation to ensure department is set for HOD Coordinator"""
        if self.user_type == 'hod_coordinator' and not self.department:
            raise models.ValidationError({
                'department': 'Department is required for HOD Coordinator'
            })

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    class Meta:
        constraints = [
            # Allow same employee_id for different roles
            models.UniqueConstraint(
                fields=['employee_id', 'user_type'],
                name='unique_employee_id_per_role'
            ),
            # One HOD per department
            models.UniqueConstraint(
                fields=['department', 'user_type'],
                condition=models.Q(user_type='hod'),
                name='unique_hod_per_department'
            ),
            # Max 3 different roles per user (removes unique_user_type_per_user)
            models.UniqueConstraint(
                fields=['user', 'user_type'],
                name='unique_role_per_user'
            ),

            models.UniqueConstraint(
                fields=['department', 'user_type'],
                condition=models.Q(user_type='hod_coordinator'),
                name='unique_hod_coordinator_per_department'
            )
        ]

    @classmethod
    def can_register_role(cls, user, user_type, department=None):
        """Enhanced role registration validation"""
        # Check max roles per user (3)
        user_roles = cls.objects.filter(user=user).count()
        if user_roles >= 3:
            return False

        # Check role-specific limits
        if user_type == 'finance':
            return cls.objects.filter(user_type='finance').count() < 1
        elif user_type == 'coordinator':
            return cls.objects.filter(user_type='coordinator').count() < 2
        elif user_type == 'hod' and department:
            return not cls.objects.filter(
                user_type='hod',
                department=department
            ).exists()
        elif user_type == 'hod_coordinator' and department:
            # Check if HOD Coordinator already exists for this department
            exists = cls.objects.filter(
                user_type='hod_coordinator',
                department=department
            ).exists()
            return not exists
        
        return True

    @property
    def is_coordinator(self):
        return self.user_type == "coordinator"

    @property
    def is_employee(self):
        return self.user_type == "employee"

    @property
    def is_hod(self):
        return self.user_type == "hod"

    @property
    def is_finance(self):
        return self.user_type == "finance"
    
    @property
    def is_admin(self):
        return self.user_type == "admin"
    
    @property
    def is_hod_coordinator(self):
        return self.user_type == "hod_coordinator"


    @classmethod
    def get_active_profile(cls, user):
        """Get the active profile based on session"""
        if not hasattr(user, '_cached_active_profile'):
            profile_type = user.request.session.get('active_profile_type')
            if profile_type:
                user._cached_active_profile = user.profiles.filter(
                    user_type=profile_type
                ).first()
            else:
                user._cached_active_profile = user.profiles.first()
        return user._cached_active_profile

    def __str__(self):
        return f"{self.user.username}'s {self.user_type} profile"

        

# models.py
class HorizontalDeployment(models.Model):
    kaizen_sheet = models.ForeignKey(
        KaizenSheet, on_delete=models.CASCADE, related_name="deployments"
    )
    department = models.CharField(max_length=100)
    deployed_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("kaizen_sheet", "department")

    def __str__(self):
        return f"{self.kaizen_sheet.title} - {self.department}"


class KaizenCoordinator(models.Model):
    department = models.CharField(max_length=100, unique=True)
    coordinator_name = models.CharField(max_length=150, blank=True, null=True)

    def __str__(self):
        return (
            f"{self.department} - {self.coordinator_name or 'No Coordinator'}"
        )

class PasswordResetRequest(models.Model):
    employee_id = models.CharField(max_length=50)
    email = models.EmailField()
    department = models.CharField(max_length=100, choices=Profile.DEPARTMENT_CHOICES)
    request_date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('approved', 'Approved'),
            ('rejected', 'Rejected')
        ],
        default='pending'
    )
    resolved_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='resolved_password_requests'
    )
    resolved_date = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-request_date']