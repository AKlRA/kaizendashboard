# Generated by Django 5.1.2 on 2024-11-29 09:04

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0015_kaizensheet_finance_approved_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='kaizensheet',
            name='approval_status',
            field=models.CharField(choices=[('pending', 'Pending'), ('hod_approved', 'HOD Approved'), ('finance_pending', 'Finance Review Pending'), ('finance_approved', 'Finance Approved'), ('finance_rejected', 'Finance Rejected'), ('coordinator_approved', 'Fully Approved')], default='pending', max_length=20),
        ),
    ]
