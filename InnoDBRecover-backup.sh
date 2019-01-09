#!/bin/bash
    USER=$1
    echo "checking for $USER ..."
    if [ -f /backup/2019-01-04/accounts/$USER.tar.gz ]; then
        cd /home/juniorriau/ && tar -zxf /backup/2019-01-04/accounts/$USER.tar.gz;
        touch /home/juniorriau/$USER-exist.txt;
    elif [ -f /backup/2019-01-01/accounts/$USER.tar.gz ]; then
        cd /home/juniorriau/ && tar -zxf /backup/2019-01-01/accounts/$USER.tar.gz;
        touch /home/juniorriau/$USER-exist.txt;
    else
        wget -o /home/juniorriau/$USER.tar.gz -c http://45.127.134.149/hercules/2019-01-01/accounts/$USER.tar.gz
        cd /home/juniorriau && tar -zxf $USER.tar.gz
        touch /home/juniorriau/$USER-exist.txt;
    fi
    if [ -f /home/juniorriau/$USER-exist.txt ];then
        for db in `mysql -e"show databases like '%$USER%'"| egrep -v "Database";`
        do
            echo "checking database $db ..."
            mysqlcheck --database --repair $db > $db.clog;
            if grep -q "doesn't exist in engine" $db.clog; then
                echo "restoring $db ..."
                if [ -f /home/juniorriau/$USER/mysql/$db.create ]; then
                    yes | cp -r /var/lib/mysql/$db /home/innodbtest/$db;
                    rm /var/lib/mysql/$db -rf;
                    mysql -e "drop database $db";
                    mysql -u root < /home/juniorriau/$USER/mysql/$db.create;
                    mysql -u root $db < /home/juniorriau/$USER/mysql/$db.sql;
                fi
            fi
        done
        mysql -u root < /home/juniorriau/$USER/mysql.sql;
        echo "restore done, deleting backup extract ..."
        cd /home/juniorriau && rm /home/juniorriau/$USER -rf;
    fi
