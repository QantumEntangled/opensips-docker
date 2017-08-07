FROM ubuntu:14.04
MAINTAINER Mikel Farley <Mikel@Farley.pro>

# set version of OpenSIPs to install
ARG VERSION=2.3

# add repo for OpenSIPs and install it
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 049AD65B \
	&& echo "deb http://apt.opensips.org trusty $VERSION-releases" >>/etc/apt/sources.list \
	&& apt update; apt upgrade -y \
	&& apt install -y opensips \
	&& touch /var/log/opensips.log

# Copy in the startup script and make it executable
COPY run.sh /run.sh
RUN chmod 777 /run.sh 



# Download and install OpenSIPs Control Panel
RUN apt install -y debconf-utils \
	&& echo "mysql-server mysql-server/root_password password mysql" | sudo debconf-set-selections \
	&& echo "mysql-server mysql-server/root_password_again password mysql" | sudo debconf-set-selections \
	&& apt install -y apache2 libapache2-mod-php5 php5-curl php5 php5-gd php5-mysql php5-xmlrpc php-pear php5-cli git mysql-server iptables opensips-mysql-module expect

COPY apache2-opensips.conf /etc/apache2/sites-available/opensips.conf
COPY etc-opensips/opensipsctlrc /etc/opensips/opensipsctlrc
COPY dbcreate.sh /root/dbcreate.sh

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
	&& a2dissite 000-default.conf \
	&& a2ensite opensips.conf \
	&& pear install MDB2 \
	&& pear install MDB2#mysql \
	&& pear install log

RUN cd /var/www \
	&& git clone https://github.com/OpenSIPS/opensips-cp \
	&& chown -R www-data:www-data /var/www/opensips-cp/ \
	&& cd /var/www/opensips-cp/

RUN service mysql start \
	&& expect -f /root/dbcreate.sh \
	&& mysql --password=mysql -e "GRANT ALL PRIVILEGES ON opensips.* TO opensips@localhost IDENTIFIED BY 'opensipsrw'" \
	&& mysql --password=mysql -Dopensips < /var/www/opensips-cp/config/tools/admin/add_admin/ocp_admin_privileges.mysql \
	&& mysql --password=mysql -Dopensips -e "INSERT INTO ocp_admin_privileges (username,password,ha1,available_tools,permissions) values ('admin','admin',md5('admin:admin'),'all','all');" \
	&& mysql --password=mysql -Dopensips < /var/www/opensips-cp/config/tools/system/smonitor/tables.mysql \
	&& cp /var/www/opensips-cp/config/tools/system/smonitor/opensips_stats_cron /etc/cron.d/



# Set public ports and startup script
EXPOSE 80 443 5060
CMD ["/run.sh"]
