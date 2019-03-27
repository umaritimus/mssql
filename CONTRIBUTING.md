# Creating a puppet module

## Develop a module

1. Create module

    ```cmd
    pdk new module mssql
    cd .\mssql
    ```

1. Create classes

    ```cmd
    pdk new class mssql::client
    pdk new class mssql::client::odbc
    pdk new defined_type mssql::client::odbc::driver
    ```

1. .\mssql\client\odbc\driver.pp

    ```puppet
    define mssql::client::odbc::driver(
        String $driver = $mssql::client::odbc::drivername,
        String $ensure = $mssql::client::odbc::driverensure,
        String $source = $mssql::client::odbc::driversource,
    ) {

        if ($facts['operatingsystem'] == 'windows') {

            package { "Microsoft ${driver}" :
            ensure          => $ensure,
            source          => $source,
            install_options => [ { 'ADDLOCAL' => 'All' }, { 'IACCEPTMSODBCSQLLICENSETERMS' => 'YES' } ],
            provider        => 'windows',
            }

        } else {

            warn ('Only windows operating system is currently supported, please somebody add `yum`|`apt` sections')

        }
    }
    ```

1. .\mssql\client\odbc.pp

    ```puppet
    class mssql::client::odbc (
        Enum['ODBC Driver 13 for SQL Server','ODBC Driver 17 for SQL Server'] $drivername,
        String $driversource,
        String $driverensure = 'present',
    ) {

        mssql::client::odbc::driver { $drivername :
            driver => $drivername,
            ensure => $driverensure,
            source => $driversource,
        }
    }
    ```

1. .\mssql\client.pp

    ```puppet
    class mssql::client (
        String $ensure = 'absent'
    ) {
        include ::mssql::client::odbc
    }
    ```

## Add module-level data

1. .\mssql\hiera.yaml

    ```yaml
    ---
    version: 5
    defaults:
    datadir: data
    data_hash: yaml_data
    hierarchy:
    - name: "common"
        path: "common.yaml"
    ```

1. .\mssql\data\common.yaml

    ```yaml
    ---
    mssql::client::ensure: 'absent'
    mssql::client::odbc::drivername: 'ODBC Driver 17 for SQL Server'
    mssql::client::odbc::driversource: 'c:/temp/msodbcsql_17.3.1.1_x64.msi'
    mssql::client::odbc::driverensure: "%{lookup('mssql::client::ensure')}"
    ```

## Add environment-level data

1. ...somewhere in environment hiera

    ```yaml
    ---
    ...
    mssql::client::ensure: 'present'
    mssql::client::odbc::drivername: 'ODBC Driver 17 for SQL Server'
    mssql::client::odbc::driversource: '//real/location/msodbcsql_17.3.1.1_x64.msi'
    ```

## Register dependencies

1. .\mssql\metadata.json

    ```json
    ...
    "dependencies": [
        {
        "name": "puppetlabs/stdlib",
        "version_requirement": ">= 4.13.1 < 6.0.0"
        }
    ],
    ...
    ```

## Test and validate

1. Ensure there are no errors or warnings

    ```cmd
    pdk validate --parallel
    pdk test unit --parallel
    ```

## Publish the module to github

1. Create github repository https://github.com/umaritimus/mssql.git
1. Register source and summary in .\mssql\metadata.json

    ```json
    ...
    "summary": "Puppet module to install and manage Microsoft SQL Server",
    "source": "https://github.com/umaritimus/mssql.git",
    ```

1. Describe module in [README.md](README.md)

1. Initialize repository and push

    ```cmd
    git init
    git remote add origin https://github.com/umaritimus/mssql.git
    git add .
    git commit -m "Initial commit"
    git push origin


## Publish the module to puppet forge

1. Optional

## Appendix

1. Expand functionality

    ```cmd
    pdk new defined_type mssql::client::cli::sqlcmd
    pdk new defined_type mssql::client::cli::sqlscript
    pdk new defined_type mssql::client::cli::sqlquery
    pdk new defined_type mssql::client::api::smo
    pdk new class mssql::client::cli
    pdk new class mssql::client::api
    pdk new defined_type mssql::client::odbc::datasource
    ```
