{% from "mysql/map.jinja" import mysql with context %}

mysql_backup_script:
  file.managed:
    - name: {{ mysql.backup_script }}
    - source: salt://mysql/templates/backup.sh.j2
    - template: jinja
    - mode: 755
    - makedirs: True

mysql_backup_dir:
  file.directory:
    - name: {{ mysql.backup.dir }}

{%- if mysql.backup.cron is defined %}
mysql_backup_log:
  file.managed:
    - name: {{ mysql.backup_log }}
    - replace: False
    - makedirs: True
    - require:
      - file: mysql_backup_script

mysql_backup_cron:
  cron.present:
    - identifier: mysql_backup
    - name: "{{ mysql.backup_script }} > {{ mysql.backup_log }} 2>&1"
    - user: root
    {%- if mysql.backup.cron.special is defined %}
    - special: {{mysql.backup.cron.special}}
    {%- else %}
      {%- if mysql.backup.cron.daymonth is defined %}
    - daymonth: {{mysql.backup.cron.daymonth}}
      {%- endif %}
      {%- if mysql.backup.cron.month is defined %}
    - month: {{mysql.backup.cron.month}}
      {%- endif %}
      {%- if mysql.backup.cron.dayweek is defined %}
    - dayweek: {{mysql.backup.cron.dayweek}}
      {%- endif %}
      {%- if mysql.backup.cron.hour is defined %}
    - hour: {{mysql.backup.cron.hour}}
      {%- endif %}
      {%- if mysql.backup.cron.minute is defined %}
    - minute: {{mysql.backup.cron.minute}}
      {%- endif %}
    {%- endif %}
    - require:
      - file: mysql_backup_script
{%- endif %}