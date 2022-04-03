# civicrm-zero

## Overview

This repo contains a zero config CiviCRM instance on Drupal 9.

## Pre-requirements

Civi-zero is installed on a LAMP stack. So basically we need a DataBase, webserver and PHP. Availability of this is
considered the environment thus not handled by this app.

**Requirements**

- Ubuntu
- Apache
    - modules:
        - actions
        - expires
        - headers
        - rewrite
- DB (MySQL or MariaDB)
    - system user account for CiviCRM with
      privileges: `SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES,EXECUTE,CREATE ROUTINE,ALTER ROUTINE,TRIGGER`
- PHP
    - version: `7.4`
    - extensions:
        - bcmath
        - bz2
        - cli
        - common
        - curl
        - fpm
        - gd
        - imagick
        - imap
        - intl
        - json
        - ldap
        - mbstring
        - mysql
        - opcache
        - soap
        - xdebug
        - xml
        - zip
    - tools:
      - composer v2
      - phpunit8

## Installation

1. Check out repo
1. Run `composer install`
1. Install Drupal
1. Install CiviCRM
1. Config
