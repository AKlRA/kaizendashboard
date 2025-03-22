# 0005_rename_admin_to_hod.py
from django.db import migrations

def rename_admin_to_hod(apps, schema_editor):
    Profile = apps.get_model('kaizen_app', 'Profile')
    Profile.objects.filter(user_type='admin').update(user_type='hod')

def rename_hod_to_admin(apps, schema_editor):
    Profile = apps.get_model('kaizen_app', 'Profile')
    Profile.objects.filter(user_type='hod').update(user_type='admin')

class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0004_remove_profile_is_coordinator_profile_user_type_and_more'),
    ]

    operations = [
        migrations.RunPython(
            rename_admin_to_hod,
            reverse_code=rename_hod_to_admin
        ),
    ]