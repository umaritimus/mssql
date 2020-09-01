# @summary Configure SQL Server instance
#
# @example
#   include mssql::server::config
class mssql::server::config {
  notify { 'Processing mssql::server::config' : }

  $instancename = lookup({
    'name'          => 'mssql::server::install::settings.OPTIONS.INSTANCENAME',
    'default_value' => 'MSSQLSERVER',
  })

  dsc_sqlserverconfiguration { 'Set Default Backup Compression' :
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_optionname   => 'backup compression default',
    dsc_optionvalue  => 1,
  }

  dsc_sqlserverlogin { 'Disable sa account' :
    dsc_ensure       => 'present',
    dsc_name         => 'sa',
    dsc_logintype    => 'SqlLogin',
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_disabled     => 'True',
  }

  dsc_sqlservermaxdop{ "Set MAXDOP to lookup('mssql.maxdop')" :
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_maxdop       => lookup('mssql.server.maxdop'),
  }

  dsc_sqlservermemory { "Set Sql Server Memory to lookup('mssql.maxmemory')" :
    dsc_ensure       => 'present',
    dsc_dynamicalloc => 'False',
    dsc_minmemory    => lookup('mssql.server.minmemory'),
    dsc_maxmemory    => lookup('mssql.server.maxmemory'),
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
  }

  dsc_sqlserverconfiguration { 'Set Cost Threshold For Parallelism' :
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_optionname   => 'cost threshold for parallelism',
    dsc_optionvalue  => lookup('mssql.server.cost_threshold_for_parallelism'),
  }

  dsc_sqlserverconfiguration { 'Enable Contained Database Authentication' :
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_optionname   => 'contained database authentication',
    dsc_optionvalue  => lookup('mssql.server.contained_database_authentication'),
  }

  dsc_sqlserverconfiguration {  'Enable Database Mail XPs' :
    dsc_servername   => 'localhost',
    dsc_instancename => $instancename,
    dsc_optionname   => 'Database Mail XPs',
    dsc_optionvalue  => 1,
  }

  dsc_sqlserverdatabasemail { 'Enable Database Mail' :
    dsc_ensure         => 'Present',
    dsc_servername     => 'localhost',
    dsc_instancename   => $instancename,
    dsc_accountname    => lookup('mssql.server.email.accountname'),
    dsc_profilename    => lookup('mssql.server.email.profilename'),
    dsc_emailaddress   => lookup('mssql.server.email.address'),
    dsc_replytoaddress => lookup('mssql.server.email.replytoaddress'),
    dsc_displayname    => lookup('mssql.server.email.displayname'),
    dsc_mailservername => lookup('mssql.server.email.servername'),
    dsc_description    => lookup('mssql.server.email.description'),
    dsc_logginglevel   => lookup('mssql.server.email.logginglevel'),
    dsc_tcpport        => lookup('mssql.server.email.tcpport'),
    require            => [ Dsc_sqlserverconfiguration['Enable Database Mail XPs'] ],
  }

  dsc_sqlservernetwork { 'Configure SQL network' :
    dsc_instancename   => $instancename,
    dsc_protocolname   => 'tcp',
    dsc_isenabled      => 'True',
    dsc_tcpport        => lookup('mssql.server.tcpport'),
    dsc_restartservice => 'True',
  }

  dsc_firewall { 'Create SQL Server Firewall Rule' :
    dsc_action        => 'Allow',
    dsc_protocol      => 'TCP',
    dsc_remoteaddress => lookup('mssql.server.firewall.allow_remoteaddress'),
    dsc_localport     => lookup('mssql.server.firewall.allow_localport'),
    dsc_description   => 'Allow SQL Server Connection',
    dsc_displayname   => 'SQL Server Connection',
    dsc_name          => 'SQL Server Connection',
    dsc_ensure        => 'present',
    require           => [ Dsc_sqlservernetwork['Configure SQL network'] ],
  }
}
