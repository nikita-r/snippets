#·syn.psh

Get-TypeName -f $v
??{}{}{}
function ?? ( [scriptblock]$PossiblyNil, [scriptblock]$ExecIfNil = $(throw) ) {
    ${??}=@(Invoke-Command $PossiblyNil) |? {![string]::IsNullOrWhiteSpace($_)}
    if (@(${??}).Count) { return ${??} }
    ${??}=@(Invoke-Command $ExecIfNil) |? {![string]::IsNullOrWhiteSpace($_)}
    return ${??}
}

Get-Process |? Name -eq 'system' | select @{N='PID';E={$_.id}}, handles | ConvertTo-Csv -NoTypeInformation

[].DeclaredProperties | sort Name | select Name, Can*
[].DeclaredFields | sort Name | select IsPublic, Name, IsStatic, FieldType
[].DeclaredMethods | sort Name | select IsPublic, Name, IsStatic, ReturnType

foreach ($property in ($object.PSObject.Properties.Name | sort)) {
    Write-Host; Write-Host ('~' * $property.Length)
    Write-Host $property
    Write-Host $object.$property
} ; Write-Host

gci $· |% LastWriteTime |% { '{0:yyyy-MM-dd}' -f $_ } | sort -Unique
gci $· |% Extension |% ToUpper | sort -u
gci $· | group Extension -NoElement | sort Name

gc Function:\prompt

$list = New-Object Collections.Generic.List[Object]
$list.Add
$list.ToArray()

$dict = [Collections.Generic.Dictionary`2[string,string]]::new()
$($dict.GetEnumerator()) |% {
    $arr = $_.Key.ToCharArray()
    [array]::Reverse($arr)
    $dict.Add(-join($arr), $_.Value) # $arr -join $null
    [void]$dict.Remove($_.Key)
}

$A += ,@($AinA)

$hash.Count -eq ( compare ($hash | select -Expand Values) ($hash.GetEnumerator() | select -Expand Value) -IncludeEqual ).Count
compare @() @() -IncludeEqual -ExcludeDifferent -PassThru
[linq.enumerable]::Intersect([object[]]@(), [object[]]@())

[System.IO.File]::ReadLines('d:\Absolute\Path\to\theFile.txt') |% {}

$str = [io.StreamWriter] 'tmp.txt'
$str.WriteLine
$str.Dispose()


(Get-Date (Get-Date).ToUniversalTime() -f s) + '.000Z'

$timePoint = (Get-Date).AddMinutes(-5)
((Get-Date $timePoint -f:ss) -ge '30')
(Get-Date $timePoint -Second 0 -f s) + '.000Z'

([System.DateTime]::Now - $timePoint).TotalSeconds # [TimeSpan]

Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
[datetime]::Today


# modify hashtable values in-place
$hsh = @{ aud="https://management.core.windows.net/" }
# opt A
$hsh = $hsh.Keys |% { $rez = @{} }{ $rez[$_] = [Net.WebUtility]::UrlEncode($hsh[$_]) }{ $rez }
# opt B
foreach ($key in $($hsh.Keys)) { $hsh[$key] = [Net.WebUtility]::UrlEncode($hsh[$key]) }
# end opt


#Requires -Version 5
using namespace System.Management.Automation.Internal
[AutomationNull]::Value -is [psobject]
@([AutomationNull]::Value).Count -eq 0
[AutomationNull]::Value -isNot [AutomationNull]
[AutomationNull]::Value -eq $null

<# all the pretty nulls #>
[System.DBNull]::Value -isNot [psobject]
@( $null ).Count -eq 1
[System.DBNull]::Value -is [System.DBNull]
[System.DBNull]::Value -ne $null

[System.DBNull]::Value -ne [NullString]::Value

[System.DBNull]::Value -ne [string]::Empty
[NullString]::Value -ne [string]::Empty
<#~cmp~#>
[string]::Empty -eq [System.DBNull]::Value
[string]::Empty -ne [NullString]::Value

<# see https://github.com/PowerShell/PowerShell/pull/9794 #>


$head, $null = $a # or $head = @($a)[0]; thou shalt not rely on $a[0]


<# regex #>
[regex]::Match($str, [regex]::Escape($LiteralPattern) + '(?:)', [Text.RegularExpressions.RegexOptions] 'IgnoreCase, CultureInvariant').Groups[1].Value


1.49999999999999989 -as 'int-apprx' -eq 2
1.4999999999999999 -as 'int-banker' -eq 2
1.499999999999999 -as 'int-nearest' -eq 1


