# docker-ubuntu2204

Ubuntu 22.04 Docker image for testing Ansible roles with Molecule.

## Docker Pull Command

```sh
docker pull  <image>
```

## How to Build

This image is built on Docker Hub automatically any time the upstream OS image is rebuilt, and any time a commit is made
or merged to the `main` branch. But if you need to build the image on your own locally, do the following:

1. Install [docker]
2. Clone the repo, `git clone <repo>`
3. `cd` into the directory
4. Run `docker build --tag noders/ansible-docker-2202 .`

## How to Use

### Within Molecule Scenario

- Add the following code to your molecule scenario file, e.g. `molecule/default/molecule.yml`.

  ```yaml
  platforms:
    - name: ${MOLECULE_NAME:-instance}
      image: ${MOLECULE_IMAGE:-trfore/docker-ubuntu2204-systemd}
      command: ${MOLECULE_COMMAND:-""}
      tmpfs:
        - /run
        - /tmp
      volumes:
        - /sys/fs/cgroup:/sys/fs/cgroup:rw
      cgroupns_mode: host
      privileged: true
      pre_build_image: true
  ```

### Interactively Using Docker

- Install [docker]
- Build an image locally (see above) or pull from Docker Hub: `docker pull trfore/docker-ubuntu2204-systemd:latest`
- **On Docker with Cgroup V1 (e.g. Ubuntu 20.04)**, run a container from the image:

  ```sh
  docker run -d -it --name ubuntu2204-systemd --privileged --cgroupns=host --tmpfs=/run --tmpfs=/tmp --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro trfore/docker-ubuntu2204-systemd:latest
  ```

- **On Docker with Cgroup V2 (e.g. Ubuntu 22.04)**, run a container from the image:

  ```sh
  docker run -d -it --name ubuntu2204-systemd --privileged --cgroupns=host --tmpfs=/run --tmpfs=/tmp --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw trfore/docker-ubuntu2204-systemd:latest
  ```

- Use it, ex:

  ```sh
  docker exec -it ubuntu2204-systemd /bin/bash
  ```

### Using Podman

- Podman defaults to running containers in systemd mode, `--systemd=true`, and will mount the required tmpfs and cgroup
  filesystem. See [Podman Docs: Commands `run --systemd`] for details.

  ```sh
  podman run -d -it --name ubuntu2204-systemd docker.io/trfore/docker-ubuntu2204-systemd:latest
  ```
