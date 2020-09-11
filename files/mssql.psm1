Function New-SqlServerLinkedServer {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the name for the Linked Server"
        )]
        [String] ${Name},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the Login username for the Linked Server"
        )]
        [String] ${Login},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the password for the Linked Server"
        )]
        [String] ${Password}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
    }

    Process {

        Write-Verbose "[${ComputerName}][Goal] Configure SQL Server Linked Server"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-Not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-Not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-Not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }

            Write-Verbose "[${ComputerName}][Task] Create SQL Server Linked Server"
            ${linked_server} = ${server}.linkedservers | Where-Object Name -like ${Name}

            If (-Not ${linked_server}) {
                ${linked_server} = New-Object -TypeName Microsoft.SqlServer.Management.SMO.LinkedServer
                ${linked_server}.Parent = ${server}
                ${linked_server}.Name = ${Name}
        
                ${linked_server}.ProductName = "SQL Server"
                ${linked_server}.Create()
                Write-Verbose "[${ComputerName}][Done] Create SQL Server Linked Server"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] Create SQL Server Linked Server"
            }

            Write-Verbose "[${ComputerName}][Task] Configure Login for SQL Server Linked Server"
            If ( ${linked_server}.LinkedServerLogins.RemoteUser -ne "${Login}" ) {
                ${linked_server_login} = New-Object -TypeName Microsoft.SqlServer.Management.SMO.LinkedServerLogin(${linked_server}, $Null)
                ${linked_server_login}.Impersonate = $False;
                ${linked_server_login}.RemoteUser = "${Login}"
                ${linked_server_login}.SetRemotePassword("${Password}")
                ${linked_server_login}.Create()
                Write-Verbose "[${ComputerName}][Done] Configure Login for SQL Server Linked Server"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] Configure Login for SQL Server Linked Server"
            }

            Write-Verbose "[${ComputerName}][Complete] Configure SQL Server Linked Server"
        } Catch {
            Throw "Something went wrong during the creation of SQL Server Linked Server"
        }
    }
}


Function New-SqlServerCredential {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the Identity"
        )]
        [String] ${Username},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the Password"
        )]
        [String] ${Password}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        ${ContextType} = [System.DirectoryServices.AccountManagement.ContextType]::Domain
        ${PrincipalContext} = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ${ContextType}, ${Username}.Split('\')[0]
        ${UserPrincipalType} = 'System.DirectoryServices.AccountManagement.UserPrincipal' -as [Type]
        ${User} = ${UserPrincipalType}::FindByIdentity(${PrincipalContext}, "SamAccountName", ${Username})

        ${ProxyName} = "$(${User}.DisplayName)"
        ${Username} = "$(${Username}.Split('\')[0].ToUpper())\$(${User}.SamAccountName)"
        ${CredentialName} = ${ProxyName}
    }

    Process {
        Write-Verbose "[${ComputerName}][Goal] Configuring SQL Server Credential"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }

            Write-Verbose "[${ComputerName}][Task] Create Login"
            ${login} = ${server}.Logins | Where-Object Name -like ${Username}
            If (-not ${login}) {
                ${login} = new-object Microsoft.SqlServer.Management.Smo.Login($server, ${Username})
                ${login}.LoginType = 'WindowsUser'
                ${login}.Create(${Password})
                Write-Verbose "[${ComputerName}][Done] Create Login '$(${login}.Name)'"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] Login '$(${login}.Name)' already exists"
            }

            Write-Verbose "[${ComputerName}][Task] Create SQL Credential"
            ${server}.Credentials.Refresh()
            ${sqlcredential} = ${server}.Credentials[${CredentialName}]
            If (-not ${sqlcredential}) {
                $sqlcredential = New-Object -Type Microsoft.SqlServer.Management.SMO.Credential($server, ${CredentialName})
                $sqlcredential.Create(${Username}, ${Password})
                Write-Verbose "[${ComputerName}][Done] Create SQL Credential '$(${sqlcredential}.Name)'"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] SQL Credential '$(${sqlcredential}.Name)' already exists"
            }

            Write-Verbose "[${ComputerName}][Task] Associate SQL Credential with Login"
            Try {
                $login.AddCredential($sqlcredential.Name)
                $login.Alter()
                Write-Verbose "[${ComputerName}][Done] Associate SQL Credential '$($sqlcredential.Name)' with Login '$(${login}.Name)'"
            } Catch {
                Write-Verbose "[${ComputerName}][Skip] $($PSItem.Exception.InnerException.InnerException.InnerException.Message)"
            }
        } Catch {
            Throw "Something went wrong during the creation of SQL Server Credential"
        }
    }
}


Function New-SqlServerProxy {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the username for the Proxy Account"
        )]
        [String] ${Username},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the password for the Proxy"
        )]
        [String] ${ProxySubsystem}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        ${ContextType} = [System.DirectoryServices.AccountManagement.ContextType]::Domain
        ${PrincipalContext} = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ${ContextType}, ${Username}.Split('\')[0]
        ${UserPrincipalType} = 'System.DirectoryServices.AccountManagement.UserPrincipal' -as [Type]
        ${User} = ${UserPrincipalType}::FindByIdentity(${PrincipalContext}, "SamAccountName", ${Username})

        ${ProxyName} = "$(${User}.DisplayName)"
        ${Username} = "$(${Username}.Split('\')[0].ToUpper())\$(${User}.SamAccountName)"
        ${CredentialName} = ${ProxyName}
    }

    Process {
        Write-Verbose "[${ComputerName}][Goal] Configuring SQL Server Proxy Account"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }
            ${server}.JobServer.ProxyAccounts.Refresh()

            Write-Verbose "[${ComputerName}][Task] Create Proxy"
            If (-not ${server}.JobServer.ProxyAccounts[${CredentialName}]) {
                Try {
                    ${proxy} = New-Object -Type Microsoft.SqlServer.Management.SMO.Agent.ProxyAccount `
                        -ArgumentList ${server}.JobServer, ${CredentialName}
                    ${proxy}.CredentialName = ${CredentialName}
                    ${proxy}.Description = ${CredentialName}
                    ${proxy}.Create()
                    ${server}.JobServer.ProxyAccounts.Refresh() 
                    Write-Verbose "[${ComputerName}][Done] Create Proxy"
                } Catch {
                    Write-Warning "[${ComputerName}][Fail] Create Proxy"
                }
            } Else {
                Write-Verbose "[${ComputerName}][Skip] Create Proxy"
            }

            ${proxy} = ${server}.JobServer.ProxyAccounts | Where-Object Name -like ${CredentialName}

            Write-Verbose "[${ComputerName}][Task] Associate SQL Credential Proxy Account"
            Try {
                If (!${proxy}) {
                    ${proxy}.AddLogin(${CredentialName})
                    ${proxy}.Alter()
                    Write-Verbose "[${ComputerName}][Done] Associate SQL Credential Proxy Account"
                } Else {
                    Write-Verbose "[${ComputerName}][Skip] Associate SQL Credential Proxy Account"
                }
            } Catch {
                Write-Warning "[${ComputerName}][Fail] Associate SQL Credential Proxy Account"
            }

            Write-Verbose "[${ComputerName}][Task] Add subsystems"
            Try {
                ${proxy}.AddSubSystem(${ProxySubsystem})
                ${proxy}.Alter()
                Write-Verbose "[${ComputerName}][Done] Add ${ProxySubsystem} subsystem"
            } Catch {
                Write-Warning "[${ComputerName}][Fail] Add ${ProxySubsystem} subsystem"
            }
        } Catch {
            Throw "Something went wrong during the creation of SQL Server Proxy"
        }
    }
}


Function New-SqlAgentAlert {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the Alert Name"
        )]
        [String] ${AlertName},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the Operator Name"
        )]
        [String] ${Operator},
        [Parameter(
            Mandatory = $False,
            HelpMessage = "Please enter Severity level"
        )]
        [String] ${Severity}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
    }

    Process {
        Write-Verbose "[${ComputerName}][Goal] Configuring SQL Server Credential"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }

            Write-Verbose "[${ComputerName}][Task] Create Alert"
            ${alert} = ${server}.JobServer.Alerts | Where-Object Name -like ${AlertName}
            If (-not ${alert}) {
                ${alert} = New-Object Microsoft.SqlServer.Management.Smo.Agent.Alert($server.JobServer, ${AlertName})
                ${alert}.Severity = ${Severity}
                ${alert}.Create()
                Write-Verbose "[${ComputerName}][Done] Create Alert '${AlertName}'"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] Alert '${AlertName}' already exists"
            }

            Write-Verbose "[${ComputerName}][Task] Add email notification"
            If ((${alert}.EnumNotifications([Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail, ${Operator}) | Measure-Object).Count -gt 0) {
                Write-Verbose "[${ComputerName}][Skip] Add email notification"
            } Else {
                ${alert}.AddNotification(${Operator}, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
                ${alert}.Alter()
                Write-Verbose "[${ComputerName}][Done] Add email notification"
            }
        } Catch {
            Throw "Something went wrong during the creation of SQL Agent Alert"
        }
    }
}


Function Set-SqlAgentProperty {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the SQL Agent Property Name"
        )]
        [String] ${PropertyName},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter the SQL Agent Property Value"
        )]
        [String] ${PropertyValue}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
    }

    Process {
        Write-Verbose "[${ComputerName}][Goal] Configuring SQL Agent Property '${PropertyName}'"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }

            Write-Verbose "[${ComputerName}][Task] Set Property '${PropertyName}'"
            ${server}.JobServer.Refresh()
            ${property} = ${server}.JobServer.Properties | Where-Object Name -like ${PropertyName}
            If (${property}) {
                ${property}.Value = ${PropertyValue} -as (${property}.Type -as [Type])
                Try {
                    ${server}.JobServer.Alter()
                } Catch {
                    Throw "Job Server properties coudn't be saved"
                }
                Write-Verbose "[${ComputerName}][Done] Set Property '${PropertyName}'"
            } Else {
                Write-Verbose "[${ComputerName}][Skip] No such property defined"
            }
        } Catch {
            Throw "Something went wrong during the creation of SQL Agent Property"
        }
    }
}

Function New-SqlServerStartupParameter {
    [CmdletBinding()]

    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Please enter Startup Parameter"
        )]
        [String] ${StartupParameter},
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Ensure"
        )]
        [String] ${Ensure}
    )

    Begin {
        ${ComputerName} = (Get-WmiObject Win32_Computersystem).Name.toLower()
    }

    Process {
        Write-Verbose "[${ComputerName}][Goal] Configuring SQL Server Credential"
        Try {
            Write-Verbose "[${ComputerName}][Task] Ensure that the services are running"
            If (-not (Get-Service MSSQLSERVER | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name MSSQLSERVER -ErrorAction Stop | Out-Null
            }
            If (-not (Get-Service SQLSERVERAGENT | Where-Object { $_.Status -eq 'Running' }) ) {
                Start-Service -Name SQLSERVERAGENT -ErrorAction Stop | Out-Null
            }
            Write-Verbose "[${ComputerName}][Done] Ensure that the services are running"

            If (-not ${server}) {
                Write-Verbose "[${ComputerName}][Task] Get default server"
                [void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
                [void][Reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server '.'
                Write-Verbose "[${ComputerName}][Done] Get default server"
            }

            Write-Verbose "[${ComputerName}][Task] Ensure that Startup Parameter '${StartupParameter}' is '${Ensure}'"
            ${Computer} = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $server.ComputerNamePhysicalNetBIOS
            ${SqlService} = (${Computer}.Services | Where-Object { $_.Type -eq "SqlServer" })
            ${SqlService}.Refresh()
            ${CurrentStartupParameters} = ${SqlService}.StartupParameters

            If (${CurrentStartupParameters}.Split(';') -contains ${StartupParameter}) {
                If (${Ensure} -eq 'present') {
                    Write-Verbose "[${ComputerName}][Skip] Startup Parameter '${StartupParameter}' is already present"
                } Else {
                    ${NewStartupParameters} = ${CurrentStartupParameters}.Remove($CurrentStartupParameters.IndexOf(${StartupParameter}),${StartupParameter}.Length)
                    ${SqlService}.StartupParameters = ${NewStartupParameters}
                    ${SqlService}.Alter()
                    Write-Verbose "[${ComputerName}][Done] Remove Startup Parameter '${StartupParameter}'"
                }
            } Else {
                If (${Ensure} -ne 'present') {
                    Write-Verbose "[${ComputerName}][Skip] Startup Parameter '${StartupParameter}' is doesn't exist"
                } Else {
                    ${NewStartupParameters} = "${CurrentStartupParameters};${StartupParameter}"
                    ${SqlService}.StartupParameters = ${NewStartupParameters}
                    ${SqlService}.Alter()
                    Write-Verbose "[${ComputerName}][Done] Create Startup Parameter '${StartupParameter}'"
                }
            }
        } Catch {
            Throw "Something went wrong during the creation of SQL Server Startup Parameter"
        }
    }
}