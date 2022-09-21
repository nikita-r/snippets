function Using-Object {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,

        [Parameter(Mandatory)]
        [scriptblock]
        $ScriptBlock
    )

    try {
        . $ScriptBlock
    } finally {
        if ($InputObject -is [IDisposable]) { $InputObject.Dispose() }
    }
}
