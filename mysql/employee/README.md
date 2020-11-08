[Employees Sample Database](https://dev.mysql.com/doc/employee/en/employees-preface.html)

Script downloads the required SQL dump files from GitHub into the sql_dump directory if it does not exist. 
The size of the dump files and the sample database is about 160MB. 
The script always downloads the dump files if it is necessary.
On the other hand the dump files will be always imported which takes some time. 

Connection

    - Host: localhost 127.0.0.1
    - Port: 3306
    - User: root
    - Pass: secret  see $MYSQL_ROOT_PASSWORD
    - DB: employees
