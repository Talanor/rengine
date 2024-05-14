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

watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --loglevel=info --autoscale=$MAX_CONCURRENCY,$MIN_CONCURRENCY -Q main_scan_queue &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=30 --loglevel=info -Q initiate_scan_queue -n initiate_scan_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=30 --loglevel=info -Q subscan_queue -n subscan_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=20 --loglevel=info -Q report_queue -n report_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q send_notif_queue -n send_notif_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q send_scan_notif_queue -n send_scan_notif_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q send_task_notif_queue -n send_task_notif_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=5 --loglevel=info -Q send_file_to_discord_queue -n send_file_to_discord_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=5 --loglevel=info -Q send_hackerone_report_queue -n send_hackerone_report_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q parse_nmap_results_queue -n parse_nmap_results_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=20 --loglevel=info -Q geo_localize_queue -n geo_localize_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q query_whois_queue -n query_whois_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=30 --loglevel=info -Q remove_duplicate_endpoints_queue -n remove_duplicate_endpoints_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=50 --loglevel=info -Q run_command_queue -n run_command_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q query_reverse_whois_queue -n query_reverse_whois_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q query_ip_history_queue -n query_ip_history_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=30 --loglevel=info -Q gpt_queue -n gpt_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q dorking_queue -n dorking_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q osint_discovery_queue -n osint_discovery_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q h8mail_queue -n h8mail_worker &
watchmedo auto-restart --recursive --pattern="*.py" --directory="/home/rengine/rengine/" -- poetry run -C $HOME/ celery -A reNgine.tasks worker --pool=gevent --concurrency=10 --loglevel=info -Q theHarvester_queue -n theHarvester_worker