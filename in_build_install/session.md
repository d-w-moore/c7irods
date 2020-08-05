Sample session for using this rough-and-ready Docker build:

```
$ docker  build -t c7inbuild -f Dockerfile.in-build-install .

$ docker run c7inbuild bash -c "cat /tmp/hostname"
bbfc36c193e0                                            # <-- hostname of container and server
                                                        #     during the build; repeat this string in
                                                        #     the docker run --hostname option below

$ docker run --name c7_irods_1 --hostname bbfc36c193e0 -it  c7inbuild bash

[INSIDE THE CONTAINER:]

    # su - postgres -c 'pg_ctl -D /var/lib/pgsql/data -l logfile start'

    server starting

    # sleep 8 ; su - irods -c '~/irodsctl start'

    Validating [/var/lib/irods/.irods/irods_environment.json]... Success
    Validating [/var/lib/irods/VERSION.json]... Success
    Validating [/etc/irods/server_config.json]... Success
    Validating [/etc/irods/host_access_control_config.json]... Success
    Validating [/etc/irods/hosts_config.json]... Success
    Ensuring catalog schema is up-to-date...
    Catalog schema is up-to-date.
    Starting iRODS server...
    Success

    # su - irods                    # test the server is up and working ;
                                    # in the $ prompts below we are user 'irods'

    Last login: Thu Aug  6 13:11:45 UTC 2020 on pts/0
    -bash-4.2$ ils
    /tempZone/home/rods:
    -bash-4.2$ iput VERSION.json.dist
    -bash-4.2$ iput /etc/irods/server_config.json 
    -bash-4.2$ ils
    /tempZone/home/rods:
      VERSION.json.dist
      server_config.json
    -bash-4.2$ 

```
