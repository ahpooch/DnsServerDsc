<#
    .SYNOPSIS
        The DnsServerZoneTransferPolicy DSC resource manages Zone Transfer Policies that control whether a zone transfer is allowed or not by your DNS server.

    .DESCRIPTION
        The DnsServerZoneTransferPolicy DSC resource manages Zone Transfer Policies that control whether a zone transfer is allowed or not by your DNS server.

    #.PARAMETER ZoneScope
    #    Specifies the name of a zone scope. (Key Parameter)

    .NOTES
        You can create policies for zone transfer at either the server level or the zone level.
        Server level policies apply on every zone transfer query that occurs on the DNS server.
        Zone level policies apply only on the queries on a zone hosted on the DNS server.
        The most common use for zone level policies is to implement blocked or safe lists.

        DNS Policies overview
        https://learn.microsoft.com/en-us/windows-server/networking/dns/deploy/dns-policies-overview
#>
