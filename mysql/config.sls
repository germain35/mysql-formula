{% from "mysql/map.jinja" import mysql with context %}

{%- if mysql.server %}
include:
  - mysql.service
{%- endif %}

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
      {%- if mysql.server %}
      - pkg: mysql_server_pkg
      {%- endif %}
    - require:
      - file: mysql_config_directory
    {%- if mysql.server %}
    - watch_in:
      - service: mysql_svc
    {%- endif %}
  {%- endfor %}
{%- endif %}

{%- if mysql.server %}

  {%- if 'tmpdir' in global_params.keys() %}
{{ global_params.get('tmpdir') }}:
  file.directory:
    - mode: 1777
    - makedirs: True
    - require_in:
      - pkg: mysql_server_pkg
  {%- elif 'datadir' in global_params.keys() %}
{{ global_params.get('datadir') }}:
  file.directory:
    - makedirs: True
    - require_in:
      - pkg: mysql_server_pkg
  {%- endif %}

mysql_root_conf:
  file.managed:
    - name: /root/.my.cnf
    - source: salt://mysql/templates/my.cnf.j2
    - template: jinja
    - user: root
    - mode: 600

{%- endif %}
