# STAGE 0: use base image from Docker Hub and upgrade the existing packages
FROM nvidia/cuda:11.8.0-base-ubuntu22.04 AS base

RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y &&\
  rm -rf /var/lib/apt/lists/*

# STAGE 1: copy contents of the original base image to a new image so we don't have overlapping files in layers
FROM scratch
COPY --from=base / /
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

# add non-root user (smirest)
RUN groupadd -g 514 smirest &&\
  useradd -u 514 -g 514 -d /home/smirest smirest

# cache busting
ARG SMIREST_VER

# install dependencies and get the jar from the latest release
RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq openjdk-11-jre wget &&\
  SMIREST_VER=$(if [ -z "${SMIREST_VER}" ]; then wget -q -O - https://api.github.com/repos/lampaa/nvidia-smi-rest/releases/latest | jq -r .tag_name; else echo "${SMIREST_VER}"; fi) &&\
  mkdir /opt/smirest &&\
  wget -nv "https://github.com/lampaa/nvidia-smi-rest/releases/download/${SMIREST_VER}/smirest-$(echo "${SMIREST_VER}" | awk -F 'v' '{print $2}').jar" -O /opt/smirest/smirest.jar &&\
  cd /tmp &&\
  wget -nv "https://github.com/lampaa/nvidia-smi-rest/archive/refs/tags/${SMIREST_VER}.tar.gz" -O "${SMIREST_VER}.tar.gz" &&\
  tar xvf "${SMIREST_VER}.tar.gz" "nvidia-smi-rest-$(echo "${SMIREST_VER}" | awk -F 'v' '{print $2}')/resources" &&\
  mv "nvidia-smi-rest-$(echo "${SMIREST_VER}" | awk -F 'v' '{print $2}')/resources" /opt/smirest/ &&\
  rm -rf "${SMIREST_VER}.tar.gz" "nvidia-smi-rest-$(echo "${SMIREST_VER}" | awk -F 'v' '{print $2}')" &&\
  chown -R smirest:smirest /opt/smirest &&\
  apt-get purge -y jq wget &&\
  apt-get autoremove -y &&\
  rm -rf /var/lib/apt/lists/*

USER smirest
WORKDIR /opt/smirest
EXPOSE 8176
CMD ["java","-jar", "/opt/smirest/smirest.jar"]
