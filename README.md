# civi-zero

[![Build](https://github.com/reflexive-communications/civi-zero/actions/workflows/build.yml/badge.svg)](https://github.com/reflexive-communications/civi-zero/actions/workflows/build.yml)
[![Shell](https://github.com/reflexive-communications/civi-zero/actions/workflows/shell.yml/badge.svg)](https://github.com/reflexive-communications/civi-zero/actions/workflows/shell.yml)

## Overview

This repo contains a zero config CiviCRM instance on Drupal.

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
    1. Duplicate `cfg/install.cfg` and rename to `cfg/install.local.cfg`
    1. Change relevant configs in `cfg/install.local.cfg`
1. Run `bin/prepare.sh`
1. Run `bin/install.sh`, usage:

    ```
    install.sh [INSTALL_DIR] [FLAGS]...

    INSTALL_DIR:    Installation dir, where to install CiviCRM.
                    Defaults to civi-zero project dir.
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

-   You can install Civi in civi-zero project dir also, installed CiviCRM directories (`vendor/`, `web/`) are ignored by git, it won't interfere with civi-zero.
-   You can run `install.sh` multiple times, it will always create a fresh install.
    Only config & local files (`web/sites/default/files`) are deleted and the DataBase is purged, `vendor/` dir and extension files are kept intact.
-   To quickly reinstall CiviCRM, you can use `bin/reinstall.sh`.
    This keeps _all_ files (`vendor/`, config files, logs, etc.) and Drupal tables in the DB, only Civi tables are purged and reinitialized.
    Parameters are the same as `install.sh`.
-   For development the `--sample` flag on `install.sh` can be very useful as it fills the DB with some data.

## Usage

After installation, CiviCRM is ready to use (mostly in a CI environment).
However if you plan to use it for development, there are several utility scripts to help work:

-   `bin/dev-config.sh`: Configure CiviCRM for development. Install some development tools.

    ```
    dev-config.sh [INSTALL_DIR]

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4).
                         Defaults to civi-zero project dir.
    ```

-   `bin/init-test-DB.sh`: Initialize test DB. It's possible to use a separate DB for testing so unit tests won't mess up your database.

    ```
    init-test-DB.sh [INSTALL_DIR]

    INSTALL_DIR:    Installation dir (the same dir where you installed in step #4).
                    Defaults to civi-zero project dir.
    ```

-   `bin/tests.sh`: To run said unit tests on extensions.

    ```
    tests.sh INSTALL_DIR EXTENSION_DIR

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4)
    EXTENSION_DIR:       Extension dir (where the extension is installed)
    ```

-   `bin/clear-cache.sh`: Clears Drupal & CiviCRM caches.

    ```
    clear-cache.sh [INSTALL_DIR]

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4).
                         Defaults to civi-zero project dir.
    ```

-   `bin/set-perm.sh`: Set file permissions.

    ```
    set-perm.sh [INSTALL_DIR]

    INSTALL_DIR:         Installation dir (the same dir where you installed in step #4).
                         Defaults to civi-zero project dir.
    ```
