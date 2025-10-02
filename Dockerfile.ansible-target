ARG BASEOS_DIGEST
FROM docker.io/library/ubuntu:22.04${BASEOS_DIGEST:-}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN set -eux; \
  apt-get update -o Acquire::Retries=3; \
  apt-get install -y apt-utils tzdata dialog locales; \
  apt-get install -y \
    ubuntu-standard \
    ubuntu-server \
    software-properties-common \
    rsyslog systemd cron sudo \
    iproute2 \
    openssh-server \
    make build-essential gcc git jq chrony lz4 tmux tree bc acl libssl-dev; \
  # Ensure locale file exists and generate en_US.UTF-8
  if [ ! -f /etc/locale.gen ]; then \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen; \
  elif ! grep -qE '^\s*en_US\.UTF-8 UTF-8' /etc/locale.gen; then \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  fi; \
  locale-gen; \
  # SSH + systemd prep
  mkdir -p /var/run/sshd; \
  ln -sf /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service; \
  # rsyslog: disable imklog (harmless if not present)
  sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf || true; \
  # Remove units that break in containers (ignore if missing)
  rm -f /lib/systemd/system/systemd*udev* || true; \
  rm -f /lib/systemd/system/getty.target || true; \
  # Clean
  rm -rf /var/lib/apt/lists/*

EXPOSE 22
STOPSIGNAL SIGRTMIN+3
VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]