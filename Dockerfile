FROM centos:7
ARG password="mypw"
ARG preinstall=" wget vim-enhanced tig gcc-c++ make "
ARG db_wait_sec=10
ENV DB_WAIT_SEC "${db_wait_sec}"
RUN yum install -y sudo git which python epel-release
SHELL ["/bin/bash","-c"]
RUN yum install -y $preinstall
COPY irods_setup.bash /
RUN chmod +x /irods_setup.bash
RUN echo "PREINSTALL='${preinstall}'" >> /irods_setup.bash
RUN echo "test >/dev/null 2>&1 \"\$DB_WAIT_SEC\" -gt 0 || DB_WAIT_SEC="${db_wait_sec} >> /irods_setup.bash
RUN useradd -m -s/bin/bash cen7
RUN usermod -aG wheel cen7
RUN chpasswd <<<"cen7:${password}"
COPY do_install.sh /
COPY rsyslogd_conf.patch /
RUN yum install -y patch rsyslog
RUN patch /etc/rsyslog.conf < /rsyslogd_conf.patch
RUN chmod +x /do_install.sh
