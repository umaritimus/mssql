# @summary Install SQL Server
#
# @example
#   include mssql::server::install
class mssql::server::install (
  #Hash $settings = $mssql::server::install::settings,
  Boolean $logoutput = true,
  Enum['present','absent'] $ensure = lookup('mssql.server.ensure'),
) {

  notify { "Processing mssql::server::install" : }

  if ($facts['operatingsystem'] == 'windows') {

    $source = lookup({
      'name'          => 'mssql.server.source.install',
      'default_value' => undef,
    })

    $features = lookup({
      'name'          => 'mssql.server.instance.features',
      'default_value' => 'SQLENGINE',
    })

    $instancename = lookup({
      'name'          => 'mssql.server.instance.instancename',
      'default_value' => 'MSSQLSERVER',
    })

    if ($ensure == 'absent') {

      if (!empty($source)) {
        exec { 'Uninstall mssql::server' :
          command   => "& ${source}/setup.exe /ACTION=Uninstall /QUIET=True /FEATURES=${features} /INSTANCENAME=${instancename}",
          provider  => 'powershell',
          logoutput => $logoutput,
          onlyif    => Sensitive(@("EOT")),
            If (
              (Get-ItemProperty `
                -Path 'HKLM:/SOFTWARE/Microsoft/Microsoft SQL Server/Instance Names/SQL' `
                -ErrorAction SilentlyContinue `
              ).${instancename}) {
              0
            } Else {
              Throw 'Instance ${instancename} is not present.'
            }
            If (Test-Path -Path "${regsubst($source ,'/', '\\\\', 'G')}\\setup.exe") {
              0
            } Else {
              Throw 'Path for ${source} is invalid.'
            }
            |-EOT
        }
      }

    } else {

      if (!empty($source)) {
        dsc_sqlsetup { 'Install SQL Server' :
          dsc_action                     => lookup({name => 'mssql.server.instance.action',default_value => 'Install',}),
          dsc_sourcepath                 => lookup({name => 'mssql.server.source.install',default_value => undef,}),
          dsc_sourcecredential           => lookup({name => 'mssql.server.instance.sourcecredential',default_value => undef,}),
          dsc_suppressreboot             => lookup({name => 'mssql.server.instance.suppressreboot',default_value => 'True',}),
          dsc_forcereboot                => lookup({name => 'mssql.server.instance.forcereboot',default_value => 'False',}),
          dsc_features                   => lookup({name => 'mssql.server.instance.features',default_value => 'SQLENGINE',}),
          dsc_instancename               => lookup({name => 'mssql.server.instance.instancename',default_value => 'MSSQLSERVER',}),
          dsc_instanceid                 => lookup({name => 'mssql.server.instance.instanceid',default_value => undef,}),
          dsc_productkey                 => lookup({name => 'mssql.server.instance.productkey',default_value => undef,}),
          dsc_updateenabled              => lookup({name => 'mssql.server.instance.updateenabled',default_value => 'False',}),
          dsc_updatesource               => lookup({name => 'mssql.server.instance.updatesource',default_value => undef,}),
          dsc_sqmreporting               => lookup({name => 'mssql.server.instance.sqmreporting',default_value => undef,}),
          dsc_errorreporting             => lookup({name => 'mssql.server.instance.errorreporting',default_value => undef,}),
          dsc_installshareddir           => lookup({name => 'mssql.server.instance.installshareddir',default_value => undef,}),
          dsc_installsharedwowdir        => lookup({name => 'mssql.server.instance.installsharedwowdir',default_value => undef,}),
          dsc_instancedir                => lookup({name => 'mssql.server.instance.instancedir',default_value => undef,}),
          dsc_sqlsvcaccount              => lookup({name => 'mssql.server.instance.sqlsvcaccount',default_value => undef,}),
          dsc_sqlsvcaccountusername      => lookup({name => 'mssql.server.instance.sqlsvcaccountusername',default_value => undef,}),
          dsc_agtsvcaccount              => lookup({name => 'mssql.server.instance.agtsvcaccount',default_value => undef,}),
          dsc_agtsvcaccountusername      => lookup({name => 'mssql.server.instance.agtsvcaccountusername',default_value => undef,}),
          dsc_sqlcollation               => lookup({name => 'mssql.server.instance.sqlcollation',default_value => undef,}),
          dsc_sqlsysadminaccounts        => lookup({name => 'mssql.server.instance.sqlsysadminaccounts',default_value => undef,}),
          dsc_securitymode               => lookup({name => 'mssql.server.instance.securitymode',default_value => undef,}),
          dsc_sapwd                      => lookup({name => 'mssql.server.instance.sapwd',default_value => undef,}),
          dsc_installsqldatadir          => lookup({name => 'mssql.server.instance.installsqldatadir',default_value => undef,}),
          dsc_sqluserdbdir               => lookup({name => 'mssql.server.instance.sqluserdbdir',default_value => undef,}),
          dsc_sqluserdblogdir            => lookup({name => 'mssql.server.instance.sqluserdblogdir',default_value => undef,}),
          dsc_sqltempdbdir               => lookup({name => 'mssql.server.instance.sqltempdbdir',default_value => undef,}),
          dsc_sqltempdblogdir            => lookup({name => 'mssql.server.instance.sqltempdblogdir',default_value => undef,}),
          dsc_sqlbackupdir               => lookup({name => 'mssql.server.instance.sqlbackupdir',default_value => undef,}),
          dsc_ftsvcaccount               => lookup({name => 'mssql.server.instance.ftsvcaccount',default_value => undef,}),
          dsc_ftsvcaccountusername       => lookup({name => 'mssql.server.instance.ftsvcaccountusername',default_value => undef,}),
          dsc_rssvcaccount               => lookup({name => 'mssql.server.instance.rssvcaccount',default_value => undef,}),
          dsc_rssvcaccountusername       => lookup({name => 'mssql.server.instance.rssvcaccountusername',default_value => undef,}),
          dsc_assvcaccount               => lookup({name => 'mssql.server.instance.assvcaccount',default_value => undef,}),
          dsc_assvcaccountusername       => lookup({name => 'mssql.server.instance.assvcaccountusername',default_value => undef,}),
          dsc_ascollation                => lookup({name => 'mssql.server.instance.ascollation',default_value => undef,}),
          dsc_assysadminaccounts         => lookup({name => 'mssql.server.instance.assysadminaccounts',default_value => undef,}),
          dsc_asdatadir                  => lookup({name => 'mssql.server.instance.asdatadir',default_value => undef,}),
          dsc_aslogdir                   => lookup({name => 'mssql.server.instance.aslogdir',default_value => undef,}),
          dsc_asbackupdir                => lookup({name => 'mssql.server.instance.asbackupdir',default_value => undef,}),
          dsc_astempdir                  => lookup({name => 'mssql.server.instance.astempdir',default_value => undef,}),
          dsc_asconfigdir                => lookup({name => 'mssql.server.instance.asconfigdir',default_value => undef,}),
          dsc_asservermode               => lookup({name => 'mssql.server.instance.asservermode',default_value => undef,}),
          dsc_issvcaccount               => lookup({name => 'mssql.server.instance.issvcaccount',default_value => undef,}),
          dsc_issvcaccountusername       => lookup({name => 'mssql.server.instance.issvcaccountusername',default_value => undef,}),
          dsc_sqlsvcstartuptype          => lookup({name => 'mssql.server.instance.sqlsvcstartuptype',default_value => undef,}),
          dsc_agtsvcstartuptype          => lookup({name => 'mssql.server.instance.agtsvcstartuptype',default_value => undef,}),
          dsc_issvcstartuptype           => lookup({name => 'mssql.server.instance.issvcstartuptype',default_value => undef,}),
          dsc_assvcstartuptype           => lookup({name => 'mssql.server.instance.assvcstartuptype',default_value => undef,}),
          dsc_rssvcstartuptype           => lookup({name => 'mssql.server.instance.rssvcstartuptype',default_value => undef,}),
          dsc_browsersvcstartuptype      => lookup({name => 'mssql.server.instance.browsersvcstartuptype',default_value => undef,}),
          dsc_failoverclustergroupname   => lookup({name => 'mssql.server.instance.failoverclustergroupname',default_value => undef,}),
          dsc_failoverclusteripaddress   => lookup({name => 'mssql.server.instance.failoverclusteripaddress',default_value => undef,}),
          dsc_failoverclusternetworkname => lookup({name => 'mssql.server.instance.failoverclusternetworkname',default_value => undef,}),
          dsc_sqltempdbfilecount         => lookup({name => 'mssql.server.instance.sqltempdbfilecount',default_value => undef,}),
          dsc_sqltempdbfilesize          => lookup({name => 'mssql.server.instance.sqltempdbfilesize',default_value => undef,}),
          dsc_sqltempdbfilegrowth        => lookup({name => 'mssql.server.instance.sqltempdbfilegrowth',default_value => undef,}),
          dsc_sqltempdblogfilesize       => lookup({name => 'mssql.server.instance.sqltempdblogfilesize',default_value => undef,}),
          dsc_sqltempdblogfilegrowth     => lookup({name => 'mssql.server.instance.sqltempdblogfilegrowth',default_value => undef,}),
          dsc_setupprocesstimeout        => lookup({name => 'mssql.server.instance.setupprocesstimeout',default_value => undef,}),
          dsc_psdscrunascredential       => lookup({name => 'mssql.server.instance.psdscrunascredential',default_value => undef,}),
        }
      }
    }
  } else {
    fail("Unsupported Platform - ${$facts['operatingsystem']}")
  }
}
