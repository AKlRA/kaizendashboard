# Generated by Django 5.1.2 on 2025-01-30 14:19

from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0026_remove_kaizensheet_benefits'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='profile',
            name='employee_id',
            field=models.CharField(blank=True, help_text='Employee identification number', max_length=50, null=True),
        ),
        migrations.AddConstraint(
            model_name='profile',
            constraint=models.UniqueConstraint(fields=('employee_id', 'user_type'), name='unique_employee_id_per_role'),
        ),
    ]
