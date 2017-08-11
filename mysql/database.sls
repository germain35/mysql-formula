{% from "mysql/map.jinja" import mysql_settings with context %}

{%- for database, params in mysql_settings.databases.iteritems() %}
mysql_database_{{database}}:
  mysql_database.present:
    - name: {{database}}
    - character_set: {{params.character_set}}
    - collate: {{params.collate}}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: '{{mysql_settings.root_password}}'
    - connection_charset: utf8
{%- endfor %}