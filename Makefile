build:
	docker-compose build
	
up:
	docker-compose up -d
	
stop:
	docker-compose stop
	
psql:
	docker-compose exec postgresql psql -U postgres
	
init_oracle:
	docker-compose exec oracle11g /bin/bash -i -c "sqlplus system/oracle @/root/oracle/create_user.sql"
	docker-compose exec oracle11g /bin/bash -i -c "sqlplus ora_user/oracle @/root/oracle/init_table.sql"
	
	docker-compose exec postgresql psql -U postgres -c "DROP SCHEMA IF EXISTS oracle_schema cascade;"
	docker-compose exec postgresql psql -U postgres -c "DROP SERVER IF EXISTS oracle_server cascade;"
	
	docker-compose exec postgresql psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS oracle_fdw;"
	docker-compose exec postgresql psql -U postgres -c "CREATE SERVER oracle_server FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '//oracle11g:1521/XE');"
	docker-compose exec postgresql psql -U postgres -c "CREATE USER MAPPING FOR postgres SERVER oracle_server OPTIONS( user 'ora_user', password 'oracle');"
	docker-compose exec postgresql psql -U postgres -c "CREATE SCHEMA oracle_schema;"
	docker-compose exec postgresql psql -U postgres -c "IMPORT FOREIGN SCHEMA \"ORA_USER\" FROM SERVER oracle_server INTO oracle_schema;"
	
init_mysql:
	docker-compose exec mysql mysql -u root --password=root -e "DROP DATABASE if exists fdw_test;"
	docker-compose exec mysql mysql -u root --password=root -e "CREATE DATABASE fdw_test;"
	docker-compose exec mysql mysql -u root --password=root -e "CREATE TABLE fdw_test.test(id int primary key, name text);"
	docker-compose exec mysql mysql -u root --password=root -e "INSERT INTO fdw_test.test values (1, 'mysql1');"
	docker-compose exec mysql mysql -u root --password=root -e "INSERT INTO fdw_test.test values (2, 'mysql2');"
	
	docker-compose exec postgresql psql -U postgres -c "DROP SCHEMA IF EXISTS mysql_schema cascade;"
	docker-compose exec postgresql psql -U postgres -c "DROP SERVER IF EXISTS mysql_server cascade;"
	
	docker-compose exec postgresql psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS mysql_fdw;"
	docker-compose exec postgresql psql -U postgres -c "CREATE SERVER mysql_server FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host 'mysql', port '3306');"
	docker-compose exec postgresql psql -U postgres -c "CREATE USER MAPPING FOR postgres SERVER mysql_server OPTIONS( username 'root', password 'root');"
	docker-compose exec postgresql psql -U postgres -c "CREATE SCHEMA mysql_schema;"
	docker-compose exec postgresql psql -U postgres -c "IMPORT FOREIGN SCHEMA fdw_test FROM SERVER mysql_server INTO mysql_schema;"

	
init_mssql:
	docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -U SA -P p@ssw0rd! -Q "DROP SCHEMA if exists fdw_test cascade;"
	docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -U SA -P p@ssw0rd! -Q "CREATE SCHEMA fdw_test;"
	docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -U SA -P p@ssw0rd! -Q "CREATE TABLE fdw_test.test(id int primary key, name text);"
	docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -U SA -P p@ssw0rd! -Q "INSERT INTO fdw_test.test values (1, 'SQL Server1');"
	docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -U SA -P p@ssw0rd! -Q "INSERT INTO fdw_test.test values (2, 'SQL Server2');"
	
	docker-compose exec postgresql psql -U postgres -c "DROP SCHEMA IF EXISTS mssql_schema cascade;"
	docker-compose exec postgresql psql -U postgres -c "DROP SERVER IF EXISTS mssql_server cascade;"
	
	docker-compose exec postgresql psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS tds_fdw;"
	docker-compose exec postgresql psql -U postgres -c "CREATE SERVER mssql_server FOREIGN DATA WRAPPER tds_fdw OPTIONS (servername 'mssql', port '1433');"
	docker-compose exec postgresql psql -U postgres -c "CREATE USER MAPPING FOR postgres SERVER mssql_server OPTIONS( username 'sa', password 'p@ssw0rd!');"
	docker-compose exec postgresql psql -U postgres -c "CREATE SCHEMA mssql_schema;"
	docker-compose exec postgresql psql -U postgres -c "IMPORT FOREIGN SCHEMA fdw_test FROM SERVER mssql_server INTO mssql_schema;"

init_odbc:
	docker-compose exec postgresql psql -U postgres -c "DROP SCHEMA IF EXISTS odbc_schema cascade;"
	docker-compose exec postgresql psql -U postgres -c "DROP SERVER IF EXISTS odbc_server cascade;"
	
	docker-compose exec postgresql psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS odbc_fdw;"
	docker-compose exec postgresql psql -U postgres -c "CREATE SERVER odbc_server FOREIGN DATA WRAPPER odbc_fdw OPTIONS (dsn 'mssql');"
	docker-compose exec postgresql psql -U postgres -c "CREATE USER MAPPING FOR postgres SERVER odbc_server OPTIONS( odbc_UID 'sa', odbc_PWD 'p@ssw0rd!');"
	docker-compose exec postgresql psql -U postgres -c "CREATE SCHEMA odbc_schema;"
	docker-compose exec postgresql psql -U postgres -c "IMPORT FOREIGN SCHEMA fdw_test FROM SERVER odbc_server INTO odbc_schema;"
	
init_jdbc:
	docker-compose exec postgresql psql -U postgres -c "DROP SCHEMA IF EXISTS jdbc_schema cascade;"
	docker-compose exec postgresql psql -U postgres -c "DROP SERVER IF EXISTS jdbc_server cascade;"
	
	docker-compose exec postgresql psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS jdbc_fdw;"
	docker-compose exec postgresql psql -U postgres -c "CREATE SERVER jdbc_server FOREIGN DATA WRAPPER jdbc_fdw OPTIONS (drivername 'com.mysql.cj.jdbc.Driver', url 'jdbc:mysql://mysql/fdw_test', jarfile '/jdbc/mysql-connector-java-8.0.25.jar');"
	docker-compose exec postgresql psql -U postgres -c "CREATE USER MAPPING FOR postgres SERVER jdbc_server OPTIONS( username 'root', password 'root');"
	docker-compose exec postgresql psql -U postgres -c "CREATE SCHEMA jdbc_schema;"
	# docker-compose exec postgresql psql -U postgres -c "IMPORT FOREIGN SCHEMA fdw_test FROM SERVER jdbc_server INTO jdbc_schema;"
	docker-compose exec postgresql psql -U postgres -c "CREATE FOREIGN TABLE jdbc_schema.test (id int,name text) SERVER jdbc_server OPTIONS (table 'test');"

init: init_mysql init_mssql init_odbc init_oracle init_jdbc

