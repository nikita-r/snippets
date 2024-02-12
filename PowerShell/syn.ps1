# syn.ps1

Get-TypeName -f $v
??{}{}{}
function ?? ( [scriptblock]$PossiblyNil, [scriptblock]$ExecIfNil = $(throw) ) {
    ${??}=@(Invoke-Command $PossiblyNil) |? {![string]::IsNullOrWhiteSpace($_)}
    if (@(${??}).Count) { return ${??} }
    ${??}=@(Invoke-Command $ExecIfNil) |? {![string]::IsNullOrWhiteSpace($_)}
    return ${??}
}

Get-Process |? Name -eq 'system' | select @{N='PID';E={$_.id}}, handles | ConvertTo-Csv -NoTypeInformation

function Get-StrictMode { # Set-StrictMode -Version:0
  try { $arr=@(1); $arr[1] } catch { return 3 } # -Version:Latest
  try { "Not-a-Date".Year } catch { return 2 }
  try { $local:undefined } catch { return 1 }
  return 0 # Set-StrictMode -Off
}

foreach ($property in ($object.psObject.Properties.Name | Sort-Object)) {
    Write-Host ( '_' * <#$property.Length#>77 )
    Write-Host $property
    Write-Host ( '-' * <#$property.Length#>77 )
    Write-Host $object.$property
} ; Write-Host ( '~' + '*~*~' * 19 )

gci $_ |% LastWriteTime |% { '{0:yyyy-MM-dd}' -f $_ } | Sort-Object -Unique
gci $_ |% Extension |% ToUpper | sort -u
gci $_ | group Extension -NoElement | Sort-Object Name

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


<# on System.Array wrapping antics #>

$A += ,@($AinA) # comma prevents unwrap

<#
## ',' binds tighter than '/' when constructing @(), but
## not in a method call; [type] is tighter in both cases
#>

Remove-TypeData System.Array # avoid "value"/"Count" in `ConvertTo-Json` output
<# alternatively #> ($array | ...).psObject.BaseObject | ConvertTo-Json

<# and generally,
## for the output of `ConvertFrom-Json`, make sure to access the underlying
## dotnet object, so that eg Select-Object works as expected #>
(... | ConvertFrom-Json).psObject.BaseObject


Compare-Object @() @() -IncludeEqual -ExcludeDifferent -PassThru
[linq.enumerable]::Intersect([object[]]@(), [object[]]@())

$idx = 0; $series = New-Object Collections.Generic.List[PSCustomObject]
while (1) {
    sleep 1
    Write-Host (++$idx).ToString('00000')
    $object = Get-Object ... -ea:Continue
    if (!$?) { continue }
    $series.Add(($object | Select-Object *))
    if ($series.Count -le 1) { continue }
    $comparison = Compare-Object -ReferenceObject @($series[-2]) -DifferenceObject @($series[-1]) `
            -Property <#Id,#>Name,Type,...
    $isDifferent = !!(@($comparison.SideIndicator) -ne '==')
    if ($isDifferent) { Write-Host Difference at $series.Count }
}


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
@([AutomationNull]::Value).Count -eq 0
[AutomationNull]::Value -is [psobject]
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


[version] '0.0' -lt [version] '0.0.0' # better supply all four numbers
# Major  Minor  Build  Revision
# -----  -----  -----  --------
#     0      0     -1        -1


<# Only 'select' would work as expected with any kind of Collection #>
$head, $null = $a # thou shalt not rely on $a[0]
$head = @($a)[0]
$rest = @($a | select -Skip 1) #.GetType().ToString() -ceq 'System.Object[]'


$reOpt = [Text.RegularExpressions.RegexOptions] 'IgnoreCase, CultureInvariant'
$rePat = [regex]::Escape($LiteralPattern) + '(?<rep>\W+)' + '(?:)' + '\k<rep>'
$value = [regex]::Match($str, $rePat, $reOpt).Groups[1].Value
$value -is [string] # $value='' if group does not exist


1.49999999999999989 -as 'int-apprx' -eq 2
1.4999999999999999 -as 'int-banker' -eq 2
1.499999999999999 -as 'int-nearest' -eq 1


