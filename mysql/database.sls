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

{%- if params.query_file is defined %}
    {%- for query_file in params.query_file %}
mysql_database_{{database}}_query_file_{{ loop.index0 }}:
  mysql_query.run_file:
    - database: {{database}}
    - query_file: {{query_file}}
    - connection_host: {{params.get('connection_host', 'localhost')}}
    - connection_user: {{params.get('connection_user', 'root')}}
    - connection_pass: '{{params.get('connection_pass', mysql.root_password)}}'
    - connection_charset: {{params.get('connection_charset', 'utf8')}}
    - require:
      - mysql_database: mysql_database_{{database}}
    {%- endfor %}
  {%- endif %}

  {%- if params.query is defined %}
    {%- for query in params.query %}
mysql_database_{{database}}_query_{{ loop.index0 }}:
  mysql_query.run:
    - database: {{database}}
    - query: "{{query}}"
    - connection_host: {{params.get('connection_host', 'localhost')}}
    - connection_user: {{params.get('connection_user', 'root')}}
    - connection_pass: '{{params.get('connection_pass', mysql.root_password)}}'
    - connection_charset: {{params.get('connection_charset', 'utf8')}}
    - require:
      - mysql_database: mysql_database_{{database}}
    {%- endfor %}
  {%- endif %}

{%- endfor %}
