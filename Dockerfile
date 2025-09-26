ARG BASEOS_DIGEST
FROM docker.io/library/ubuntu:22.04${BASEOS_DIGEST:-}

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update \
 && apt-get install -y apt-utils tzdata dialog \
 # Core “server-like” bundles and your extras
 && apt-get install -y \
      ubuntu-standard \
      software-properties-common \
      rsyslog systemd cron sudo \
      iproute2 \
      openssh-server \
      make build-essential gcc git jq chrony lz4 tmux tree bc acl libssl-dev \
 # locale (optional)
 && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen \
 # SSH + systemd prep
 && mkdir -p /var/run/sshd \
 && ln -sf /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service \
 # rsyslog: disable imklog
 && sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf \
 # remove units that break in containers
 && rm -f /lib/systemd/system/systemd*udev* \
 && rm -f /lib/systemd/system/getty.target \
 # clean
 && rm -rf /var/lib/apt/lists/*

EXPOSE 22
STOPSIGNAL SIGRTMIN+3
VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]