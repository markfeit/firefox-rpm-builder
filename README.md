# firefox-rpm-builder

The files in this directory download a copy of the latest Firefox
binary distribution for Linux and turns it into an RPM.

## Prerequisites

This requires installation of the `rpm-with-deps` and
`make-generic-rpm` packages from the [perfSONAR project's pScheduler
repository](https://github.com/perfsonar/pscheduler).

## Directions

Run `make`.

Once the process is completed, an RPM and SRPM will be available to
install.

Run `make clean` to remove build byproducts.
