table="users"
table=$1
service mysql stop
rm -rf /store/data/ib*
rm -rf /store/data/tapsg*
service mysql start
mysql -uroot -paaaa1111 -e "CREATE DATABASE \`tapsg_utf8\`;"
mysql -uroot -paaaa1111 tapsg_utf8 -e "CREATE TABLE $table(id int) engine=innodb;"
service mysql stop
/bin/cp -f /ifreeback/s3/tapsg_utf8/$table.frm /store/data/tapsg_utf8
chown -R mysql:mysql /store/data/tapsg_utf8/*
service mysql start
mysql -uroot -paaaa1111 tapsg_utf8 -e "FLUSH TABLES;"
mysqldump -uroot -paaaa1111 --lock-tables=false -d tapsg_utf8 > /ifreeback/$table.d.sql
mysql -uroot -paaaa1111 tapsg_utf8 < /ifreeback/$table.d.sql

service mysql stop
/bin/cp -f /ifreeback/s3/tapsg_utf8/$table.ibd /store/data/tapsg_utf8
chown -R mysql:mysql /store/data/tapsg_utf8/*
/ifreeback/percona-data-recovery-tool-for-innodb-0.5/ibdconnect -o /store/data/ibdata1 -f /store/data/tapsg_utf8/$table.ibd -d tapsg_utf8 -t $table

/ifreeback/percona-data-recovery-tool-for-innodb-0.5/innochecksum -f /store/data/ibdata1
/ifreeback/percona-data-recovery-tool-for-innodb-0.5/innochecksum -f /store/data/ibdata1

/ifreeback/percona-data-recovery-tool-for-innodb-0.5/innochecksum /store/data/ibdata1

service mysql start
mysqldump -uroot -paaaa1111 --lock-tables=false tapsg_utf8 $table > $table.sql
