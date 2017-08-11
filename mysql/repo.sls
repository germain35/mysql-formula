{% from "mysql/map.jinja" import mysql_settings with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if mysql_settings.manage_repo %}
  {%- if 'repo' in mysql_settings and mysql_settings.repo is mapping %}
  mysql_repo:
    pkgrepo.managed:
    {%- for k, v in mysql_settings.repo.iteritems() %}
      - {{k}}: {{v}}
    {%- endfor %}
  {%- endif %}
{%- endif %}