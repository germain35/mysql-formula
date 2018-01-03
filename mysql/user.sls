{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.database

{%- for user, params in mysql.get('users', {}).iteritems() %}

mysql_user_{{user}}:
  mysql_user.present:
    - name: {{user}}
    - host: {{params.host | yaml_dquote}}
    - password: {{params.password}}
    - connection_host: {{params.get('connection_host', 'localhost')}}
    - connection_user: {{params.get('connection_user', 'root')}}
    - connection_pass: '{{params.get('connection_pass', mysql.root_password)}}'
    - connection_charset: {{params.get('connection_charset', 'utf8')}}

  {%- if 'grants' in params %}
    {%- for db, db_params in params.grants.iteritems() %}
mysql_grant_{{user}}_{{db}}:
  mysql_grants.present:
    - grant: {{db_params.grant|join(',')}}
    - database: '{{db ~ ".*"}}'
    - user: {{user}}
    - host: '{{params.host}}'
    - connection_host: {{params.get('connection_host', 'localhost')}}
    - connection_user: {{params.get('connection_user', 'root')}}
    - connection_pass: '{{params.get('connection_pass', mysql.root_password)}}'
    - connection_charset: {{params.get('connection_charset', 'utf8')}}
    - require: 
      - mysql_user: mysql_user_{{user}}
    {%- endfor %}
  {%- endif %}

{%- endfor %}

