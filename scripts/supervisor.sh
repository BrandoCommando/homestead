#!/usr/bin/env bash
if [ `id -u` -ne 0 ]; then sudo $0 $*; exit $?; fi
if [ ! -z "$2" -a -d "$2" ]; then
	cnf="$2/laravel_queue.conf"
elif [ -d "/etc/supervisor" ]; then
	cnf="/etc/supervisor/conf.d/laravel_queue.conf"
else
	cnf="`find /etc -name 'supervisor' -type d | head -n1`/conf.d/laravel_queue.conf"
fi
if [ -z "$cnf" ]; then
	echo "Unable to find supervisor config directory"
	exit 1
fi
if [ -f "$cnf" -a `stat --printf="%s" $cnf` -gt 0 ]; then
	echo "Config file already exists"
	exit 3
fi
touch "$cnf"
if [[ $? -ne 0 ]]; then
	echo "Unable to create supervisor config file"
	exit 2
fi
if [ -d "$1" ]; then
	root="$1"
else
	root="/home/vagrant/Code"
fi
logp="$root/storage/logs"

echo "[program:laravel_queue]" > $cnf
echo "command=php artisan queue:listen --timeout=360 --tries=1 --env=${APP_ENV} --memory=512 --sleep --delay=0" >> $cnf
echo "directory=$root" >> $cnf
echo "stdout_logfile=$logp/laravel-queue.log" >> $cnf
echo "logfile_maxbytes=0" >> $cnf
echo "logfile_backups=0" >> $cnf
echo "redirect_stderr=true" >> $cnf
echo "autostart=true" >> $cnf
echo "autorestart=true" >> $cnf
echo "startretries=86400" >> $cnf
/etc/init.d/supervisor restart
