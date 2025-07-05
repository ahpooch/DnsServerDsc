$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:dscResourceCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        This will return the current state of the resource.

    .PARAMETER Name
        Specifies the name of the Zone Scope.

    .PARAMETER ZoneName
        Specify the existing DNS Zone to add a scope to.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ZoneName

    )

    Write-Verbose -Message ($script:localizedData.GettingDnsServerZoneScopeMessage -f $Name, $ZoneName)

    if (-not (Test-ModuleExist -Name 'DNSServer'))
    {
        Write-Warning -Message 'DNS module is not installed and resource could be used for revision purposes only.'
        # Returning a mostly $null-filled hashtable so the resource can be used for revision purposes on systems without the DnsServer module.
        $targetResource = @{
            Name     = $Name
            ZoneName = $ZoneName
            ZoneFile = $null
            Ensure   = 'Absent'
        }

        return $targetResource
    }

    $record = Get-DnsServerZoneScope -Name $Name -ZoneName $ZoneName -ErrorAction SilentlyContinue

    $targetResource = if ($null -eq $record)
    {
        @{
            Name     = $Name
            ZoneName = $ZoneName
            ZoneFile = $null
            Ensure   = 'Absent'
        }
    }
    else
    {
        @{
            Name     = $record.ZoneScope
            ZoneName = $record.ZoneName
            ZoneFile = $record.FileName
            Ensure   = 'Present'
        }
    }

    return $targetResource
}

<#
    .SYNOPSIS
        This will configure the resource.

    .PARAMETER Name
        Specifies the name of the Zone Scope.

    .PARAMETER ZoneName
        Specify the existing DNS Zone to add a scope to.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ZoneName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $clientSubnet = Get-DnsServerZoneScope -Name $Name -ZoneName $ZoneName -ErrorAction SilentlyContinue
    if ($Ensure -eq 'Present')
    {
        if (!$clientSubnet)
        {
            Write-Verbose -Message ($script:localizedData.CreatingDnsServerZoneScopeMessage -f $Name, $ZoneName)
            Add-DnsServerZoneScope -ZoneName $ZoneName -Name $Name
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($script:localizedData.RemovingDnsServerZoneScopeMessage -f $Name, $ZoneName)
        Remove-DnsServerZoneScope -Name $Name -ZoneName $ZoneName
    }
}

<#
    .SYNOPSIS
        This will return whether the resource is in desired state.

    .PARAMETER Name
        Specifies the name of the Zone Scope.

    .PARAMETER ZoneName
        Specify the existing DNS Zone to add a scope to.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ZoneName,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    $result = Get-TargetResource -Name $Name -ZoneName $ZoneName

    if ($Ensure -ne $result.Ensure)
    {
        Write-Verbose -Message ($script:localizedData.NotDesiredPropertyMessage -f 'Ensure', $Ensure, $result.Ensure)
        Write-Verbose -Message ($script:localizedData.NotInDesiredStateMessage -f $Name)
        return $false
    }

    Write-Verbose -Message ($script:localizedData.InDesiredStateMessage -f $Name)
    return $true
}
