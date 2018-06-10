#!/bin/sh

rsnapshot_config="rsnapshot.conf"
crontab_schedule="crontab"

part_label="snapshots"
dev_path="$(blkid | grep "LABEL=\"${part_label}\"" | cut -d: -f1)"

# mount device with LABEL="snapshot" if it exists
if [ -n "${dev_path}" ]
then
	echo "mounting ${dev_path} onto ${SNAPSHOT_ROOT} ..."
	mount "${dev_path}" "${SNAPSHOT_ROOT}"
else
	echo "no devices with label '${part_label}' found!"
	exit 1
fi

# if rsnapshot.conf does not exist, create a new one from rsnapshot.conf.default
if [ ! -f "${rsnapshot_config}" ]
then
	echo "creating defaults rsnapshot config ..."
	sed -r \
		-e "s|^#?(snapshot_root\s+.+)$|snapshot_root\t$SNAPSHOT_ROOT/|" \
		-e "s/^#?(no_create_root\s+.+)$/no_create_root\t1/" \
		-e "s/^#?(cmd_ssh\s+.+)$/\1/" \
		-e "s/^#?(cmd_cp\s+.+)$/\1/" \
		-e "s/^#?(retain\s+(alpha|hourly)\s+.+)$/retain\talpha\t6/" \
		-e "s/^#?(retain\s+(beta|daily)\s+.+)$/retain\tbeta\t7/" \
		-e "s/^#?(retain\s+(gamma|weekly)\s+.+)$/retain\tgamma\t4/" \
		-e "s/^#?(retain\s+(delta|monthly)\s+.+)$/retain\tdelta\t3/" \
		-e "s/^#?(backup\s+.+)$/#\1/" \
		-e "s/^#?(backup_script\s+.+)$/#\1/" \
		/etc/rsnapshot.conf.default > "${rsnapshot_config}"
else
	sed -i '/#RSNAPSHOT_CONF_/d' "${rsnapshot_config}"
fi

# append RSNAPSHOT_CONF_* environment variables to rsnapshot.conf
echo "updating rsnapshot config ..."
printenv | grep "^RSNAPSHOT_CONF_" | while IFS== read -r var val
do
	echo "$val #$var" | sed -r 's/\s+/\t/g' | tee -a "${rsnapshot_config}"
done

# test rsnapshot config syntax
echo "checking rsnapshot config ..."
/usr/bin/rsnapshot -c "${rsnapshot_config}" configtest || exit 1

# print cron schedule in human readable format
echo "reading rsnapshot schedule ..."
cat "${crontab_schedule}" | grep -v '^\s*#' | grep -v '^\s*$' \
	| awk '{print "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression="$1"+"$2"+"$3"+"$4"+"$5"&locale=en-US"}' \
	| xargs curl -s | sed -r 's/\{"description":"([^"]+)"\}/\1\n/g'

# install crontab schedule with a link
rm /etc/crontabs/root
ln -s "${crontab_schedule}" /etc/crontabs/root

# stop cron if it is running
kill $(pidof crond)

# start dcron service
if [ "${INITSYSTEM}" != "on" ]
then
	# start dcron in foreground
	/usr/sbin/crond -f
else
	# start dcron with openrc
	rc-service dcron start
fi

