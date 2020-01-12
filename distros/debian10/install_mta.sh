#---------------------------------------------------------------------
# Function: InstallMTA
#    Install chosen MTA. Courier or Dovecot
#---------------------------------------------------------------------
InstallMTA() {
  CFG_MTA='dovecot'
  echo -n "Installing POP3/IMAP Mail server (Dovecot) and Mail signing (OpenDKIM, OpenDMARC)... ";
  apt_install dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd sudo dovecot-managesieved dovecot-sieve dovecot-antispam opendkim opendkim-tools opendmarc
  echo -e "[${green}DONE${NC}]\n"
}
