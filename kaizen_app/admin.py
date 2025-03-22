from django.contrib import admin
from .models import PasswordResetRequest

@admin.register(PasswordResetRequest)
class PasswordResetRequestAdmin(admin.ModelAdmin):
    list_display = ('employee_id', 'email', 'department', 'request_date', 'status', 'resolved_by')
    list_filter = ('status', 'department')
    search_fields = ('employee_id', 'email')
    readonly_fields = ('request_date',)
