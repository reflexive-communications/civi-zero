# civicrm-zero

## Overview

This repo contains a zero config CiviCRM instance on Drupal 9.

## Pre-requirements

Civi-zero is installed on a LAMP stack. So basically we need a DataBase, webserver, PHP and some tools (`composer`, `phpunit`, `cv`).
Database and the user account for CiviCRM is considered part of the environment and not handled by this app.
Installing the rest of stack is possible by running `bin/prepare.sh`.

## Installation

1. Check out repo
1. Install & setup database (MySQL or MariaDB)
1. Create system user for DB (username, password); database is created later automatically.
1. Config installer
   1. Check `install.conf` for defaults
   1. Duplicate `install.conf` and rename to `install.local`
   1. Change relevant configs in `install.local`
1. Run `bin/prepare.sh`
