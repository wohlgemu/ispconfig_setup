#---------------------------------------------------------------------
# Function: InstallAntiVirus
#    Install Amavisd, Spamassassin, ClamAV
#---------------------------------------------------------------------
InstallAntiVirus() {
  if [ "$CFG_ANTISPAM" == "amavisd" ]; then
    echo -n "Installing Antispam utilities (Amavisd-new), Spam filtering (SpamAssassin) and Greylisting (Postgrey) (This may take awhile. Do not abort it...) "
    apt_install amavisd-new spamassassin postgrey
    sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
    echo "use strict;" > /etc/amavis/conf.d/05-node_id
    echo "chomp(\$myhostname = \`hostname --fqdn\`);" >> /etc/amavis/conf.d/05-node_id
    echo "\$myhostname = \"$CFG_HOSTNAME_FQDN\";" >> /etc/amavis/conf.d/05-node_id
    echo "1;" >> /etc/amavis/conf.d/05-node_id
    echo "$CFG_HOSTNAME_FQDN" > /etc/mailname
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Stopping SpamAssassin... "
    systemctl  stop spamassassin
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Disabling SpamAssassin... "
    hide_output systemctl disable spamassassin
    echo -e "[${green}DONE${NC}]\n"
  elif [ "$CFG_ANTISPAM" == "rspamd" ]; then
    echo -n "Installing Antispam utilities (Rspamd) (This may take awhile. Do not abort it...) "
    apt_install redis-server lsb-release
    if [[ "$(which named)" == "" ]]; then
	apt_install unbound
    fi
    CODENAME=`lsb_release -c -s`
    curl https://rspamd.com/apt-stable/gpg.key | apt-key add -
    echo "deb [arch=amd64] http://rspamd.com/apt-stable/ $CODENAME main" > /etc/apt/sources.list.d/rspamd.list
    echo "deb-src [arch=amd64] http://rspamd.com/apt-stable/ $CODENAME main" >> /etc/apt/sources.list.d/rspamd.list
    hide_output apt-get update
    apt_install rspamd clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip \
         apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libclamunrar9 libio-string-perl libio-socket-ssl-perl libnet-ident-perl \
         zip libnet-dns-perl libdbd-mysql-perl unrar-free unp lz4 liblz4-tool unp
    echo 'servers = "127.0.0.1";' > /etc/rspamd/local.d/redis.conf
    echo "nrows = 2500;" > /etc/rspamd/local.d/history_redis.conf
    echo "compress = true;" >> /etc/rspamd/local.d/history_redis.conf
    echo "subject_privacy = false;" >> /etc/rspamd/local.d/history_redis.conf
    echo "$CFG_HOSTNAME_FQDN" > /etc/mailname
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting Rspamd... "
    systemctl restart rspamd
    echo -e "[${green}DONE${NC}]\n"
  fi

  echo -n "Installing Antivirus utilities (ClamAV) ... (This may take awhile. Do not abort it...) "
  apt_install clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract p7zip p7zip-full unrar lrzip \
         apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl \
         zip libnet-dns-perl libdbd-mysql-perl unrar-free unp lz4 liblz4-tool unp
  sed -i "s/AllowSupplementaryGroups false/AllowSupplementaryGroups true/" /etc/clamav/clamd.conf
  if [ "$CFG_AVUPDATE" == "yes" ]; then
	echo -n "Updating Freshclam Antivirus Database. Please Wait... "
	freshclam
	echo -e "[${green}DONE${NC}]\n"
  fi
  echo -n "Restarting ClamAV... "
  systemctl restart clamav-daemon
  echo -e "[${green}DONE${NC}]\n"

}
