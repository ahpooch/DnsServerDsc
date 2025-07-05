$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'

Import-Module -Name $script:dscResourceCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#

    .SYNOPSIS
        Get desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

#>
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $NameServer
    )

    Write-Verbose -Message $script:localizedData.GettingCurrentRootHintsMessage

    if (-not (Test-ModuleExist -Name 'DNSServer'))
    {
        Write-Warning -Message 'DNS module is not installed and resource could be used for revision purposes only.'
        # Returning a mostly $null-filled hashtable so the resource can be used for revision purposes on systems without the DnsServer module.
        $targetResource = @{
            IsSingleInstance = 'Yes'
            NameServer       = $null
        }

        return $targetResource
    }

    $targetResource = @{
        IsSingleInstance = 'Yes'
        NameServer       = Convert-RootHintsToHashtable -RootHints @(Get-DnsServerRootHint)
    }

    Write-Verbose -Message ($script:localizedData.FoundRootHintsMessage -f $targetResource.NameServer.Count)

    return $targetResource
}

<#

    .SYNOPSIS
        Set desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

    .PARAMETER NameServer
        A list of names and IP addresses as a hashtable. This may look like this: NameServer = @{ 'rh1.vm.net.' = '20.1.1.1' }

#>
function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $NameServer
    )

    Write-Verbose -Message $script:localizedData.RemovingAllRootHintsMessage
    Get-DnsServerRootHint | Remove-DnsServerRootHint -Force

    foreach ($item in $NameServer)
    {
        Write-Verbose -Message ($script:localizedData.AddingRootHintMessage -f $item.Key)
        Add-DnsServerRootHint -NameServer $item.Key -IPAddress ($item.value -split ',' | ForEach-Object { $_.Trim() })
    }
}

<#

    .SYNOPSIS
        Test desired state

    .PARAMETER IsSingleInstance
        Key for the resource. This value must be set to 'Yes'

    .PARAMETER NameServer
        A list of names and IP addresses as a hashtable. This may look like this: NameServer = @{ 'rh1.vm.net.' = '20.1.1.1' }

#>
function Test-TargetResource
{
    [OutputType([Bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        [AllowEmptyCollection()]
        $NameServer
    )

    Write-Verbose -Message $script:localizedData.ValidatingRootHintsMessage
    $currentState = Get-TargetResource @PSBoundParameters
    $desiredState = $PSBoundParameters

    foreach ($entry in $desiredState.NameServer)
    {
        $entry.Value = $entry.Value -replace ' ', ''
    }

    $params = @{
        CurrentValues       = $currentState
        DesiredValues       = $desiredState
        TurnOffTypeChecking = $true
        ReverseCheck        = $true
    }

    $result = Test-DscParameterState @params

    $result
}

<#
    .SYNOPSIS
        Converts root hints like the DNS cmdlets are run.

    .DESCRIPTION
        This function is used to convert a CimInstance array containing MSFT_KeyValuePair objects into a hashtable.

    .PARAMETER CimInstance
        An array of CimInstances or a single CimInstance object to convert.

    .OUTPUTS
        System.Collections.Hashtable
#>
function Convert-RootHintsToHashtable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        [AllowEmptyCollection()]
        $RootHints
    )

    $RootHintsHashTable = @{ }

    foreach ($rootHint in $RootHints)
    {
        if (-not $rootHint.IPAddress)
        {
            continue
        }

        $ip = if ($rootHint.IPAddress.RecordData.IPv4Address)
        {
            $rootHint.IPAddress.RecordData.IPv4Address.IPAddressToString -join ','
        }
        else
        {
            $rootHint.IPAddress.RecordData.IPv6Address.IPAddressToString -join ','
        }

        $RootHintsHashTable.Add($rootHint.NameServer.RecordData.NameServer, $ip)
    }

    return $RootHintsHashTable
}
