#!/bin/bash
DIR=$(dirname "$0")
. "$DIR"/irods_setup.bash
ensure_preinstall_pkgs 
install_prereqs 
db_ctl start
db_ctl
init_database_and_user
set_up_package_repo 
sudo yum install -y irods-server 
sudo yum install -y irods-database-plugin-postgres.x86_64
sudo python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input 
