set -xuef

# Which process occupies port 4001?
lsof -i:4001

# prepend timestamp to each line of the <command> output
command | gawk '{ print strftime(" %Y-%m-%d %H:%M:%S . . .", systime(), 1), $0; fflush(); }'

# grep recursively from root
echo "find / -xdev -not \( -type d -path '*/exclude/dir' -prune \) -type f -print0 | xargs -0 grep --color -HIP 'regexp'" | sudo sh
sudo grep --color --devices=skip -RIP "regexp" /

# clear terminal and erase scrollback
echo -en '\033c'

# allow use of aliases with sudo
alias sudo='sudo '

# highlight <word> in the <command> output in less
command | grep --colour=always -e $ -e word | less -r

# flush to the history file after each command
export PROMPT_COMMAND='history -a'

# eject media
sudo mount -o remount,rw /media/kr/Verbatim
sudo -s -- 'sync; umount /media/kr/Verbatim'

# find trailing whitespace in source files without choking on CR+LF
IFS=$'\n'; set -f
for f in $(find . -name '*.cpp' -or -name '*.h' | sort); do tr -d '\r' < $f | egrep -Hn "\s+$" | sed s#^\(standard\ input\)#$f#; done
unset IFS; set +f

# find all lib icu sos; pad the size column; sort by name (*.so.1 goes before *.so?)
find /usr/lib -name 'libicu*' -exec ls -dl {} \; | awk '{ $5=sprintf("%011d", $5) }5' | sort -k9 | less -S

# dos2unix
IFS=$'\n'; set -o noglob
for f in $(find ./Folder -type f | sort); do sed -i 's/\r$//g' $f; done
unset IFS; set +f

# Who used up my disk space?
du -b -x / | awk '{ $1=sprintf("%015d", $1) }1' | sort -r | more

