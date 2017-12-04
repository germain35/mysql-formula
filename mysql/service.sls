{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.server

mysql_svc:
  service.running:
    - name: {{ mysql.server_svc }}
    - enable: True
    {%- if mysql.reload_on_change %}
    - reload: True
    {%- endif %}
    - require:
      - pkg: mysql_server_pkg
