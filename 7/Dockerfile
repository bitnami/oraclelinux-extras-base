FROM oraclelinux:7-slim

LABEL maintainer "Bitnami <containers@bitnami.com>"
ENV IMAGE_OS=ol-7

ENV BITNAMI_IMAGE_VERSION=7-r280

COPY rootfs /

# component installation requirements
RUN mkdir --parents /opt/bitnami
RUN yum-config-manager --enable ol7_developer_EPEL ol7_optional_latest && \
    yum upgrade -y && \
    install_packages tar gzip curl ca-certificates sudo procps-ng libaio-devel which
