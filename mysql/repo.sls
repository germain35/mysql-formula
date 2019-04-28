{% from "mysql/map.jinja" import mysql with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if mysql.manage_repo %}
  {%- if 'repo' in mysql and mysql.repo is mapping %}
mysql_repo:
  pkgrepo.managed:
  {%- for k, v in mysql.repo.items() %}
    - {{k}}: {{v}}
    - retry:
        attempts: 5
        until: True
        interval: 10
    {%- endfor %}
  {%- endif %}
{%- endif %}
