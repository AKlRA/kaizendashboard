# Generated by Django 5.1.2 on 2024-12-07 06:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0021_alter_profile_department'),
    ]

    operations = [
        migrations.CreateModel(
            name='DepartmentKaizenCoordinator',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('coordinator_name', models.CharField(max_length=100)),
            ],
        ),
    ]
