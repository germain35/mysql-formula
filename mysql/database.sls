{% from "mysql/map.jinja" import mysql with context %}

{%- for database, params in mysql.get('databases', {}).iteritems() %}
mysql_database_{{database}}:
  mysql_database.present:
    - name: {{database}}
    - character_set: {{params.character_set}}
    - collate: {{params.collate}}
    - connection_host: {{params.get('connection_host', 'localhost')}}
    - connection_user: {{params.get('connection_user', 'root')}}
    - connection_pass: '{{params.get('connection_pass', mysql.root_password)}}'
    - connection_charset: {{params.get('connection_charset', 'utf8')}}
{%- endfor %}
