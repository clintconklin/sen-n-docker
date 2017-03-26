# base image
FROM fedora:latest

# note: can't run updates with enterprise red hat; mebbe there's a developer image avail?
#FROM registry.access.redhat.com/rhel7/rhel

MAINTAINER Your Mom <your@mom.com>

# update the image
RUN dnf update -y; dnf clean all

# install apache
RUN dnf install -y httpd; dnf clean all

# install git
RUN dnf install -y git-all; dnf clean all

# install node & npm
RUN dnf install nodejs npm -y; dnf clean all

# uncomment if you need to run 'which' in the image
#RUN dnf install which -y; dnf clean all

# copy over our sample hapi app
#COPY ./src /opt/src

# clone our repo
RUN git clone https://github.com/clintconklin/docker-hapi-dev.git /opt/src/

# run npm install
RUN cd /opt/src; npm install

# use this for standalone node
#EXPOSE 3000
#CMD ["node", "/opt/src/index.js"]

# set up our reverse proxy
COPY proxy.conf /etc/httpd/conf/proxy.conf
RUN cat /etc/httpd/conf/proxy.conf >> /etc/httpd/conf/httpd.conf

# open ports
EXPOSE 8080 443

# openshift security model runs under a random unid, make httpd/run and httpd/logs world-writeable
RUN chmod -R a+rwx /etc/httpd/run
RUN chmod -R a+rwx /etc/httpd/logs

# not sure why this only happens on minishift, but there ya have it
RUN chmod -R a+rwx /run/httpd

# httpd -> 8080
RUN sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd.conf

# copy over our shell script, make it executable, then make it go
ADD go.sh /usr/local/bin/go.sh
RUN chmod +x /usr/local/bin/go.sh
CMD /bin/bash -c "/usr/local/bin/go.sh"
