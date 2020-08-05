. /irods_setup.bash 
ensure_preinstall_pkgs 
install_prereqs 
db_ctl start
db_ctl
init_database_and_user
set_up_package_repo 
yum install -y irods-server 
yum install -y irods-database-plugin-postgres.x86_64
python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input 
