import os

from celery._state import get_current_task
from celery.utils.log import ColorFormatter
from django.utils.translation import gettext_lazy


def is_safe_path(basedir, path, follow_symlinks=True):
	# Source: https://security.openstack.org/guidelines/dg_using-file-paths.html
	# resolves symbolic links
	if follow_symlinks:
		matchpath = os.path.realpath(path)
	else:
		matchpath = os.path.abspath(path)
	return basedir == os.path.commonpath((basedir, matchpath))


# Source: https://stackoverflow.com/a/10408992
def remove_lead_and_trail_slash(s):
	if s.startswith('/'):
		s = s[1:]
	if s.endswith('/'):
		s = s[:-1]
	return s


def get_time_taken(latest, earlier):
	duration = latest - earlier
	days, seconds = duration.days, duration.seconds
	hours = days * 24 + seconds // 3600
	minutes = (seconds % 3600) // 60
	seconds = seconds % 60
	if not hours and not minutes:
		return gettext_lazy('%(seconds)s seconds') % {"seconds": seconds}
	elif not hours:
		return gettext_lazy('%(minutes)s minutes') % {"minutes": minutes}
	elif not minutes:
		return gettext_lazy('%(hours)s hours') % {"hours": hours}
	return gettext_lazy('%(hours)s hours %(minutes)s minutes') % {"hours": hours, "minutes": minutes}

# Check if value is a simple string, a string with commas, a list [], a tuple (), a set {} and return an iterable
def return_iterable(string):
	if not isinstance(string, (list, tuple)):
		string = [string]

	return string


# Logging formatters

class RengineTaskFormatter(ColorFormatter):

	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		try:
			self.get_current_task = get_current_task
		except ImportError:
			self.get_current_task = lambda: None

	def format(self, record):
		task = self.get_current_task()
		if task and task.request:
			task_name = '/'.join(task.name.replace('tasks.', '').split('.'))
			record.__dict__.update(task_id=task.request.id,
								   task_name=task_name)
		else:
			record.__dict__.setdefault('task_name', f'{record.module}.{record.funcName}')
			record.__dict__.setdefault('task_id', '')
		return super().format(record)


def get_gpt_vuln_input_description(title, path):
	vulnerability_description = ''
	vulnerability_description += gettext_lazy('Vulnerability Title: %(vulnerabilityTitle)s') % {'vulnerabilityTitle': title}
	# gpt gives concise vulnerability description when a vulnerable URL is provided
	vulnerability_description += gettext_lazy('\nVulnerable URL: %(path)s') % {'path': path}

	return vulnerability_description


def replace_nulls(obj):
	if isinstance(obj, str):
		return obj.replace("\x00", "")
	elif isinstance(obj, list):
		return [replace_nulls(item) for item in obj]
	elif isinstance(obj, dict):
		return {key: replace_nulls(value) for key, value in obj.items()}
	else:
		return obj
