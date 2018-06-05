# docker-rsnapshot

[rsnapshot](http://rsnapshot.org/) docker images

## Build

```bash
# build for rpi3
make build-rpi3
```

## Deploy

```bash
# deploy on rpi3
docker run --name rsnapshot \
--privileged \
-e TZ=America/Toronto \
klutchell/rsnapshot:rpi3-latest
```

## Parameters

* `-e TZ=America/Toronto` - local timezone

## Usage

* format a storage device with `LABEL=snapshots`

```bash
# fdisk example
fdisk /dev/sda
d
n
w
mkfs.ext4 /dev/sda1 -L snapshots
```

* specify backup points by setting environment variables
prefixed with `RSNAPSHOT_CONF_`

```bash
# deploy on rpi3
docker run --name rsnapshot \
--privileged \
-e TZ=America/Toronto \
-e RSNAPSHOT_CONF_local1="backup /home/ localhost/" \
-e RSNAPSHOT_CONF_local2="backup /etc/ localhost/" \
-e RSNAPSHOT_CONF_local3="backup /usr/local/ localhost/" \
-e RSNAPSHOT_CONF_pi="backup pi@192.168.1.101:/home/ 192.168.1.101/" \
-e RSNAPSHOT_CONF_ex1="exclude media/movies" \
-e RSNAPSHOT_CONF_ex2="exclude media/tv" \
klutchell/rsnapshot:rpi3-latest
```

* adjust the schedules in `/usr/src/app/crontab`

```
# defaults:
alpha:	Every 4 hours
beta:	At 03:30 AM
gamma:	At 03:00 AM, only on Monday
delta:	At 02:30 AM, on day 1 of the month
```

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

* https://github.com/resin-io-playground/cron-example
