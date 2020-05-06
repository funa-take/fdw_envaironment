drop user ora_user cascade;
create user ora_user identified by oracle;
grant connect to ora_user;
grant create table to ora_user;
GRANT UNLIMITED TABLESPACE TO ora_user;
quit;
