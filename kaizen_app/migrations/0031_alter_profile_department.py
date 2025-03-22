# Generated by Django 5.1.2 on 2025-02-06 08:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0030_update_department_choices'),
    ]

    operations = [
        migrations.AlterField(
            model_name='profile',
            name='department',
            field=models.CharField(blank=True, choices=[('ASSLY MECH- VMC GROUP - RAPC', 'ASSLY MECH- VMC GROUP - RAPC'), ('ASSLY MECH- BB -SA- HS & IT', 'ASSLY MECH- BB -SA- HS & IT'), ('ASSLY MECH- HMC GROUP', 'ASSLY MECH- HMC GROUP'), ('ASSLY MECH- L VMC GROUP', 'ASSLY MECH- L VMC GROUP'), ('ASSLY MECH- LINE ASSLY 1 & 2', 'ASSLY MECH- LINE ASSLY 1 & 2'), ('ASSLY MECH- LINE ASSLY 3 & 4', 'ASSLY MECH- LINE ASSLY 3 & 4'), ('ASSLY MECH- VMC GROUP - 2', 'ASSLY MECH- VMC GROUP - 2'), ('ASSLY MECH- VMC GROUP - 1', 'ASSLY MECH- VMC GROUP - 1'), ('ASSLY MECH- VMC GROUP - LAPC', 'ASSLY MECH- VMC GROUP - LAPC'), ('BASE BUILD- SA- SPINDLE', 'BASE BUILD- SA- SPINDLE'), ('CSG', 'CSG'), ('EEP', 'EEP'), ('ELCT- DESIGN', 'ELCT- DESIGN'), ('ELCT- FINAL ASSLY (HMC)', 'ELCT- FINAL ASSLY (HMC)'), ('ELCT- FINAL ASSLY (LVMC)', 'ELCT- FINAL ASSLY (LVMC)'), ('ELCT- FINAL ASSLY (EXPORT)', 'ELCT- FINAL ASSLY (EXPORT)'), ('ELCT- FINAL ASSLY (SKI)', 'ELCT- FINAL ASSLY (SKI)'), ('ELCT- LINE ASSLY (SKI)', 'ELCT- LINE ASSLY (SKI)'), ('ELCT- METHODS', 'ELCT- METHODS'), ('ELCT- PLANNING', 'ELCT- PLANNING'), ('ELCT- PROCUREMENT', 'ELCT- PROCUREMENT'), ('ELCT- SUB ASSLY (SKI)', 'ELCT- SUB ASSLY (SKI)'), ('EXPORT ASSEMBLY', 'EXPORT ASSEMBLY'), ('FINAL ASSLY- SA', 'FINAL ASSLY- SA'), ('FINANCE & ACCOUNTS', 'FINANCE & ACCOUNTS'), ('FIXTURE DESIGN', 'FIXTURE DESIGN'), ('HRD', 'HRD'), ('ISG', 'ISG'), ('MACHINE SHOP', 'MACHINE SHOP'), ('MAINTENANCE', 'MAINTENANCE'), ('METHODS ENGG', 'METHODS ENGG'), ('PAINT SHOP & PACKING- DISPATCH', 'PAINT SHOP & PACKING- DISPATCH'), ('PROD PLANNING & CONTROL', 'PROD PLANNING & CONTROL'), ('PRODUCT DESIGN- HMC GROUP', 'PRODUCT DESIGN- HMC GROUP'), ('PRODUCT DESIGN- VMC GROUP', 'PRODUCT DESIGN- VMC GROUP'), ('PROJECTS', 'PROJECTS'), ('QUALITY- CIP, CMM & CALIBRATION', 'QUALITY- CIP, CMM & CALIBRATION'), ('QUALITY- FNL INSPTN, LASER & BALL BAR', 'QUALITY- FNL INSPTN, LASER & BALL BAR'), ('QUALITY- INWARD INSPECTION', 'QUALITY- INWARD INSPECTION'), ('R & D', 'R & D'), ('SCM- A CLASS', 'SCM- A CLASS'), ('SCM- B & C CLASS', 'SCM- B & C CLASS'), ('SCM- BROUGHTOUT', 'SCM- BROUGHTOUT'), ('SCM- COSTING & INVENTORY CONTROL', 'SCM- COSTING & INVENTORY CONTROL'), ('SCM- HMC EXCLUSIVE', 'SCM- HMC EXCLUSIVE'), ('SCM- PE (CASTING/ FOUNDRY)', 'SCM- PE (CASTING/ FOUNDRY)'), ('SCM- PROCESS ENGG', 'SCM- PROCESS ENGG'), ('SCM- SHEET METAL', 'SCM- SHEET METAL'), ('SCM- FIXTURES', 'SCM- FIXTURES'), ('STORES', 'STORES'), ('SUB ASSEMBLY- FIXTURE', 'SUB ASSEMBLY- FIXTURE'), ('TRYOUTS', 'TRYOUTS'), ('TSG- APPLICATION ENGINEERING', 'TSG- APPLICATION ENGINEERING'), ('TSG- AUTOMATION', 'TSG- AUTOMATION'), ('TSG- DIE & MOULD', 'TSG- DIE & MOULD'), ('TSG- EXPORT', 'TSG- EXPORT'), ('TSG- MARKETING & BRANDING', 'TSG- MARKETING & BRANDING'), ('TSG- SALES & EXECUTION', 'TSG- SALES & EXECUTION'), ('SUB_ASSLY - RAPC,LAPC, SLIDE ASSEMBLY', 'SUB_ASSLY - RAPC,LAPC, SLIDE ASSEMBLY')], max_length=100, null=True),
        ),
    ]
