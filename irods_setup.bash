#!/bin/bash

SUDO=''

sudo_is_pwless()
{
  sudo -n ls /root >/dev/null && { SUDO=sudo; true; }
} \
2>/dev/null

make_sudo_pwless()
{
  sudo_is_pwless && return;
  local cmd="echo '$USER ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers"
  sudo su - -c "/bin/bash -c \"$cmd\"" && SUDO='sudo'
}

can_be_root() { [ `id -u` = 0 ] || make_sudo_pwless; }

ensure_preinstall_pkgs()
{
  can_be_root || return 126
  [ -n "$PREINSTALL" ] || return 0;
  for pkg in $PREINSTALL; do
    echo >&2 "checking $pkg ."
    rpm -q $pkg >/dev/null || $SUDO yum install -y $pkg
  done
}

install_prereqs()
{
  can_be_root || return 126
  local STATUS=good
  for pkg in epel-release postgresql-server ;do
    command $SUDO yum install -y $pkg || { STATUS=bad; break; }
  done
  [ $STATUS = "good" ] && command $SUDO su - postgres -c "/usr/bin/pg_ctl initdb"
}

db_ctl()
{
  [ "$1" = restart ] && { db_ctl stop ; db_ctl start; return; }
  can_be_root || return 126
  if pgrep -f -u postgres bin/postgres >/dev/null
  then
    x=${DB_WAIT_SEC:-15}
    while [ $((--x)) -ge 0 ] && { ! $SUDO su - postgres -c "psql -c '\l' >/dev/null 2>&1" || x=""; }
    do
      [ -z "$x" ] && break
      sleep 1
    done
    [ -z "$x" ] && {
      DB_RUNNING="Y"
      [ "$1" = "stop" ] && { $SUDO su - postgres -c "/usr/bin/pg_ctl stop" ; return; }
    }
  else
    DB_RUNNING="N"
    [ "$1" = "start" ] && { $SUDO su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start" ; return; }
  fi
  [ "$DB_RUNNING" = "Y" ]
}

set_up_coredev_repo()
{
  can_be_root || return 126
  $SUDO  rpm --import https://core-dev.irods.org/irods-core-dev-signing-key.asc
  wget -qO - https://core-dev.irods.org/renci-irods-core-dev.yum.repo | $SUDO tee /etc/yum.repos.d/renci-irods-core-dev.yum.repo
}

install_build_prereqs()
{
  command $SUDO yum install -y pam-devel python-psutil python-requests python-jsonschema
}

set_up_package_repo()
{
  can_be_root || return 126
  $SUDO rpm --import https://packages.irods.org/irods-signing-key.asc
  wget -qO - https://packages.irods.org/renci-irods.yum.repo | $SUDO tee /etc/yum.repos.d/renci-irods.yum.repo
}

uninit_database_and_user() {
  can_be_root || return 126
  $SUDO su - postgres -c "dropdb --if-exists ICAT ; dropuser --if-exists irods"

}

PSQL_IRODS_INIT="psql <<'EOF'
CREATE USER irods WITH PASSWORD 'testpassword';
CREATE DATABASE \"ICAT\";
GRANT ALL PRIVILEGES ON DATABASE \"ICAT\" TO irods;
EOF
"

init_database_and_user()
{
  can_be_root || return 126
  $SUDO su - postgres -c "$PSQL_IRODS_INIT"
}

# ---

SOURCE_DIR=$(dirname "${BASH_SOURCE[0]}")

if [ -r /tmp/preinstall.txt ]; then
    PREINSTALL=$(cat /tmp/preinstall.txt)
elif [ -r "$SOURCE_DIR"/preinstall.txt ]; then
    PREINSTALL=$(cat "$SOURCE_DIR"/preinstall.txt)
else
    PREINSTALL="wget sudo"
fi

if [ -r /tmp/db_wait_sec.sh ]; then
    source /tmp/db_wait_sec.sh
elif [ -r "$SOURCE_DIR"/db_wait_sec.sh ]; then
    source "$SOURCE_DIR"/db_wait_sec.sh
else
    DB_WAIT_SEC=30
fi
