# syntax=docker/dockerfile:1

FROM fedora AS sandbox

WORKDIR /sandbox

COPY default_packages.txt /default_packages.txt

RUN dnf upgrade -y && \
  dnf install -y $(tr '\n' ' ' </default_packages.txt) && \
  git lfs install && \
  tldr --update
