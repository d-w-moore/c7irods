#!/bin/bash
DIR=$(dirname "$0")
. "$DIR"/irods_setup.bash
ensure_preinstall_pkgs 
install_prereqs 
set_up_package_repo 
if [ $1 != "devel-and-runtime-only" ]; then
  db_ctl start
  db_ctl
  init_database_and_user
  yum install -y irods-server 
  yum install -y irods-database-plugin-postgres.x86_64
  python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input 
fi
