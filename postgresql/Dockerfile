From docker.io/postgres:12

WORKDIR /root

RUN apt update && apt -y install postgresql-12-mysql-fdw git

# tds_fdw
RUN apt update && apt -y install libsybdb5 freetds-dev freetds-common gnupg gcc make wget postgresql-server-dev-12 unzip

RUN git clone https://github.com/tds-fdw/tds_fdw.git
# COPY postgresql/import_view.patch tds_fdw
# RUN cd tds_fdw && patch -p1 < import_view.patch
RUN cd tds_fdw && make clean && make USE_PGXS=1 && make USE_PGXS=1 install

# oracle_fdw
RUN apt update && apt -y install alien libaio1
RUN wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm
RUN wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm
RUN alien oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm
RUN alien oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm
RUN dpkg -i oracle-instantclient*.deb
RUN git clone https://github.com/laurenz/oracle_fdw.git
RUN cd oracle_fdw && make && make install

# odbc_fdw
# https://qiita.com/arachan@github/items/5863c945dbe7507975d8
# isql -v mssql sa p@ssw0rd!
RUN apt update && apt -y install odbc-postgresql unixodbc-dev freetds-common tdsodbc unixodbc
RUN git clone https://github.com/CartoDB/odbc_fdw.git
RUN cd odbc_fdw && make && make install
COPY postgresql/driver.template /root/
COPY postgresql/dsn.template /root/
RUN odbcinst -i -d -f driver.template
RUN odbcinst -i -s -l -f dsn.template

# jdbc_fdw
COPY postgresql/jdbc/ /jdbc
RUN apt update && apt -y install openjdk-11-jdk
RUN git clone https://github.com/atris/JDBC_FDW.git
RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64/lib/server/libjvm.so /usr/lib/libjvm.so
RUN cd JDBC_FDW && USE_PGXS=1 make && USE_PGXS=1 make install
# RUN git clone https://github.com/heimir-sverrisson/jdbc2_fdw.git
# RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64/lib/server/libjvm.so /usr/lib/libjvm.so
# RUN cd jdbc2_fdw && USE_PGXS=1 make && USE_PGXS=1 make install
