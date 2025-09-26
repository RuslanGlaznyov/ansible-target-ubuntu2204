ARG BASEOS_DIGEST
FROM docker.io/library/ubuntu:22.04${BASEOS_DIGEST:-}

ENV DEBIAN_FRONTEND=noninteractive

# Base packages + SSH + your toolchain
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      software-properties-common \
      rsyslog systemd systemd-cron sudo \
      iproute2 \
      openssh-server \
      make build-essential gcc git jq chrony lz4 tmux tree bc acl libssl-dev curl cat vim \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/share/doc /usr/share/man \
 && apt-get clean

# rsyslog: disable imklog (as you had)
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Remove udev/getty services (known issues in containers)
# https://bugzilla.redhat.com/show_bug.cgi?id=1046469#c11
# https://github.com/ansible-community/molecule/issues/1104
RUN rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

# --- SSH setup ---
# Make sure runtime dir exists; enable ssh at boot (systemd-friendly)
RUN mkdir -p /var/run/sshd \
 # systemctl may not be PID 1 during build; create wants/ symlink as a fallback
 && ln -sf /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service

# (Optional) Harden SSH a bit; comment these lines if you want defaults
# RUN sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
#  && sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22

STOPSIGNAL SIGRTMIN+3

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]