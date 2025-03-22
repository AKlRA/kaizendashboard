# Generated by Django 5.1.2 on 2025-02-07 15:42

from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0033_alter_kaizensheet_area_implemented'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='profile',
            name='user_type',
            field=models.CharField(choices=[('employee', 'Employee'), ('coordinator', 'Coordinator'), ('hod', 'Hod'), ('finance', 'Finance and Accounts'), ('admin', 'Admin')], default='employee', max_length=20),
        ),
        migrations.AddConstraint(
            model_name='profile',
            constraint=models.UniqueConstraint(condition=models.Q(('user_type', 'hod')), fields=('department', 'user_type'), name='unique_hod_per_department'),
        ),
        migrations.AddConstraint(
            model_name='profile',
            constraint=models.UniqueConstraint(fields=('user', 'user_type'), name='unique_user_type_per_user'),
        ),
    ]
