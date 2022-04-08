# civicrm-zero

[![build](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/ci-composer.yml/badge.svg)](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/ci-composer.yml)
[![CI](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/ci-bin.yml/badge.svg)](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/ci-bin.yml)

## Overview

This repo contains a zero config CiviCRM instance on Drupal 9.

## Pre-requirements

CiviCRM-zero is installed on a LAMP stack. So basically we need Linux, a DataBase, webserver, PHP and some tools (`composer`, `cv`).
Installing these dependencies is possible by running `bin/prepare.sh`.
We use MariaDB as database, and Apache as webserver with PHP-FPM.

Currently only Ubuntu is supported.

## Installation

1. Check out repo into a dir where you want to serve it
1. Config installer
   1. Check `cfg/install.cfg` for defaults
   1. Duplicate `cfg/install.cfg` and rename to `cfg/install.local`
   1. Change relevant configs in `cfg/install.local`
1. Run `bin/prepare.sh`
1. Run `bin/install.sh`, parameters:
   1. Install dir (the same dir as in the 1. step)
1. (Optional) Install extensions
   1. Download extension
   1. Run `bin/extension.sh`, parameters:
      1. Install dir (the same dir as in the 1. step)
      1. Extension dir
      1. Extension key (if key is the same as the dir name, this can be omitted)
1. (Optional) Run unit test on extensions: run `bin/tests.sh`, params:
   1. Install dir (the same dir as in the 1. step)
   1. Extension name
