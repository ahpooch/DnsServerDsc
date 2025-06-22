DNS Query Resolution Policies specify how incoming resolution queries are handled by a DNS server.
#https://learn.microsoft.com/en-us/windows-server/networking/dns/deploy/dns-policies-overview

Add-DnsServerQueryResolutionPolicy
Remove-DnsServerQueryResolutionPolicy
Set-DnsServerQueryResolutionPolicy

## Requirements

- Target machine must be running Windows Server 2016 or later.


# DnsServerQueryResolutionPolicy

Inherit from DscResource.Base/source/Classes/010.ResourceBase.ps1



################### Query Resolution Policy elements ###########
# Name
Policy name
- Up to 256 characters
- Can contain any character valid for a file name

# State
Policy state
- Enable (default)
- Disabled

# Level
Policy level
- Server
- Zone

# Processing order
Once a query is classified by level and applies on, the server finds the first policy for which the query matches the criteria and applies it to query
- Numeric value
- Unique value per policy containing the same level and applies on value

# Action
Action to be performed by DNS server
- Allow (default for zone level)
- Deny (default on server level)
- Ignore

# Criteria
Policy condition (AND/OR) and list of criterion to be met for policy to be applied
- Condition operator (AND/OR)
- List of criteria (see the criterion table below)

# Scope
List of zone scopes and weighted values per scope. Weighted values are used for load balancing distribution. For instance, if this list includes datacenter1 with a weight of 3 and datacenter2 with a weight of 5 the server will respond with a record from datacentre1 three times out of eight requests
- List of zone scopes (by name) and weights

Also for Recursion Policy:
Name	Description
# Apply on recursion
Specifies that this policy should only be used for recursion.
# Recursion Scope
Name of the recursion scope.

########## CRITERIA FIELD #####
############## The DNS policy criteria field is composed of two elements:
Name	Description	Sample values
# Client Subnet
Name of a predefined client subnet. Used to verify the subnet from which the query was sent.
- EQ,Spain,France - resolves to true if the subnet is identified as either Spain or France
- NE,Canada,Mexico - resolves to true if the client subnet is any subnet other than Canada and Mexico

# Transport Protocol
Transport protocol used in the query. Possible entries are UDP and TCP
- EQ,TCP
- EQ,UDP

# Internet Protocol
Network protocol used in the query. Possible entries are IPv4 and IPv6
- EQ,IPv4
- EQ,IPv6

# Server Interface IP address
IP address for the incoming DNS server network interface
- EQ,10.0.0.1
- EQ,192.168.1.1

# FQDN
FQDN of record in the query, with the possibility of using a wild card
- EQ,www.contoso.com - resolves to true only the if the query is trying to resolve the www.contoso.com FQDN
- EQ,*.contoso.com,*.woodgrove.com - resolves to true if the query is for any record ending in contoso.com OR woodgrove.com

# Query Type
Type of record being queried (A, SRV, TXT)
- EQ,TXT,SRV - resolves to true if the query is requesting a TXT OR SRV record
- EQ,MX - resolves to true if the query is requesting an MX record

# Time of Day
Time of day the query is received
- EQ,10:00-12:00,22:00-23:00 - resolves to true if the query is received between 10 AM and noon, OR between 10PM and 11PM



########## Zone Transfer Policy elements #########
# Name
Policy name
- Up to 256 characters
- Can contain any character valid for a file name

# State
Policy state
- Enable (default)
- Disabled

# Internet Protocol
Network protocol used in the query. Possible entries are IPv4 and IPv6
- EQ,IPv4
- EQ,IPv6

# Processing order
Once a query is classified by level and applies on, the server finds the first policy for which the query matches the criteria and applies it to query
- Numeric value
- Unique value per policy containing the same level and applies on value

# Server Interface IP address
IP address for the incoming DNS server network interface
- EQ,10.0.0.1
- EQ,192.168.1.1

# Time of Day
Time of day the query is received
- EQ,10:00-12:00,22:00-23:00 - resolves to true if the query is received between 10 AM and noon, OR between 10PM and 11PM

# Transport Protocol
Transport protocol used in the query. Possible entries are UDP and TCP
- EQ,TCP
- EQ,UDP

# ZoneName
Specifies the name of a DNS zone on which this cmdlet creates a zone level policy. The zone must exist on the DNS server.

# Action
Specifies the action to take if a zone transfer matches this policy. The acceptable values for this parameter are:
- DENY. Respond with SERV_FAIL.
- IGNORE. Do not respond.

# ClientSubnet
Specifies the client subnet criterion. For more information, see Add-DnsServerClientSubnet. Specify a criterion in the following format:
operator, value01, value02, . . . , operator, value03, value04, . . .

The operator is either EQ or NE. You can specify no more than one of each operator in a criterion.

The policy treats values that follow the EQ operator as multiple assertions which are logically combined (OR'd). The policy treats values that follow the NE operator as multiple assertions which are logically differenced (AND'd). The criterion is satisfied if the subnet of the zone transfer matches one of the EQ values and does not match any of the NE values.

Example criterion: "EQ,NorthAmerica,Asia,NE,Europe"

# Condition
Specifies how the policy treats multiple criteria. The acceptable values for this parameter are:
- OR. The policy evaluates criteria as multiple assertions which are logically combined (OR'd).
- AND. The policy evaluates criteria as multiple assertions which are logically differenced (AND'd).
The default value is AND.
