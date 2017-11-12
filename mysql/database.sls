{% from "mysql/map.jinja" import mysql with context %}

{%- for database, params in mysql.databases.iteritems() %}
mysql_database_{{database}}:
  mysql_database.present:
    - name: {{database}}
    - character_set: {{params.character_set}}
    - collate: {{params.collate}}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: '{{mysql.root_password}}'
    - connection_charset: utf8
{%- endfor %}
