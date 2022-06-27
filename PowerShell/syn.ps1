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

[].DeclaredProperties | Sort-Object Name | select Name, Can*
[].DeclaredFields | Sort-Object Name | select IsPublic, Name, IsStatic, FieldType
[].DeclaredMethods | Sort-Object Name | select IsPublic, Name, IsStatic, ReturnType

foreach ($property in ($object.PSObject.Properties.Name | Sort-Object)) {
    Write-Host; Write-Host ('~' * $property.Length)
    Write-Host $property
    Write-Host $object.$property
} ; Write-Host

gci $· |% LastWriteTime |% { '{0:yyyy-MM-dd}' -f $_ } | Sort-Object -Unique
gci $· |% Extension |% ToUpper | sort -u
gci $· | group Extension -NoElement | Sort-Object Name

gc Function:\prompt

<# modify Hashtable keys in-place #>
$dict = [Collections.Generic.Dictionary`2[string,string]]::new()
$($dict.GetEnumerator()) |% { # without $(), the IEnumerator would be invalidated upon iteration
    $arr = $_.Key.ToCharArray()
    [array]::Reverse($arr)
    $dict.Add(-join($arr), $_.Value) # $arr -join $null
    [void]$dict.Remove($_.Key)
}

<# modify values #>
$hsh = @{ aud="https://management.core.windows.net/" }
<# A #> $hsh = $hsh.Keys |% { $rez = @{} }{ $rez[$_] = [Net.WebUtility]::UrlEncode($hsh[$_]) }{ $rez }
<# B #> foreach ($key in $($hsh.Keys)) { $hsh[$key] = [Net.WebUtility]::UrlEncode($hsh[$key]) }


$list = New-Object Collections.Generic.List[Object]
$list.Add
$list.ToArray()

$A += ,@($AinA)

Compare-Object @() @() -IncludeEqual -ExcludeDifferent -PassThru
[linq.enumerable]::Intersect([object[]]@(), [object[]]@())


[io.file]::ReadAllLines('d:\Absolute\Path\to\theFile.txt') |% {}
[io.file]::WriteAllLines('d:\Absolute\Path\to\theFile.txt', $content) # utf8 by default (even in PowerShell v5)

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


using namespace System.Management.Automation.Internal
[AutomationNull]::Value -is [psobject]
@([AutomationNull]::Value).Count -eq 0
[AutomationNull]::Value -isNot [AutomationNull]
[AutomationNull]::Value -eq $null

[System.DBNull]::Value -isNot [psobject]
[System.DBNull]::Value -is [System.DBNull]
[System.DBNull]::Value -ne $null
[System.DBNull]::Value -ne [string]::Empty
[string]::Empty -eq [System.DBNull]::Value

[string]::Empty -ne [NullString]::Value

<# After merging of https://github.com/PowerShell/PowerShell/pull/9794
   was #> 1 -eq -not [DBNull]::Value
<# But reverted by https://github.com/PowerShell/PowerShell/pull/11648
   so #> 0 -eq -not [DBNull]::Value


$head, $null = $a # or $head = @($a)[0]; thou shalt not rely on $a[0]


$reOpt = [Text.RegularExpressions.RegexOptions] 'IgnoreCase, CultureInvariant'
$rePat = [regex]::Escape($LiteralPattern) + '(?:)'
[regex]::Match($str, $rePat, $reOpt).Groups[1].Value


1.49999999999999989 -as 'int-apprx' -eq 2
1.4999999999999999 -as 'int-banker' -eq 2
1.499999999999999 -as 'int-nearest' -eq 1


