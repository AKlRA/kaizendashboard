# Generated by Django 5.1.2 on 2024-11-30 04:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0018_alter_kaizensheet_horizontal_departments'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='kaizensheet',
            name='horizontal_departments',
        ),
        migrations.AddField(
            model_name='kaizensheet',
            name='horizontal_departments',
            field=models.TextField(blank=True, help_text='Comma-separated list of departments for horizontal deployment', null=True),
        ),
    ]
