read -p "[1] Listen Port (7777) > " lport
read -p "[2] Your Domain (localhost) > " domain
read -p "[3] Pool Host&Port (xmr-us-east1.nanopool.org:14444) > " pool
read -p "[4] Your XMR wallet (45MuwhzBk17cGJEgaHWrzQYcZKsktapJLHwZWkNwLea5LNyFMzGcoRqNpNf6vrhgpYK8JVxgmngXHURWTDNH7NwN4c6reJE) > " addr
if [ ! -n "$lport" ];then
    lport="7777"
fi
if [ ! -n "$domain" ];then
    domain="localhost"
fi
if [ ! -n "$pool" ];then
    pool="pool.elitexmr.com:8080"
fi
while  [ ! -n "$addr" ];do
    read -p "Plesae set XMR wallet address!!! > " addr
done
read -p "[5] The Pool passwd (null) > " pass
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt install --yes nodejs git curl nginx
mkdir /srv
cd /srv
rm -rf deepMiner
git clone https://github.com/deepwn/deepMiner.git -o deepMiner
cd deepMiner
sed -i "s/7777/$lport/g" config.json
sed -i "s/digxmr.com/$domain/g" config.json
sed -i "s/xmr-us-east1.nanopool.org:14444/$pool/g" config.json
sed -i "s/45MuwhzBk17cGJEgaHWrzQYcZKsktapJLHwZWkNwLea5LNyFMzGcoRqNpNf6vrhgpYK8JVxgmngXHURWTDNH7NwN4c6reJE/$addr/g" config.json
sed -i "s/\"pass\": \"\"/\"pass\": \"$pass\"/g" config.json
npm update
npm install -g forever
forever stopall
forever start /srv/deepMiner/server.js
sed -i '/forever start \/srv\/deepMiner\/cluster.js/d' /etc/rc.local
sed -i '/exit 0/d' /etc/rc.local
echo "forever start /srv/deepMiner/cluster.js" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
rm -rf /etc/nginx/sites-available/deepMiner.conf
rm -rf /etc/nginx/sites-enabled/deepMiner.conf
echo 'server {' >> /etc/nginx/sites-available/deepMiner.conf
echo 'listen 80;' >> /etc/nginx/sites-available/deepMiner.conf
echo "server_name $domain;" >> /etc/nginx/sites-available/deepMiner.conf
echo 'location / {' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_http_version 1.1;' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_set_header   Host	$http_host;' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_set_header   X-Real-IP $remote_addr;' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_set_header   Upgrade $http_upgrade;' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_set_header   Connection "upgrade";' >> /etc/nginx/sites-available/deepMiner.conf
echo 'proxy_cache_bypass $http_upgrade;' >> /etc/nginx/sites-available/deepMiner.conf
echo "proxy_pass         http://127.0.0.1:$lport;" >> /etc/nginx/sites-available/deepMiner.conf
echo '}' >> /etc/nginx/sites-available/deepMiner.conf
echo '}' >> /etc/nginx/sites-available/deepMiner.conf
ln -s /etc/nginx/sites-available/deepMiner.conf /etc/nginx/sites-enabled/deepMiner.conf
clear
echo " >>> Serv : $domain (backend > 127.0.0.1:$lport)"
echo " >>> Pool : $pool"
echo " >>> Addr : $addr"
echo ""
echo " All done ! Enjoy deepMiner !"
echo ""
service nginx restart
