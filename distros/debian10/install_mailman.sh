#---------------------------------------------------------------------
# Function: InstallMailman
#    Install the Mailman list manager
#---------------------------------------------------------------------
InstallMailman() {
	echo -n "Installing Mailman... ";
	echo "mailman mailman/default_server_language select en" | debconf-set-selections
	echo "mailman mailman/site_languages  multiselect en" | debconf-set-selections
	echo "mailman mailman/create_site_list select " | debconf-set-selections
	apt_install mailman
	mmsitepass "${MMSITEPASS}"
	newlist -a  mailman "${MMLISTOWNER}" "${MMLISTPASS}" | grep "/var/lib/mailman" >> /etc/aliases
	newaliases
	ln -s /usr/lib/mailman/mail/mailman /usr/bin/mailman
	systemctl restart postfix.service
	systemctl enable mailman.service
	systemctl start mailman.service

	echo -e "[${green}DONE${NC}]\n"
}
