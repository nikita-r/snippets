@echo off

	if -%2-==-- (
tasklist /fi "ImageName eq %1.exe" /fo list /v
echo:
	) else (
		if -%1-==-p- (
wmic process where name='%2.exe' get CreationClassName, CreationDate, ParentProcessId, ProcessId, ExecutablePath /format:list
		)
		if -%1-==-t- (
tasklist /fi "WindowTitle eq %2*" /fo list /v
echo:
		)
		if -%1-==-i- (
tasklist /fi "pid eq %2" /fo list /v
echo:
		)
	)

