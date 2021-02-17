
# forward localhost:$port to $host2:$port2, where $host2 belongs to $net and is with $port2 unexposed
docker run -d --name $hostname -p $port:80 --net $net $img socat TCP-LISTEN:80,fork TCP:$host2:$port2

