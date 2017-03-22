# base image
FROM fedora:latest

# note: can't run updates with enterprise red hat; mebbe there's a developer image avail?
#FROM registry.access.redhat.com/rhel7/rhel

MAINTAINER Clint Conklin <clint@creativengine.com>

# update the image; NOTE: fedora uses dnf in lieu of yum
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
EXPOSE 80 443

# copy over our shell script, make it executable, then make it go
ADD go.sh /usr/local/bin/go.sh
RUN chmod +x /usr/local/bin/go.sh
CMD /bin/bash -c "/usr/local/bin/go.sh"


