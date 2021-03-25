FROM centos:7
ARG password="mypw"
RUN yum install -y sudo git which python epel-release
SHELL ["/bin/bash","-c"]
COPY irods_setup.bash /
RUN chmod +x /irods_setup.bash
COPY preinstall.txt /tmp/
COPY db_wait_sec.sh /tmp/
RUN yum install -y $(cat /tmp/preinstall.txt) && rm -f /tmp/preinstall.txt
RUN useradd -m -s/bin/bash cen7
RUN usermod -aG wheel cen7
RUN chpasswd <<<"cen7:${password}"
COPY do_install.sh /
RUN chmod +x /do_install.sh
