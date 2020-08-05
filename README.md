# c7irods

  - Part I (The Easy Way)
  ```
  $ git clone http://github.com/d-w-moore/c7irods
  $ cd c7irods ; docker build -t c7irods .
  $ docker run -it c7irods
  (INSIDE THE CONTAINER):
      # /do_install.sh
          <... iRODS server will be installed and launched here ...> 
      # su - irods
      (irods)$ ./irodsctl start
      (irods)$ iput /etc/irods/server_config.json ./VERSION.json.dist
      (irods)$ ils
  ```

  - Part II (The Hard Way, but you'll learn more)
    * Go to the subdirectory:
    ```
    $ cd ./in_build_install
    ```
    * Follow the directions [here](./in_build_install/session.md)
