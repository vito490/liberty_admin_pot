
LAB_HOME=/home/techzone
LAB_FILES=/home/techzone/liberty_admin_pot

WLP_HOME=$LAB_HOME/wlp

IHS_HOME=/opt/IBM/HTTPServer

PluginRoot=/opt/IBM/WebSphere/Plugins/

HOSTNAME=`hostname`
echo $HOSTNAME

$IHS_HOME/bin/apachectl stop
if [ -e "$LAB_FILES/scripts/plugin-cfg.xml" ]; then
     rm   $LAB_FILES/scripts/plugin-cfg.xml ;
     echo "$LAB_FILES/scripts/plugin-cfg.xml file removed"
fi
if [ -e "$LAB_FILES/scripts/plugin-key.p12" ]; then
     rm   $LAB_FILES/scripts/plugin-key.p12 ;
     echo "$LAB_FILES/scripts/plugin-key.p12 file removed"
fi
if [ -e "/tmp/plugin-cfg.xml" ]; then
     rm   /tmp/plugin-cfg.xml ;
     echo "/tmp/plugin-cfg.xml file removed"
fi
if [ -e "/tmp/plugin-key.p12" ]; then
     rm   /tmp/plugin-key.p12 ;
     echo "/tmp/plugin-key.p12 file removed"
fi
if [ -e "/tmp/plugin-key.kdb" ]; then
     rm   /tmp/plugin-key.kdb ;
     echo "/tmp/plugin-key.kdb file removed"
fi
if [ -e "/tmp/plugin-key.rdb" ]; then
     rm   /tmp/plugin-key.rdb ;
     echo "/tmp/plugin-key.rdb file removed"
fi
if [ -e "/tmp/plugin-key.sth" ]; then
     rm   /tmp/plugin-key.sth ;
     echo "/tmp/plugin-key.sth file removed"
fi
$WLP_HOME/bin/dynamicRouting setup --port=9493 --host=$HOSTNAME --user=admin --password=admin --keystorePassword=webAS --pluginInstallRoot=$PluginRoot --webServerNames=webserver1

sleep 5
echo "dynamicRouting setup completed"

cp plugin-cfg.xml /tmp/.
cp plugin-key.p12 /tmp/.
sleep 5

$IHS_HOME/bin/gskcapicmd -keydb -convert -pw webAS -db /tmp/plugin-key.p12 -old_format pkcs12 -target /tmp/plugin-key.kdb -new_format cms -stash 
sleep 5
echo "gskcmd convert completed"
$IHS_HOME/bin/gskcapicmd -cert -setdefault -pw webAS -db /tmp/plugin-key.kdb -label default
sleep 5
echo "gskcmd cert completed"
cp /tmp/plugin-key.kdb  /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key.rdb  /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key.sth /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-cfg.xml /opt/IBM/WebSphere/Plugins/config/webserver1/.
sleep 5
#Start HIS server

$IHS_HOME/bin/apachectl start

sleep 5