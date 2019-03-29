# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include mssql::server::install
class mssql::server::install (
  Hash $settings = $mssql::server::install::settings,
  Boolean $logoutput = true,
  Enum['present','absent'] $ensure = $mssql::server::ensure,
  String $source = $mssql::server::source,
) {

  $configurationfile = "${facts['puppet_vardir']}/ConfigurationFile.ini"

  $features = lookup({
    'name'          => 'mssql::server::install::settings.OPTIONS.FEATURES',
    'default_value' => 'SQLENGINE',
  })

  $instancename = lookup({
    'name'          => 'mssql::server::install::settings.OPTIONS.INSTANCENAME',
    'default_value' => 'MSSQLSERVER',
  })

  if $ensure == 'absent' {

    exec { 'Uninstall mssql::server' :
      command   => "& ${source}/setup.exe /ACTION=Uninstall /QUIET=True /FEATURES=${features} /INSTANCENAME=${instancename}",
      provider  => 'powershell',
      logoutput => $logoutput,
      onlyif    => @("EOT"),
        If (
          (Get-ItemProperty `
            -Path 'HKLM:/SOFTWARE/Microsoft/Microsoft SQL Server/Instance Names/SQL' `
            -ErrorAction SilentlyContinue `
          ).${instancename}) {
          0
        } Else {
          Throw 'Instance ${instancename} is not present.'
        }
        |-EOT
    }

  } else {

    validate_legacy(Hash, 'validate_hash', $settings)
    $defaults = { 'path' => $configurationfile, 'key_val_separator' => '=' }
    create_ini_settings($settings, $defaults)

    exec { 'Install mssql::server' :
      command   => @("EOT"),
        & ${source}/setup.exe /CONFIGURATIONFILE='${regsubst($configurationfile, '(/|\\\\)', '\\', 'G')}' ; 
        Remove-item -Path ${configurationfile}
        |-EOT
      provider  => 'powershell',
      logoutput => $logoutput,
    }

  }
}
