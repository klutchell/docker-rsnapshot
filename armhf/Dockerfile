FROM resin/raspberrypi3-alpine:3.6

ARG BUILD_DATE
ARG VERSION=latest

LABEL build_version="${VERSION}"
LABEL build_date="${BUILD_DATE}"
LABEL maintainer="kylemharding@gmail.com"

# allow building on x86
RUN [ "cross-build-start" ]

# enable openrc
ENV INITSYSTEM on

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
WORKDIR /usr/src/app
COPY start.sh crontab VERSION ./

# create a volume in case mounting fails
VOLUME $SNAPSHOT_ROOT

# run start script on boot
CMD ["/bin/sh", "start.sh"]

# end cross build
RUN [ "cross-build-end" ]

