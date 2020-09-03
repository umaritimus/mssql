# @summary Configure SQL Server instance
#
# @example
#   include mssql::server::config
class mssql::server::config {
  notify { 'Processing mssql::server::config' : }

  if ($facts['operatingsystem'] == 'windows') {

    $logins = lookup('mssql.server.login')
    if (!empty($logins)) {
      $logins.each | String $name, Hash $parameters | {
        dsc_sqlserverlogin { $name :
          dsc_ensure                         => lookup({name => "mssql.server.login.${name}.ensure",default_value => 'present',}),
          dsc_name                           => $name,
          dsc_logintype                      => lookup({name => "mssql.server.login.${name}.logintype",default_value => 'WindowsUser',}),
          dsc_servername                     => 'localhost',
          dsc_instancename                   => lookup('mssql.server.instance.instancename'),
          dsc_logincredential                => lookup({name => "mssql.server.login.${name}.logincredential",default_value => undef,}),
          dsc_loginmustchangepassword        => lookup({name => "mssql.server.login.${name}.loginmustchangepassword",default_value => 'False',}),
          dsc_loginpasswordexpirationenabled => lookup({name => "mssql.server.login.${name}.loginpasswordexpirationenabled",default_value => 'False',}),
          dsc_loginpasswordpolicyenforced    => lookup({name => "mssql.server.login.${name}.loginpasswordpolicyenforced",default_value => 'False',}),
          dsc_disabled                       => lookup({name => "mssql.server.login.${name}.disabled",default_value => 'False',}),
        }
      }
    }

    $configurations = lookup('mssql.server.configuration')
    if (!empty($configurations)) {
      $configurations.each | $option | {
        dsc_sqlserverconfiguration { "${option.keys[0]}" :
          dsc_servername   => 'localhost',
          dsc_instancename => lookup('mssql.server.instance.instancename'),
          dsc_optionname   => "${option.keys[0]}",
          dsc_optionvalue  => "${option.values[0]}",
        }
      }
    }

    dsc_sqlserverdatabasemail { 'Enable Database Mail' :
      dsc_ensure         => 'Present',
      dsc_servername     => 'localhost',
      dsc_instancename   => lookup('mssql.server.instance.instancename'),
      dsc_accountname    => lookup('mssql.server.email.accountname'),
      dsc_profilename    => lookup('mssql.server.email.profilename'),
      dsc_emailaddress   => lookup('mssql.server.email.address'),
      dsc_replytoaddress => lookup('mssql.server.email.replytoaddress'),
      dsc_displayname    => lookup('mssql.server.email.displayname'),
      dsc_mailservername => lookup('mssql.server.email.servername'),
      dsc_description    => lookup('mssql.server.email.description'),
      dsc_logginglevel   => lookup('mssql.server.email.logginglevel'),
      dsc_tcpport        => lookup('mssql.server.email.tcpport'),
      require            => [ Dsc_sqlserverconfiguration['Database Mail XPs'] ],
    }

    dsc_sqlservermaxdop{ "Set MAXDOP to ${lookup('mssql.server.maxdop')}" :
      dsc_servername   => 'localhost',
      dsc_instancename => lookup('mssql.server.instance.instancename'),
      dsc_maxdop       => lookup('mssql.server.maxdop'),
    }

    dsc_sqlservermemory { "Set Sql Server Memory to ${lookup('mssql.server.memory.maxmemory')}" :
      dsc_ensure       => 'present',
      dsc_dynamicalloc => 'False',
      dsc_minmemory    => lookup('mssql.server.memory.minmemory'),
      dsc_maxmemory    => lookup('mssql.server.memory.maxmemory'),
      dsc_servername   => 'localhost',
      dsc_instancename => lookup('mssql.server.instance.instancename'),
    }

    dsc_sqlservernetwork { 'Configure SQL network' :
      dsc_instancename   => lookup('mssql.server.instance.instancename'),
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

    dsc_firewall { 'Allow Remote SQL Instance Mamangement' :
      dsc_name    => 'WMI-WINMGMT-In-TCP',
      dsc_enabled => 'True',
    }

  } else {
    fail("Unsupported Platform - ${$facts['operatingsystem']}")
  }
}
