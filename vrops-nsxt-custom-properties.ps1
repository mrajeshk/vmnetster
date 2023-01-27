Import-Module VMware.VimAutomation.vROps

$nsxt_username = "admin"
$nsxt_password = "password"
$nsxtFQDN ="site-a-nsx.domain.local"

$esxiHost = $null

$vropsFQDN="vrops.domain.local"
$vrops_username ="admin"
$vrops_password="password"

$nsxtProperties = @{}


$PWord = ConvertTo-SecureString -String $nsxt_password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $nsxt_username, $PWord



Function getNSXTNodeProperties()
{
param(
[Parameter (Mandatory = $false)] [String]$hostID
     )
$hostUID= ""
#Write-Host($hostID)
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", 'application/json')
$headers.Add("Accept", 'application/json')
$uri = "https://{0}/policy/api/v1/infra/sites/default/enforcement-points/default/host-transport-nodes/{1}" -f $nsxtFQDN,$hostID
#$uri ="https://site-a-nsx/policy/api/v1/infra/sites/default/enforcement-points/default/host-transport-nodes/site-a-esxi01.corp.local"
#Write-Host($uri)
$res = Invoke-RestMethod -Uri $uri -Headers $header -Method 'GET' -Authentication:Basic -Credential $Credential -SkipCertificateCheck
$hostUID=$res.unique_id

$uri = "https://{0}/policy/api/v1/transport-nodes/{1}/status" -f $nsxtFQDN, $hostUID
$res = Invoke-RestMethod -Uri $uri -Headers $header -Method 'GET' -Authentication:Basic -Credential $Credential -SkipCertificateCheck

$nsxtProperties['version'] = $res.node_status.software_version
$nsxtProperties['nsx_agent'] = $res.agent_status.status
$nsxtProperties[$res.agent_status.agents[0].name] = $res.agent_status.agents[0].status
$nsxtProperties[$res.agent_status.agents[1].name] = $res.agent_status.agents[1].status
$nsxtProperties[$res.agent_status.agents[2].name] = $res.agent_status.agents[2].status
$nsxtProperties['lcp_connectivity_status'] = $res.node_status.lcp_connectivity_status
$nsxtProperties['mpa_connectivity_status'] = $res.node_status.mpa_connectivity_status
$nsxtProperties['tunnel_status'] = $res.tunnel_status.status
$nsxtProperties['tunnel_up'] = $res.tunnel_status.up_count
$nsxtProperties['tunnel_down'] = $res.tunnel_status.down_count
$nsxtProperties['host_node_deployment_status'] = $res.node_status.host_node_deployment_status
#Write-Host($res.tunnel_status.up_count)
}

#Write-Host($nsxtProperties)
#Write-Host("version" + " "+ $res.node_status.software_version)
#Write-Host("agent" + " " + $res.agent_status.status)
#Write-Host($res.agent_status.agents[0].name + " "+ $res.agent_status.agents[0].status)
#Write-Host($res.agent_status.agents[1].name + " "+ $res.agent_status.agents[1].status)
#Write-Host($res.agent_status.agents[2].name + " "+ $res.agent_status.agents[2].status)
#Write-Host("lcp_connectivity_status" + " "+ $res.node_status.lcp_connectivity_status)
#Write-Host("mpa_connectivity_status" + " "+ $res.node_status.mpa_connectivity_status)
#Write-Host("tunnel_statu" + " "+ $res.node_status.tunnel_statu.status)
#Write-Host("tunnel_up" + " "+ $res.node_status.tunnel_statu.up_count)
#Write-Host("tunnel_down" + " "+ $res.node_status.tunnel_statu.down_count)
#Write-Host("host_node_deployment_status" + " "+ $res.node_status.host_node_deployment_status)



#Write-Host("befor run")
#Write-Host($nsxtProperties)

Function setvROPSNSXTProperties()
{
param(
[Parameter (Mandatory = $false)] [String]$hostID
     )
     #Write-Host("vROPS " + $hostID)
     $esxiHost = Get-OMResource -name $hostID -ResourceKind HostSystem
     foreach ($nsxtPropertie in $nsxtProperties.GetEnumerator() )
{
 # Write-Host "$($nsxtPropertie.Name) : $($nsxtPropertie.Value)"

$customProperties = New-Object VMware.VimAutomation.VROps.Views.PropertyContents
$customProperty = New-Object VMware.VimAutomation.VROps.Views.PropertyContent
$customProperty.StatKey = "nsxt|"+$nsxtPropertie.Name
$customProperty.Values = @($nsxtPropertie.Value)
$customProperty.Timestamps = 1605764821000
$customProperties.Propertycontent = @($customProperty)
$customProperty
$customProperties
$esxiHost.ExtensionData.AddProperties($customProperties)

$customProperty = $null
$customProperties = $null

}
     #$esxiHost
}

Connect-OMServer $vropsFQDN -User $vrops_username -Password $vrops_password

getNSXTNodeProperties -hostID $esxiNode
setvROPSNSXTProperties -hostID $esxiNode

#Write-Host("Veriosn vROPS" + $nsxtProperties['version'])


#Write-Host($nsxtcustomProperties.Propertycontent)

Disconnect-OMServer $vropsFQDN -confirm:$false

#Write-Host("after run")
#Write-Host($nsxtProperties)

#foreach ($nsxtPropertie in $nsxtProperties.GetEnumerator() )
#{
 # Write-Host "$($nsxtPropertie.Name) : $($nsxtPropertie.Value)"
#}

