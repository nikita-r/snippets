set -fux -o pipefail
set -e # $ErrorActionPreference='Exit'
false

# Which process occupies port 4001?
lsof -i:4001

# prepend timestamp to each line of the <command> output
command | gawk '{ print strftime(" %Y-%m-%d %H:%M:%S . . .", systime(), 1), $0; fflush(); }'

# grep recursively from root
echo "find / -xdev -not \( -type d -path '*/exclude/dir' -prune \) -type f -print0 | xargs -0 grep -HIP '^*$'" | sudo sh
sudo grep --devices=skip -IP -e '^*$' -r /

# clear terminal and erase scrollback
echo -en '\033c'

# allow use of aliases with sudo
alias sudo='sudo '

# highlight <word> in the <command> output in less
command | grep --colour=always -e $ -e word | less -R

# eject media
sudo mount -o remount,rw /media/kr/Verbatim
sudo -s -- 'sync; umount /media/kr/Verbatim'

# grep thru files with some pre-processing
for f in $(...); do tr -d '\r' < $f | egrep -Hn "\s+$" | sed s#^\(standard\ input\)#$f#; done

# find all lib icu sos; pad the size column; sort by name (*.so.1 goes before *.so?)
find /usr/lib -name 'libicu*' -exec ls -dl {} \; | awk '{ $5=sprintf("%011d", $5) }5' | sort -k9 | less -S

# dos2unix
IFS=$'\n'; set -o noglob
for f in $(find ./Folder -type f | sort); do sed -i 's/\r$//g' $f; done
unset IFS; set +f

# Who used up my disk space?
du -b -x / | awk '{ $1=sprintf("%015d", $1) }1' | sort -r | more

# list all variables
( set -o posix ; set ) | less

# set file-mode and replace CRLF in newly-fetched files
find . -mindepth 1 -type d -print0 | xargs -0r -t chmod ???
find . -type f -print0 | xargs -0r -n1 sh -cx 'sed -i "s/\r\$//" "$1" && chmod a=r "$1"' --

