<#
    .SYNOPSIS
        A DSC Resource of type Policy for MS DNS Server that is not exposed to end users representing the common fields available to all DNS Policies.

    .DESCRIPTION
        A DSC Resource of type Policy for MS DNS Server that is not exposed to end users representing the common fields available to all DNS Policies.

    .PARAMETER

    #.PARAMETER ZoneName
    #    Specifies the name of a DNS zone. (Key Parameter)

    #.PARAMETER TimeToLive
    #    Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>
