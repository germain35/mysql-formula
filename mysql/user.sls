{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.database

{%- for user, params in mysql.get('users', {}).items() %}

mysql_user_{{ user }}:
  mysql_user.present:
    - name: {{ user }}
    - host: '{{ params.get('host', mysql.host) }}'
    - password: {{ params.get('password', mysql.password) }}
    - connection_host: {{ params.get('connection_host', mysql.connection_host) }}
    - connection_user: {{ params.get('connection_user', mysql.connection_user) }}
    - connection_pass: '{{ params.get('connection_pass', mysql.root_password) }}'
    - connection_charset: {{ params.get('connection_charset', mysql.connection_charset) }}

  {%- if 'grants' in params %}
    {%- for db, db_params in params.grants.items() %}
mysql_grant_{{ user }}_{{ db }}:
  mysql_grants.present:
    - grant: {{ db_params.grant|join(',') }}
    - grant_option: {{ db_params.get('grant_option', False) }}
    - database: '{{ db ~ ".*" }}'
    - user: {{ user }}
    - host: '{{ params.get('host', mysql.host) }}'
    - connection_host: {{ params.get('connection_host', mysql.connection_host) }}
    - connection_user: {{ params.get('connection_user', mysql.connection_user) }}
    - connection_pass: '{{ params.get('connection_pass', mysql.root_password) }}'
    - connection_charset: {{ params.get('connection_charset', mysql.connection_charset) }}
    - require: 
      - mysql_user: mysql_user_{{user}}
    {%- endfor %}
  {%- endif %}

{%- endfor %}

