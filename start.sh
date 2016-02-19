#!/bin/bash

openvas-mkcert -q -f
openvas-mkcert-client -n -i
openvas-nvt-sync
openvas-scapdata-sync
openvas-certdata-sync
openvasmd --create-user=${OPENVAS_ADMIN_USER} --role=Admin
openvasmd --user=${OPENVAS_ADMIN_USER} --new-password=${OPENVAS_ADMIN_PASSWORD}
