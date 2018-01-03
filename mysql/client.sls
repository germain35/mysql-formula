{% from "mysql/map.jinja" import mysql with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - mysql.repo
  - mysql.config
  - mysql.database
  - mysql.user

mysql_client_pkg:
  pkg.installed:
    - name: {{ mysql.client_pkg }}
    - refresh: True
    {%- if mysql.manage_repo %}
    - require:
      - pkgrepo: mysql_repo
    {%- endif %}

mysql_python_pkg:
  pkg.installed:
    - name: {{ mysql.python_pkg }}
    - require:
      - pkg: mysql_client_pkg
