# @summary Apply SQL Server cumulative patch
#
# @example
#   include mssql::server::update
class mssql::server::update (
  Boolean $logoutput = true,
  Enum['present','absent'] $ensure = lookup('mssql.server.ensure'),
) {

  notify { 'Processing mssql::server::update' : }

  if ($facts['operatingsystem'] == 'windows') {

    $source = lookup({
      'name'          => 'mssql.server.source.update',
      'default_value' => undef,
    })

    if (!empty($source) and ($ensure == 'present'))  {

      $instancename = lookup({
        'name'          => 'mssql.server.instance.instancename',
        'default_value' => 'MSSQLSERVER',
      })

      exec { 'Apply SQL Server Cumulative Update' :
        command   => Sensitive(@("EOT")),
          Try {
            Set-Location "${regsubst($source ,'/', '\\\\', 'G')}"
            Start-Process `
              -FilePath "${regsubst($source ,'/', '\\\\', 'G')}\\setup.exe" `
              -ArgumentList "/q /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances" `
              -Wait `
              -NoNewWindow `
              -RedirectStandardOutput ${regsubst("\'${::env_temp}/sqlserverpatch.log\'", '(/|\\\\)', '\\', 'G')}

            Start-Sleep -Seconds 10

            If (
              (Get-Content ${regsubst("\'${::env_temp}/sqlserverpatch.log\'", '(/|\\\\)', '\\', 'G')} -ErrorAction Stop) -notlike "*Error*"
            ) {
              Exit 0
            } Else {
              Exit 1
            }
          } Catch {
            Exit 1
          }
          |-EOT
        provider  => powershell,
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
    fail("Unsupported Platform - ${$facts['operatingsystem']}")
  }
}
