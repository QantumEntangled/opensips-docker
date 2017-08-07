spawn opensipsdbctl create
expect "MySQL password for root: "
send "mysql\n"
expect EOF
