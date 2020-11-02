FROM httpd:2.4.41

# Credits to Just van den Broecke for providing first versions
LABEL original_developer="Just van den Broecke <https://github.com/justb4>" \
	maintainer="Valentino Lauciani <vlauciani@gmail.com>"

ARG GEOIP_PACKAGES="libgeo-ipfree-perl libnet-ip-perl"

RUN \
	apt-get update \
	&& apt-get -yy install vim awstats gettext-base libapache2-mod-perl2 ${GEOIP_PACKAGES} supervisor cron \
	&& echo 'Include conf/awstats_httpd.conf' >> /usr/local/apache2/conf/httpd.conf  \
	&& mkdir /var/www && mv /usr/share/awstats/icon /var/www/icons && chown -R www-data:www-data /var/www \
	&& mkdir -p /aw-setup.d && mkdir -p /aw-update.d \
    && apt-get clean && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Configurations, some are templates to be substituted with env vars
ADD confs/awstats_env.conf confs/awstats_env.cron /etc/awstats/
ADD confs/awstats_httpd.conf /usr/local/apache2/conf/
ADD confs/supervisord.conf /etc/
ADD scripts/*.sh  /usr/local/bin/

# Default env vars
ENV \
	AWSTATS_CONF_DIR="/etc/awstats" \
	AWSTATS_SITES_DIR="/etc/awstats/sites" \
	AWSTATS_CRON_SCHEDULE="*/10 * * * *" \
	AWSTATS_PATH_PREFIX="" \
	AWSTATS_CONF_LOGFILE="/var/local/log/access.log" \
	AWSTATS_CONF_LOGFORMAT="%host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot" \
	AWSTATS_CONF_SITEDOMAIN="mydomain.com" \
	AWSTATS_CONF_HOSTALIASES="localhost 127.0.0.1 REGEX[^.*$]" \
	AWSTATS_CONF_DEBUGMESSAGES="0" \
	AWSTATS_CONF_DNSLOOKUP="1"

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
