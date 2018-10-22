{% from "couchdb2/map.jinja" import couchdb2 with context %}
couchdb2_cors_check_enable:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/httpd/enable_cors
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - match: '"{{ couchdb2.cors | lower() }}"'

couchdb2_cors_enable:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/httpd/enable_cors
    - method: PUT
    - data: '"{{ couchdb2.cors | lower() }}"'
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - onfail:
      - couchdb2_cors_check_enable

{%- if couchdb2.cors == True %}
couchdb2_cors_check_origins:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/origins
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - match: '"*"'

couchdb2_cors_origins:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/origins
    - method: PUT
    - data: '"*"'
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - onfail:
      - couchdb2_cors_check_origins

couchdb2_cors_check_credentials:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/credentials
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - match: '"true"'

couchdb2_cors_credentials:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/credentials
    - method: PUT
    - data: '"true"'
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - onfail:
      - couchdb2_cors_check_credentials

couchdb2_cors_check_methods:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/methods
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - match: '"GET, PUT, POST, HEAD, DELETE"'

couchdb2_cors_methods:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/methods
    - method: PUT
    - data: '"GET, PUT, POST, HEAD, DELETE"'
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - onfail:
      - couchdb2_cors_check_methods

couchdb2_cors_check_headers:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/headers
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - match: '"accept, authorization, content-type, origin, referer, x-csrf-token"'

couchdb2_cors_headers:
  http.query:
    - name: http://localhost:5984/_node/couchdb@127.0.0.1/_config/cors/headers
    - method: PUT
    - data: '"accept, authorization, content-type, origin, referer, x-csrf-token"'
    - username: admin
    - password: {{ couchdb2.admin_password }}
    - status: 200
    - onfail:
      - couchdb2_cors_check_headers
{%- endif %}
