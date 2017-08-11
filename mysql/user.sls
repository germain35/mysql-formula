{% from "mysql/map.jinja" import mysql_settings with context %}

include:
  - mysql.database

{%- for user, params in mysql_settings.users.iteritems() %}

mysql_user_{{user}}:
  mysql_user.present:
    - name: {{user}}
    - host: {{params.host}}
    - password: {{params.password}}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: '{{mysql_settings.root_password}}'
    - connection_charset: utf8

  {%- if 'grants' in params %}
    {%- for db, db_params in params.grants.iteritems() %}
mysql_grant_{{user}}_{{db}}:
  mysql_grants.present:
    - grant: {{db_params.grant|join(',')}}
    - database: {{db ~ '.*'}}
    - user: {{user}}
    - host: {{params.host}}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: '{{mysql_settings.root_password}}'
    - connection_charset: utf8
    - require: 
      - mysql_user: mysql_user_{{user}}
      - mysql_database: mysql_database_{{db}}
    {%- endfor %}
  {%- endif %}

{%- endfor %}

