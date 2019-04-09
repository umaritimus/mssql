# Changelog

All notable changes to this project will be documented in this file.

## Release 0.4.0

**Breaking Changes**

* Minimum puppet version increased to 5.0.0
* PDK version set to 1.10.0
* `mssql::client::cli` class replaced `mssql::client::cli::sqlcmd` defined type

**Added**

* Functionality to execute scripts
* Instructions for pdk installation

## Release 0.3.2

**Fixed**

* Minor documentation grammar fixups

## Release 0.3.1

**Fixed**

* Links to CHANGELOG and CONTRIBUTING
* Minor documentation clarifications

## Release 0.3.0

**Added**

* Installation of Microsoft SQL Server

## Release 0.2.1

**Fixed**

* Instructions for installing SQL Server Command Line Utilities were not clear enough

## Release 0.2.0

**Added**

* Installation of SQL Server Command Line Utilities
* Changelog references

**Fixed**

* SQL Server ODBC Driver defaults that fixes `expects a value for parameter` error in case module-level default values are not specified

## Release 0.1.0

**Added**

* Installation of SQL Server ODBC Driver
