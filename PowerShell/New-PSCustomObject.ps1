
# > New-PSCustomObject @{f1=' a';f2=' b';f3=' c';meta='three little fields'} -DefProps f1,f2,f3

function New-PSCustomObject {
	[CmdletBinding()]

	param (

	[Parameter(Mandatory,Position=0)]
	[ValidateNotNullOrEmpty()]
	[System.Collections.Hashtable]$Hsh,

	[Parameter(Position=1)]
	[ValidateNotNullOrEmpty()]
	[Alias('def')]
	[System.String[]]$DefProps
	)

	$result = [PSCustomObject]$Hsh

	if (-not $DefProps) { return $result }

	$ddps = New-Object System.Management.Automation.PSPropertySet `
			DefaultDisplayPropertySet, $DefProps

	$result | Add-Member -MemberType MemberSet -Name PSStandardMembers `
			-Value ([Management.Automation.PSMemberInfo[]]$ddps) `
			-PassThru
}

