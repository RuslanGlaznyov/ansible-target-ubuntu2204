ARG BASEOS_DIGEST
FROM docker.io/library/ubuntu:22.04${BASEOS_DIGEST:-}

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Install server-style baseline like a Hetzner VM:
# - ubuntu-standard + ubuntu-server (batteries included)
# - your additional packages (ensures they are present even if metas change)
RUN apt-get update \
 && apt-get install -y apt-utils tzdata dialog \
 && apt-get install -y \
      ubuntu-standard \
      ubuntu-server \
      software-properties-common \
      rsyslog systemd systemd-cron sudo \
      iproute2 \
      openssh-server \
      make build-essential gcc git jq chrony lz4 tmux tree bc acl libssl-dev \
 # Locale example (optional): enable en_US.UTF-8 so manpages render nicely
 && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen \
 # Prepare SSH + systemd
 && mkdir -p /var/run/sshd \
 && ln -sf /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service \
 # rsyslog: disable imklog (as you had)
 && sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf \
 # Remove udev/getty units (not needed in containers)
 && rm -f /lib/systemd/system/systemd*udev* \
 && rm -f /lib/systemd/system/getty.target \
 # Clean apt cache (keep manpages/docs!)
 && rm -rf /var/lib/apt/lists/*

# (Optional) SSH hardening — leave commented if you want defaults
# RUN sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
#  && sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22
STOPSIGNAL SIGRTMIN+3

# systemd cgroup support
VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]