./azcopy --version | Select-Object -First 1

(./azcopy cp $src/* $dst/NewFolder | Tee-Object -Variable outputAzCopy).Where({$_-match' summary$'},'sk')
if (-not $?) { throw 'azcopy: ' + ($outputAzCopy | Select-String '^(failed|RESPONSE) ' -CaseSensitive |% Line) }

