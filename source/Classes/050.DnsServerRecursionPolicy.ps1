<#
    .SYNOPSIS
        The DnsServerRecursionPolicy DSC resource manages Recursion Policies that control how the DNS server performs recursion for a query.

    .DESCRIPTION
        The DnsServerRecursionPolisy DSC resource manages Recursion Policies that control how the DNS server performs recursion for a query.

    #.PARAMETER ZoneScope
    #    Specifies the name of a zone scope. (Key Parameter)

    .NOTES
        Recursion policies apply only when query processing reaches the recursion path.
        You can choose a value of DENY or IGNORE for recursion for a set of queries.
        Alternatively, you can choose a set of forwarders for a set of queries.
        You can use recursion policies to implement a Split-brain DNS configuration.
        In this configuration, the DNS server performs recursion for a set of clients for a query,
        while the DNS server does not perform recursion for other clients for that query.

        DNS Policies overview
        https://learn.microsoft.com/en-us/windows-server/networking/dns/deploy/dns-policies-overview
#>
