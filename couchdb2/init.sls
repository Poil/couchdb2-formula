{% from "couchdb2/map.jinja" import couchdb2 with context %}
couchdb2_repo:
  pkgrepo.managed:
    - humanname: bintray-apache-couchdb-rpm
    - name: bintray-apache-couchdb-rpm
    - baseurl: {{ couchdb2.repo_url }}
    - gpgcheck: 0
    - repo_gpgcheck: 0
    - enabled: 1
{%- if couchdb2.proxy %}
    - proxy: {{ couchdb2.proxy }}
{%- endif %}

couchdb2_package:
  pkg.installed:
    - pkgs:
      - couchdb

{%- if 'config_files' in couchdb2 and couchdb2.config_files %}
  {%- for key, value in couchdb2.config_files %}
couchdb2_config_{{ key }}:
  file.serialize:
    - name: /opt/couchdb/etc/local.d/{{ key }}.ini
    - dataset:
        {{ value | yaml() | indent(8) }}
    - formatter: configparser
  {%- endfor %}
{%- endif %}

couchdb2_service:
  service.running:
    - name: couchdb
    - enable: True
    - reload: True
    - watch:
      - couchdb2_package
{%- if 'config_files' in couchdb2.config_files %}
  {%- for key, value in couchdb2.config_files.items() %}
      - couchdb2_config_{{ key }}
  {%- endfor %}
{%- endif %}

couchdb2_wait_running:
  http.wait_for_successful_query:
    - name: http://127.0.0.1:5984/_up
    - match: '{"status":"ok"}'
    - wait_for: 60
    - request_interval: 5

{%- if couchdb2.mode == 'singledb' %}
couchdb_initial_config_users:
  http.query:
    - name: http://127.0.0.1:5984/_users
    - method: PUT
    - status: 201
    - onchanges:
      - couchdb2_package

couchdb_initial_config_replicator:
  http.query:
    - name: http://127.0.0.1:5984/_replicator
    - method: PUT
    - status: 201
    - onchanges:
      - couchdb2_package

couchdb_initial_config_global_changes:
  http.query:
    - name: http://127.0.0.1:5984/_global_changes
    - method: PUT
    - status: 201
    - onchanges:
      - couchdb2_package

couchdb_initial_config_admin:
  http.query:
    - name: http://127.0.0.1:5984/_node/couchdb@127.0.0.1/_config/admins/admin
    - data: '"{{ couchdb2.admin_password }}"'
    - method: PUT
    - status: 200
    - onchanges:
      - couchdb2_package
{%- endif %}

{%- if 'users' in couchdb2 and couchdb2.users %}
  {%- for key, value in couchdb2.users.items() %}
couchdb2_user_check_{{ key }}:
  http.query:
    - name: http://localhost:5984/_users/org.couchdb.user:{{ key }}
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200

couchdb2_user_{{ key }}:
  http.query:
    - name: http://localhost:5984/_users/org.couchdb.user:{{ key }}
    - method: PUT
    - header_dict:
        Accept: application/json
        Content-Type: application/json
    - data: '{ "name": "{{ key }}", "password": "{{ value['password'] }}", "roles": {{ value['roles'] }}, "type": "user" }'
    - username: admin
    - password: test123
    - status: 201
    - onfail:
      - couchdb2_user_check_{{ key }}
  {%- endfor %}
{%- endif %}

include:
  - couchdb2.cors
