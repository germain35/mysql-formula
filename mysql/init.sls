{% from "mysql/map.jinja" import mysql with context %}

include:
  {%- if mysql.client %}
  - mysql.client
  {%- endif %}
  {%- if mysql.server %}
  - mysql.server
  {%- endif %}
  - mysql.database
  - mysql.user
  {%- if mysql.backup.enabled %}
  - mysql.backup
  {%- endif %}