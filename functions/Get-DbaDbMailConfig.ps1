﻿function Get-DbaDbMailConfig {
<#
    .SYNOPSIS
        Gets database mail configs from SQL Server

    .DESCRIPTION
        Gets database mail configs from SQL Server

    .PARAMETER SqlInstance
        The SQL Server instance, or instances.

    .PARAMETER SqlCredential
        Login to the target instance using alternative credentials. Windows and SQL Authentication supported. Accepts credential objects (Get-Credential)

    .PARAMETER Name
        Specifies one or more config(s) to get. If unspecified, all configs will be returned.

    .PARAMETER InputObject
        Accepts pipeline input from Get-DbaDbMail

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
        Tags: DatabaseMail, DBMail, Mail
        Author: Chrissy LeMaire (@cl), netnerds.net

        Website: https://dbatools.io
        Copyright: (c) 2018 by dbatools, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://dbatools.io/Get-DbaDbMailConfig

    .EXAMPLE
        PS C:\> Get-DbaDbMailConfig -SqlInstance sql01\sharepoint

        Returns DBMail configs on sql01\sharepoint

    .EXAMPLE
        PS C:\> Get-DbaDbMailConfig -SqlInstance sql01\sharepoint -Name ProhibitedExtensions

        Returns the ProhibitedExtensions configuration on sql01\sharepoint

    .EXAMPLE
        PS C:\> Get-DbaDbMailConfig -SqlInstance sql01\sharepoint | Select *

        Returns the DBMail configs on sql01\sharepoint then return a bunch more columns

    .EXAMPLE
        PS C:\> $servers = "sql2014","sql2016", "sqlcluster\sharepoint"
        PS C:\> $servers | Get-DbaDbMail | Get-DbaDbMailConfig

        Returns the DBMail configs for "sql2014","sql2016" and "sqlcluster\sharepoint"

#>
    [CmdletBinding()]
    param (
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [Alias("Credential")]
        [PSCredential]$SqlCredential,
        [Alias("Config", "ConfigName")]
        [string[]]$Name,
        [Parameter(ValueFromPipeline)]
        [Microsoft.SqlServer.Management.Smo.Mail.SqlMail[]]$InputObject,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            Write-Message -Level Verbose -Message "Connecting to $instance"
            $InputObject += Get-DbaDbMail -SqlInstance $SqlInstance -SqlCredential $SqlCredential
        }

        if (-not $InputObject) {
            Stop-Function -Message "No servers to process"
            return
        }

        foreach ($mailserver in $InputObject) {
            try {
                $configs = $mailserver.ConfigurationValues

                if ($Name) {
                    $configs = $configs | Where-Object Name -in $Name
                }

                $configs | Add-Member -Force -MemberType NoteProperty -Name ComputerName -value $mailserver.ComputerName
                $configs | Add-Member -Force -MemberType NoteProperty -Name InstanceName -value $mailserver.InstanceName
                $configs | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -value $mailserver.SqlInstance
                $configs | Select-DefaultView -Property ComputerName, InstanceName, SqlInstance, Name, Value, Description
            }
            catch {
                Stop-Function -Message "Failure" -ErrorRecord $_ -Continue
            }
        }
    }
}