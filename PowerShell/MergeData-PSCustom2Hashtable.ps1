
function MergeData-PSCustom2Hashtable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]
        $InputObject
        ,
        [Parameter(Mandatory)]
        [hashtable]
        $OutputObject
    )

    $InputObject.PSObject.Properties |% {
        if ($_.Value -is [PSCustomObject]) {
            $OutputObject[$_.Name] = @{}
            MergeData-PSCustom2Hashtable $_.Value $OutputObject[$_.Name]
        } else {
            $OutputObject[$_.Name] = $_.Value
        }
    }
}

