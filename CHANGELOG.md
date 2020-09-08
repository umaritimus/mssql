# Changelog

All notable changes to this project will be documented in this file.

## Release 0.9.7

**Added**

* Administration of Linked Servers
* Administration of Credentials and Proxies
* SQL Agent Operators
* SQL Agent Alerts

## Release 0.9.6

**Fixed**

* Update dependency definitions
* Resolved issues

## Release 0.9.5

**Changed**

* Improved documentation
* Fixed parameter hierarchy

## Release 0.9.1

**Added**

* Condition to indicate that the module only works on Windows

## Release 0.9.0

**Changed**

* Major rewrite of the installation routine using powershell dsc
module instead of the setup script.

## Release 0.5.0

**Added**

* Dependency on `puppetlabs-dsc` module for sql server configuration

## Release 0.4.2

**Fixed**

* Conditional source locations and improved error handling

**Added**

* Placeholder for config class

## Release 0.4.1

**Added**

* Capability to apply a cumulative patch

## Release 0.4.0

**Fixed**

* PDK 1.18 version dependency
* `inifile` module dependency

**Added**

* `unless` clause in sql server installation

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
