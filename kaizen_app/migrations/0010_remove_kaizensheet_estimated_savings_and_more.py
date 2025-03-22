# Generated by Django 5.1.2 on 2024-11-22 06:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0009_kaizensheet_estimated_savings_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='kaizensheet',
            name='estimated_savings',
        ),
        migrations.RemoveField(
            model_name='kaizensheet',
            name='supported_by',
        ),
        migrations.AlterField(
            model_name='kaizensheet',
            name='savings_start_month',
            field=models.CharField(blank=True, max_length=20, null=True),
        ),
    ]
