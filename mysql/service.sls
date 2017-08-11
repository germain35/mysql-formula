{% from "mysql/map.jinja" import mysql_settings with context %}

include:
  - mysql.server

mysql_svc:
  service.running:
    - name: {{ mysql_settings.server_svc }}
    - enable: True
    - require:
      - pkg: mysql_server_pkg