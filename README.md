# civicrm-zero

[![build](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/build.yml/badge.svg)](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/build.yml)
[![tests](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/tests.yml/badge.svg)](https://github.com/reflexive-communications/civicrm-zero/actions/workflows/tests.yml)

## Overview

This repo contains a zero config CiviCRM instance on Drupal 9.

**This project is intended for development/CI environments, please don't use in production!**

## Pre-requirements

CiviCRM-zero is installed on a LAMP stack. So basically we need Linux, a DataBase, webserver, PHP and some tools (`composer`, `cv`).
Installing these dependencies is possible by running `bin/prepare.sh`.
We use MariaDB as database, and Apache as webserver with PHP-FPM.

Currently only Ubuntu is supported.

## Installation

1. Check out repo
1. Config installer
    1. Check `cfg/install.cfg` for defaults
    1. Duplicate `cfg/install.cfg` and rename to `cfg/install.local`
    1. Change relevant configs in `cfg/install.local`
1. Run `bin/prepare.sh`
1. Run `bin/install.sh`, usage:

    ```
    install.sh INSTALL_DIR [FLAGS]...

    INSTALL_DIR:    Installation dir, where to install CiviCRM
    FLAGS:          Optional flags:
                      --sample:   load randomly generated sample data into Civi after install
    ```

1. (Optional) Install extensions

    1. Download extension
    1. Run `bin/extension.sh`, usage:

        ```
        extension.sh INSTALL_DIR EXTENSION_DIR EXTENSION_KEY

        INSTALL_DIR:         Installation dir (the same dir where you installed in step #4)
        EXTENSION_DIR:       Dir that contains the extension
        EXTENSION_KEY:       Extension key (if key is the same as the dir name, this can be omitted)
        ```

**Notes**

-   You can run `install.sh` multiple times, it will always create a fresh install.
    Only config & local files (`web/sites/default/files`) are deleted and the DB get purged, `vendor/` dir and extensions are kept intact.
-   To quickly reinstall CiviCRM, you can use `bin/reinstall.sh`.
    This keeps _all_ files (`vendor/`, config files, logs, etc.) and Drupal tables in the DB, only Civi tables are purged and reinitialized.
    Parameters are the same as `install.sh`.

## Usage

After installation, CiviCRM is ready to use (mostly in a CI environment).
However if you plan to use it for development, there are several utility scripts to help work:

-   `bin/init-test-DB.sh`: Initialize test DB. It's possible to use a separate DB for testing so unit tests won't mess up your database.

    ```
    init-test-DB.sh INSTALL_DIR

    INSTALL_DIR:    Installation dir (the same dir where you installed in step #4)
    ```

-   `bin/tests.sh`: To run said unit tests on extensions.

    ```
    tests.sh INSTALL_DIR EXTENSION_DIR

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4)
    EXTENSION_DIR:       Extension base dir (same as in 'extension.sh')
    ```

-   `bin/clear-cache.sh`: Clears Drupal & CiviCRM caches.

    ```
    clear-cache.sh INSTALL_DIR

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4)
    ```
