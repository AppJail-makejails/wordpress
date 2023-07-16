#!/bin/sh

if appjail cmd jexec "${APPJAIL_JAILNAME}" which -s php; then
	php_version=`echo "<?php echo phpversion();?>" | appjail cmd jexec "${APPJAIL_JAILNAME}" php`
	php_major=`echo "${php_version}" | cut -d. -f1`
	php_minor=`echo "${php_version}" | cut -d. -f2`
	php_version="${php_major}${php_minor}"
elif appjail cmd jexec "${APPJAIL_JAILNAME}" [ -d "/usr/local/www/apache24/data" ]; then
	php_version=`appjail pkg jail "${APPJAIL_JAILNAME}" info -x '^mod_php.+' | head -1 | sed -Ee 's/mod_php([0-9][0-9]).+/\1/'`

	if [ -z "${php_version}" ]; then
		echo "Cannot get the PHP version." >&2
		exit 1
	fi
else
	echo "Cannot get the PHP version." >&2
	exit 1
fi

appjail pkg jail "${APPJAIL_JAILNAME}" install -y \
	`cat pkgs-php.txt | sed -Ee "s/(.+)/php${php_version}-\1/"`
