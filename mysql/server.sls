{% from "mysql/map.jinja" import mysql_settings with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - mysql.repo
  - mysql.client
  - mysql.config
  - mysql.database
  - mysql.user
  - mysql.service


{%- if mysql_settings.get('root_password', False) %}
  {%- if os_family == 'Debian' %}
mysql_debconf_utils_pkg:
  pkg.installed:
    - name: {{ mysql_settings.debconf_utils_pkg }}

{%- if mysql_settings.application|lower == 'percona' %}
  {%- set debconf_prefix = 'percona-server-server' %}
{%- else %}
  {%- set debconf_prefix = 'mysql-server' %}
{%- endif %}

mysql_debconf:
  debconf.set:
    - name: {{ mysql_settings.server_pkg }}
    - data:
        '{{ debconf_prefix }}/root_password': {'type': 'password', 'value': '{{ mysql_settings.root_password }}'}
        '{{ debconf_prefix }}/root_password_again': {'type': 'password', 'value': '{{ mysql_settings.root_password }}'}
        '{{ mysql_settings.server_pkg }}/data-dir': {'type': 'select', 'value': ''}
        '{{ mysql_settings.server_pkg }}/root-pass': {'type': 'password', 'value': '{{ mysql_settings.root_password }}'}
        '{{ mysql_settings.server_pkg }}/re-root-pass': {'type': 'password', 'value': '{{ mysql_settings.root_password }}'}
        '{{ mysql_settings.server_pkg }}/start_on_boot': {'type': 'boolean', 'value': 'true'}
        '{{ mysql_settings.server_pkg }}/remove-test-db': {'type': 'select', 'value': 'true'}
    - require_in:
      - pkg: mysql_server_pkg
    - require:
      - pkg: mysql_debconf_utils_pkg
  {%- endif %}
{%- endif %}

mysql_server_pkg:
  pkg.installed:
    - name: {{ mysql_settings.server_pkg }}
    - refresh: True
    {%- if mysql_settings.manage_repo %}
    - require:
      - pkgrepo: mysql_repo
    {%- endif %}
