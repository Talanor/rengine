# Generated by Django 3.2.4 on 2024-04-21 05:06

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('dashboard', '0011_ollamasettings_is_ollama'),
    ]

    operations = [
        migrations.RenameField(
            model_name='ollamasettings',
            old_name='is_ollama',
            new_name='is_openai',
        ),
    ]
