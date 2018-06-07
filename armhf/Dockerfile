FROM resin/raspberrypi3-alpine:3.6

ARG BUILD_DATE
ARG VERSION=latest

LABEL build_version="${VERSION}"
LABEL build_date="${BUILD_DATE}"
LABEL maintainer="kylemharding@gmail.com"

# allow building on x86
RUN [ "cross-build-start" ]

# set snapshot root
ENV SNAPSHOT_ROOT /snapshots

# install cron, ssh, and rsnapshot
RUN apk add --no-cache \
	curl \
	dcron \
	rsnapshot \
	openssh-client \
	tzdata

# copy src files
# copy src files
WORKDIR /usr/src/app
COPY start.sh crontab VERSION ./

# modify default config with desired settings
RUN sed -r \
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
	/etc/rsnapshot.conf.default > /usr/src/app/rsnapshot.conf

# install crontab schedule with a link
RUN rm /etc/crontabs/root \
	&& ln -s /usr/src/app/crontab /etc/crontabs/root

# create a volume in case mounting fails
VOLUME $SNAPSHOT_ROOT

# run start script on boot
CMD ["/bin/sh", "start.sh"]

# end cross build
RUN [ "cross-build-end" ]

