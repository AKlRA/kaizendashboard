# Generated by Django 5.1.2 on 2024-12-07 06:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('kaizen_app', '0023_departmentkaizendata_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='KaizenCoordinator',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('department', models.CharField(max_length=100, unique=True)),
                ('coordinator_name', models.CharField(blank=True, max_length=150, null=True)),
            ],
        ),
        migrations.DeleteModel(
            name='DepartmentKaizenData',
        ),
    ]
