{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.server

mysql_svc:
  service.running:
    - name: {{ mysql.server_svc }}
    - enable: True
    - require:
      - pkg: mysql_server_pkg
