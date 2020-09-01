# @summary Install SQL Server
#
# @example
#   include mssql::server::install
class mssql::server::install (
  Hash $settings = $mssql::server::install::settings,
  Boolean $logoutput = true,
  Enum['present','absent'] $ensure = $mssql::server::ensure,
) {

  notify { 'Processing mssql::server::install' : }

  $configurationfile = "${facts['puppet_vardir']}/ConfigurationFile.ini"

  $source = lookup({
    'name'          => 'mssql::server::install::source',
    'default_value' => undef,
  })

  $features = lookup({
    'name'          => 'mssql::server::install::settings.OPTIONS.FEATURES',
    'default_value' => 'SQLENGINE',
  })

  $instancename = lookup({
    'name'          => 'mssql::server::install::settings.OPTIONS.INSTANCENAME',
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
      validate_legacy(Hash, 'validate_hash', $settings)
      $defaults = { 'path' => $configurationfile, 'key_val_separator' => '=' }
      inifile::create_ini_settings($settings, $defaults)

      exec { 'Install mssql::server' :
        command   => @("EOT"),
          & ${source}/setup.exe /CONFIGURATIONFILE='${regsubst($configurationfile, '(/|\\\\)', '\\', 'G')}' ; 
          Remove-item -Path ${configurationfile}
          |-EOT
        provider  => 'powershell',
        logoutput => $logoutput,
        unless    => Sensitive(@("EOT")),
          If (
            (Get-ItemProperty `
              -Path 'HKLM:/SOFTWARE/Microsoft/Microsoft SQL Server/Instance Names/SQL' `
              -ErrorAction SilentlyContinue `
            ).${instancename}) {
            0
          } Else {
            Throw 'Instance ${instancename} is already present.'
          }
          If (Test-Path -Path "${regsubst($source ,'/', '\\\\', 'G')}\\setup.exe") {
            0
          } Else {
            Throw 'Path for ${source} is invalid.'
          }
          |-EOT
      }
    }

  }
}
