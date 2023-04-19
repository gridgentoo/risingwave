USE mydb;

GRANT ALL PRIVILEGES ON mydb.* TO 'mysqluser';

CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'mysqlpw';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

FLUSH PRIVILEGES;
