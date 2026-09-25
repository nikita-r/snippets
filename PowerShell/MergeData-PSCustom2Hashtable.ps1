
function MergeData-psCustom2Hashtable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psCustomObject]
        $InputObject
        ,
        [Parameter(Mandatory)]
        [hashtable]
        $rzlt = @{}
    )

    $InputObject.psObject.Properties |% {
        if ($_.Value -is [psCustomObject]) {
            $rzlt[$_.Name] = @{}
            MergeData-PSCustom2Hashtable $_.Value $rzlt[$_.Name]
        } else {
            $rzlt[$_.Name] = $_.Value
        }
    }

    return $rzlt
}

