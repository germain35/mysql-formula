{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql.service

mysql_config_directory:
  file.directory:
    - name: {{mysql.config_directory}}
    - makedirs: True
    - clean: True
    - user: root
    - group: root
    - mode: 0755


{%- if 'config' in mysql and mysql.config is mapping %}
  {%- set global_params= {} %}
  {%- if 'my.cnf' in mysql.config %}
    {%- do global_params.update(mysql.config['my.cnf'].get('mysqld',{})) %}
  {%- endif %}
  {%- for file, content in mysql.config|dictsort %}
    {%- do global_params.update(mysql.config[file].get('mysqld',{})) if file != 'my.cnf' %}
    {%- if file == 'my.cnf' %}
      {%- set filepath = mysql.config_file %}
    {%- else %}
      {%- set filepath = mysql.config_directory + '/' + file %}
    {%- endif %}
{{filepath}}:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://mysql/templates/mysql.cnf.j2
    - template: jinja
    - context:
        config: {{ content|default({}) }}
    - require_in:
      - pkg: mysql_client_pkg
      - pkg: mysql_server_pkg
    - require:
      - file: mysql_config_directory
      {%- if mysql.reload_on_change %}
    - watch_in:
      - service: mysql_svc
      {%- endif %}
  {%- endfor %}
{%- endif %}


{%- for global, value in global_params.iteritems() %}
  {%- if 'tmpdir' in global %}
{{ value }}:
  file.directory:
    - mode: 1777
    - makedirs: True
    - require_in:
      - pkg: mysql_server_pkg
  {%- endif %}
{%- endfor %}
