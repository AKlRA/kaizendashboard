# Generated by Django 5.1.2 on 2025-02-05 13:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0028_add_last_department_change'),
    ]

    operations = [
        migrations.AddField(
            model_name='kaizensheet',
            name='submission_department',
            field=models.CharField(default='default', max_length=100),
        ),
    ]
