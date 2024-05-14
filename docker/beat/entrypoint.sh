#!/bin/bash

echo "INSERT INTO django_migrations (app, name, applied) SELECT 'users', '0001_initial', CURRENT_TIMESTAMP WHERE NOT EXISTS (SELECT app FROM django_migrations WHERE app = 'users' AND name = '0001_initial');" | python3 manage.py dbshell
echo "UPDATE django_content_type SET app_label = 'users' WHERE app_label = 'auth' and model = 'user';" | python3 manage.py dbshell

poetry run -C $HOME/ python3 manage.py migrate
poetry run -C $HOME/ python3 manage.py collectstatic --no-input --clear

# Load default engines, keywords, and external tools
poetry run -C $HOME/ python3 manage.py loaddata fixtures/default_scan_engines.yaml --app scanEngine.EngineType
poetry run -C $HOME/ python3 manage.py loaddata fixtures/default_keywords.yaml --app scanEngine.InterestingLookupModel
poetry run -C $HOME/ python3 manage.py loaddata fixtures/external_tools.yaml --app scanEngine.InstalledExternalTool

# Compile messages translations
find . -type f -name "*.po" -exec sed -i 's/^#~ //g' {} +
python3 manage.py compilemessages

loglevel='info'
if [ "$DEBUG" == "1" ]; then
    loglevel='debug'
fi

poetry run -C $HOME/ celery -A reNgine beat --loglevel=$loglevel --scheduler django_celery_beat.schedulers:DatabaseScheduler

exec "$@"
