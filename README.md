# civicrm-zero

## Overview

This repo contains a zero config CiviCRM instance on Drupal 9.

## Pre-requirements

CiviCRM-zero is installed on a LAMP stack. So basically we need Linux, a DataBase, webserver, PHP and some tools (`composer`, `cv`).
Database and the  DB user account for CiviCRM is considered part of the environment and not handled by this app.
Installing the rest of stack is possible by running `bin/prepare.sh`.

Currently only Ubuntu is supported.

## Installation

1. Check out repo into a dir where you want to serve it
1. Install & setup database (MySQL or MariaDB)
1. Create system user for DB (username, password); database is created later automatically.
1. Config installer
   1. Check `install.conf` for defaults
   1. Duplicate `install.conf` and rename to `install.local`
   1. Change relevant configs in `install.local`
1. Run `bin/prepare.sh`
1. Run `bin/install.sh`, parameters:
   1. Install dir (the same dir as in the 1. step)
   1. DB user name
   1. DB user pass
   1. DB name
1. (Optional) Install extensions
   1. Download extension
   1. Run `bin/extension.sh`, parameters:
      1. Install dir (the same dir as in the 1. step)
      1. Extension dir
      1. Extension key (if key is the same as the dir name, this can be omitted)
