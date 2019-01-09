#!/bin/sh
echo "install package depedencies ..."
yum update -y
yum install perl wget -y
echo "Downloading cPanel Installer..."
cd /home
wget -N httpupdate.cpanel.net/latest
sh latest
echo "Getting cldeploy..."
wget https://repo.cloudlinux.com/cloudlinux/sources/cln/cldeploy
echo "Converting CentOS to CloudLinux..."
sh cldeploy -i
echo "Installing the package..."
yum install cagefs lvemanager lve-stats -y
yum groupinstall alt-php -y
echo "Updating php.ini..."
cd /opt/
for f in `find ./ -name php.ini`
do
    echo "convert execution"
    replace ";max_execution_time = 30" "max_execution_time = 128" -- $f
    replace "max_execution_time = 30" "max_execution_time = 128" -- $f
    echo "convert memory"
    replace ";memory_limit = 32M" "memory_limit = 128M" -- $f
    echo "convert post size"
    replace "post_max_size = 8M" "post_max_size = 128M" -- $f
    echo "convert upload size"
    replace "upload_max_filesize = 2M" "upload_max_filesize = 128M" -- $f
    echo "convert date time"
    replace "UTC" "Asia/Jakarta" -- $f
    replace ";date.timezone =" "date.timezone = 'Asia/Jakarta'" -- $f
    echo "convert disable function"
    replace "disable_functions =" "disable_functions =mail,show_source,symlink,system,shell_eval,define_syslog_variables,syslog,openlog,closelog,passthru,ocinumcols,ini_alter,leak,listen,chgrp,apache_note,apache_setenv,debugger_on,debugger_off,ftp_dl,dll,ftp,myshellsocket_bind,popen,fpassthru,pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_pcntl_getpriority,pcntl_setpriority,str_rot13" -- $f
    echo "convert enable dl"
    replace "enable_dl = On" "enable_dl = Off" -- $f
    echo "convert allow_url_fopen "
    replace "allow_url_fopen = Off" "allow_url_fopen = On" -- $f
done;
echo "Change Directive PHP Configuration\n"
echo "
Directive = max_input_vars
Default   = 100
Type	  = value
Comment   = The number of max input for PHP

Directive = suhosin.post.max_vars
Default   = 100
Type	  = value
Comment   = Suhosin max posts

Directive = suhosin.request.max_vars
Default   = 100
Type	  = value
Comment   = Suhosin max requests

Directive = suhosin.get.max_vars
Default   = 100
Type	  = value
Comment   = Suhosin max get

Directive = suhosin.post.max_value_length
Default   = 1000
Type	  = value
Comment   = Suhosin post max length

Directive = zlib.output_compression
Default   = Off
Type	  = bool
Comment   = Set zlib commpression

Directive = zlib.output_compression_level
Default   = -1
Type	  = list
Range     = 0,1,2,3,4,5,6,7,8,9" >> /etc/cl.selector/php.conf
Echo "Init cagefs..."
cagefsctl --init
echo "Enabling all mode..."
cagefsctl --enable-all

echo "Installing ClamAV..."
/scripts/update_local_rpm_versions --edit target_settings.clamav installed
/scripts/check_cpanel_rpms --fix --targets=clamav

echo "Installing Let's Encrypt SSL..."
/scripts/install_lets_encrypt_autossl_provider

echo "Installing SQLite3..."
/scripts/installsqlite3

echo "Installing PostgreSQL..."
/scripts/installpostgres

echo "Securing tmp..."
echo y | /scripts/securetmp

