# @summary Apply SQL Server cumulative patch
#
# Apply SQL Server cumulative patch
#
# @example
#   include mssql::server::update
class mssql::server::update (
  Boolean $logoutput = true,
  Enum['present','absent'] $ensure = $mssql::server::ensure,
) {

  notify { 'Processing mssql::server::update' : }

  if (!empty($mssql::server::update::source) and ($ensure == 'present'))  {

    $instancename = lookup({
      'name'          => 'mssql::server::install::settings.OPTIONS.INSTANCENAME',
      'default_value' => 'MSSQLSERVER',
    })

    exec { 'Apply SQL Server Cumulative Update' :
      command  => @("EOT"),
        Try {
          Set-Location "${regsubst($mssql::server::update::source ,'/', '\\\\', 'G')}"
          Start-Process `
            -FilePath "${regsubst($mssql::server::update::source ,'/', '\\\\', 'G')}\\setup.exe" `
            -ArgumentList "/q /IAcceptSQLServerLicenseTerms /Action=Patch /AllInstances" `
            -Wait `
            -NoNewWindow `
            -RedirectStandardOutput ${regsubst("\'${::env_temp}/sqlserverpatch.log\'", '(/|\\\\)', '\\', 'G')}

          Start-Sleep -Seconds 10

          If ((Get-Content ${regsubst("\'${::env_temp}/sqlserverpatch.log\'", '(/|\\\\)', '\\', 'G')} -ErrorAction Stop) -notlike "*Error*") {
            Exit 0
          } Else {
            Exit 1
          }
        } Catch {
          Exit 1
        }
        |-EOT
      provider => powershell,
      onlyif   => @("EOT"),
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
  }
}
