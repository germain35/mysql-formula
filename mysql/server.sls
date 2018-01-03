{% from "mysql/map.jinja" import mysql with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - mysql.repo
  - mysql.client
  - mysql.config
  - mysql.service


{%- if mysql.get('root_password', False) %}
  {%- if os_family == 'Debian' %}
mysql_debconf_utils_pkg:
  pkg.installed:
    - name: {{ mysql.debconf_utils_pkg }}

{%- if mysql.application|lower == 'percona' %}
  {%- set debconf_prefix = 'percona-server-server' %}
{%- else %}
  {%- set debconf_prefix = 'mysql-server' %}
{%- endif %}

mysql_debconf:
  debconf.set:
    - name: {{ mysql.server_pkg }}
    - data:
        '{{ debconf_prefix }}/root_password': {'type': 'password', 'value': '{{ mysql.root_password }}'}
        '{{ debconf_prefix }}/root_password_again': {'type': 'password', 'value': '{{ mysql.root_password }}'}
        '{{ mysql.server_pkg }}/data-dir': {'type': 'select', 'value': ''}
        '{{ mysql.server_pkg }}/root-pass': {'type': 'password', 'value': '{{ mysql.root_password }}'}
        '{{ mysql.server_pkg }}/re-root-pass': {'type': 'password', 'value': '{{ mysql.root_password }}'}
        '{{ mysql.server_pkg }}/start_on_boot': {'type': 'boolean', 'value': 'true'}
        '{{ mysql.server_pkg }}/remove-test-db': {'type': 'select', 'value': 'true'}
    - require_in:
      - pkg: mysql_server_pkg
    - require:
      - pkg: mysql_debconf_utils_pkg
  {%- endif %}
{%- endif %}

mysql_server_pkg:
  pkg.installed:
    - name: {{ mysql.server_pkg }}
    - refresh: True
    {%- if mysql.manage_repo %}
    - require:
      - pkgrepo: mysql_repo
      - sls: mysql.client
    {%- endif %}
