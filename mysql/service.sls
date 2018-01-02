{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.server

mysql_svc:
  service.running:
    - name: {{ mysql.server_svc }}
    - enable: {{ mysql.service_enabled }}
    - reload: {{ mysql.service_reload }}
    - require:
      - pkg: mysql_server_pkg
