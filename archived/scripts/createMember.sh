####################
#  createMember.sh
####################
if [[ "$#" -lt 8 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-n Liberty member name"
  echo "-p HTTP Port for Liberty server"
  echo "-s HTTPS Port for Liberty serer"
  echo "-h Liberty member hostname"
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: createMember.sh -n server1 -p 9083 -s 9447 -h server0.gym.lan"
  echo ""
   echo "---------------------------------------"
  exit 1
fi


#iterate over the keys that are passed in, until all are processed
numKeys=0
while [[ $# -gt 1 ]]

do
key="$1"
#echo "key is: $key"
case $key in
    -n|--serverName)
    SERVER_NAME="$2"
    let "numKeys+=1" 
    shift # past argument
    ;;
    -p|--httpPort)
    HTTP_PORT="$2"
     let "numKeys+=1"
    shift # past argument
    ;;
    -s|--httpsPort)
    HTTPS_PORT="$2"
     let "numKeys+=1"
    shift # past argument
    ;;
    -h|--hostName)
    MEMBER_HOSTNAME="$2"
     let "numKeys+=1"
    shift # past argument
    ;;
   esac
shift # past argument or value
#echo "numKeys: $numKeys"
done

#Make sure all of the required keys were passed in (-n -p -s -h)
if [[ $numKeys != 4 ]]; then
  echo "---------------------------------------"
  echo "Missing required FLAGS, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-n Liberty member name"
  echo "-p HTTP Port for Liberty server"
  echo "-s HTTPS Port for Liberty serer"
  echo "-h Liberty member hostname" 
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: createMember.sh -n server1 -p 9083 -s 9447 -h server0.gym.lan"
  echo ""
  echo "---------------------------------------"
  exit 1
fi

SAVE_COMMAND="createMember.sh -n $SERVER_NAME -p $HTTP_PORT -s $HTTPS_PORT -h $MEMBER_HOSTNAME"
LAB_HOME=/home/techzone
LAB_FILES=/home/techzone/liberty_admin_pot
SCRIPT_ARTIFACTS=$LAB_FILES/scripts/scriptArtifacts
LOGS=$LAB_FILES/logs
LOG=$LOGS/1_createMember-$SERVER_NAME.log
REMOTE_LOG=$LOGS/2_joinRemoteMember_$SERVER_NAME.log

if [ ! -d "$LOGS" ]; then
     mkdir $LOGS ;
     echo "Create Logs Directory: $LOGS"
fi

if [  -f "$LOG" ]; then
    rm $LOG ;
    echo "removed $LOG"
fi



echo "#----------------------------------" | tee $LOG
echo "# Now running createMember.sh" | tee -a $LOG
echo "#----------------------------------" | tee -a $LOG

sleep 5


WLP_HOME=$LAB_HOME/wlp


CONTROLLER_HTTPS_PORT=9493
CONTROLLER_HOSTNAME=`hostname`
CONTROLLER_WLP_HOME="/home/techzone/wlp"
KNOWN_REMOTE_HOST1="server1.gym.lan"



#Ensure the -h flag contains a valid hostname for this lab environment

echo "The '-h $MEMBER_HOSTNAME' flag was specified for the script"

 if [[ "$MEMBER_HOSTNAME" = "$CONTROLLER_HOSTNAME" ]] || [[ "$MEMBER_HOSTNAME" = "$KNOWN_REMOTE_HOST1" ]]; then
     echo "Liberty member hostname passed in: $MEMBER_HOSTNAME"
else 
     echo "The -h flag specified contains an invalid member hostName parameter."
      echo "   specify 'server0.gym.lan' for creating a local collective member"
      echo "   specify 'server1.gym.lan' for creating a remote collective member"
     exit 1      
fi

# Is this a remote or local member being registered
if [[ "$MEMBER_HOSTNAME" = "$CONTROLLER_HOSTNAME" ]] ; then
  MEMBER_TYPE="local"
else 
  MEMBER_TYPE="remote"  
  WLP_HOME_REMOTE="/opt/IBM/wlp"
fi


#Ensure the Liberty adminCenterController server is running. 

$WLP_HOME/bin/server status adminCenterController 
rc=$?
echo "server status return code: $rc"

for n in {1..2};
do 
  if [[ "$rc" != "0" ]]; then
    echo "adminCenterController is not running, Attemting to start it now!"
    $WLP_HOME/bin/server start adminCenterController 
    rc=$?
    echo "server start return code" $rc
    sleep 7
  fi 
done

if [[ "$rc" != "0" ]]; then
  echo "Could not start the adminCenterController, exiting!"
  exit 1
fi  
  

# List the variables used in the script
echo " "  | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a  $LOG
echo "# Registering $MEMBER_TYPE Liberty server: $SERVER_NAME" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo " "  | tee -a $LOG

echo "# List the variables used in the script" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a  $LOG
echo "# Command entered: $SAVE_COMMAND" | tee -a $LOG
echo "# Member Hostname: $MEMBER_HOSTNAME" | tee -a $LOG
echo "# Lab Home: $LAB_HOME" | tee -a $LOG
echo "# Lab Files Directory: $LAB_FILES" | tee -a $LOG
echo "# Script Artifacts Directory: $SCRIPT_ARTIFACTS" | tee -a $LOG
echo "# Liberty Home directory on Controllers Host: $WLP_HOME" | tee -a $LOG
if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    echo "# Liberty Home directory on $MEMBER_HOSTNAME: $WLP_HOME_REMOTE" | tee -a $LOG
fi    
echo "# Controller Hostname: $CONTROLLER_HOSTNAME" | tee -a $LOG
echo "# Controller wlp Home: $CONTROLLER_WLP_HOME" | tee -a $LOG
echo "# Controller HTTPS Port: $CONTROLLER_HTTPS_PORT" | tee -a $LOG
echo "# Name of Liberty Server being registered: $SERVER_NAME" | tee -a $LOG
echo "# Collective member HTTP Port: $HTTP_PORT" | tee -a $LOG
echo "# Collective member HTTP Port: $HTTPS_PORT" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "" | tee -a $LOG

#Have user reply "y" to continue the script, afer ensuring accuracy of the variables inout 
read -p "Do you wish to continue with the parameters specified? (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo continuing...
    ;;
    * )
        exit 1
    ;;
esac


delete_packaged_server_archive()  
{
#delete server package 
  echo "" | tee -a $LOG
  echo "# remove Liberty Archive zip file, if it exists" | tee -a $LOG
  echo "rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip" | tee -a $LOG
  echo "" | tee -a $LOG

  if [ -f "$LAB_FILES/packagedServers/$SERVER_NAME.zip" ]; then
     rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip ; 
     echo "$LAB_FILES/packagedServers/$SERVER_NAME.zip removed" 
  fi

  sleep 3

}


create_liberty_server()
{
  echo "" | tee -a $LOG
  echo "# Create Liberty Server" | tee -a $LOG
  echo "$WLP_HOME/bin/server create $SERVER_NAME" | tee -a $LOG
  echo "" | tee -a $LOG
  
  $WLP_HOME/bin/server create $SERVER_NAME
    
  
  if [[ $? != 0 ]]; then
   echo "Server create failed. See the error message that was returned!"
   exit $?
  fi 
  
  echo "Liberty Server $SERVER_NAME created" 
   
#Copy the server.xml file from the LAB_FILES directory into the Liberty server config directory    
  
  echo "" | tee -a $LOG
  echo "# Copy the server.xml file and application ear file into Liberty server" | tee -a $LOG
  echo "cp $LAB_FILES/server.xml $WLP_HOME/usr/servers/$SERVER_NAME/." | tee -a $LOG
  echo "cp $LAB_FILES/plantsbywebsphereee6.ear $WLP_HOME/usr/servers/$SERVER_NAME/apps/." | tee -a $LOG
  echo "" | tee -a $LOG
  
  cp $LAB_FILES/server.xml $WLP_HOME/usr/servers/$SERVER_NAME/. 
  cp $LAB_FILES/plantsbywebsphereee6.ear $WLP_HOME/usr/servers/$SERVER_NAME/apps/. 

  echo "Server configuration and application copied to Liberty server" 


#Create the configDropins/overrides directory
  echo "" | tee -a $LOG
  echo "# create the configDropins/overrides directory" | tee -a $LOG
  echo "mkdir $WLP_HOME/usr/servers/$SERVER_NAME/configDropins" | tee -a $LOG
  echo "mkdir $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides" | tee -a $LOG
  echo "" | tee -a $LOG
    
    
  mkdir $WLP_HOME/usr/servers/$SERVER_NAME/configDropins | tee -a $LOG
  mkdir $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides | tee -a $LOG
  echo "Librty server configDropins folders created" 


#Copy the memberOverride.xml into the configDropins/overrides directory
  echo "" | tee -a $LOG
  echo "# Copy the memberOverride.xml into the configDropins/overrides directory" | tee -a $LOG
  echo "cp $SCRIPT_ARTIFACTS/memberOverride.xml $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/." | tee -a $LOG
  echo "" | tee -a $LOG  
  
  cp $SCRIPT_ARTIFACTS/memberOverride.xml $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/. 
  
  
#Update the Liberty server ports in the memberOverrides.xml with ports passed into script
  echo "" | tee -a $LOG
  echo "# Update the Liberty server ports in the memberOverrides.xml" | tee -a $LOG
  echo "sed -i 's/9084/'$HTTP_PORT'/g' $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/memberOverride.xml" | tee -a $LOG
  echo "sed -i 's/9446/'$HTTPS_PORT'/g' $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/memberOverride.xml" | tee -a $LOG
  echo "" | tee -a $LOG
  
  
  sed -i 's/9084/'$HTTP_PORT'/g' $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/memberOverride.xml 
  sed -i 's/9446/'$HTTPS_PORT'/g' $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides/memberOverride.xml 
  echo "HTTP port is now set to $HTTP_PORT in configOverrides" 
  echo "HTTPS port is now set to $HTTPS_PORT in configOverrides" 


#Add the WhereAmI application to the server, which is used in the Dynamic Routing scenario.

  echo "" | tee -a $LOG
  echo "# Copy the WhereAmI.war war file into Liberty server Dropins folder" | tee -a $LOG
  echo "cp $LAB_FILES/WhereAmI.war $WLP_HOME/usr/servers/$SERVER_NAME/dropins/." | tee -a $LOG
  echo "" | tee -a $LOG
  
  
  cp $LAB_FILES/WhereAmI.war $WLP_HOME/usr/servers/$SERVER_NAME/dropins/.
  
}


create_packaged_server()
{
#Package the Liberty Archive if it is for a REMOTE deployment
  echo "Package the Liberty Archive" 
  
#Only create the archive package for 'remote' Liberty collective members. 
#Specify --include=usr because liberty is installed on the remote host.

  if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    #Delete a package server archive of the same name, if it exists   
    delete_packaged_server_archive $SERVER_NAME
  
    echo "" | tee -a $LOG
    echo "# Package the Liberty Archive for remote deployment" | tee -a $LOG
    echo "$WLP_HOME/bin/server package $SERVER_NAME --archive=$LAB_FILES/packagedServers/$SERVER_NAME.zip --include=usr" | tee -a $LOG
    echo "" | tee -a $LOG
  
    $WLP_HOME/bin/server package $SERVER_NAME --archive=$LAB_FILES/packagedServers/$SERVER_NAME.zip --include=usr 
     
    if [[ $? != 0 ]]; then
      echo "FAILED to create the Liberty server package for remote server. See the error message that was returned!"
      exit $?
    fi   
    
    echo "Liberty server package created for remote deployment" 
    sleep 5
  fi
}
  

join_Remote_Member()
{
  echo " " | tee -a $LOG
  echo "# joining remote member to collective...." | tee -a $LOG
  echo "" | tee -a $LOG
  
  prepare_remote_member $SERVER_NAME $HTTP_PORT $MEMBER_HOSTNAME $SERVER_NAME.zip
}  
  

join_Local_Member() 
{ 

  echo "joining local member to collecive...." 
 
  #join a local server to the collective
  
  echo "" | tee -a $LOG
  echo "# join local member to collecive." | tee -a $LOG
  echo "" | tee -a $LOG

  echo "$WLP_HOME/bin/collective join $SERVER_NAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin --keystorePassword=memberKSPassword --createConfigFile=$WLP_HOME/usr/servers/$SERVER_NAME/controller.xml"  | tee -a $LOG
  echo "" | tee -a $LOG

  echo "-------------------------------------------------------------------------"
  echo "Reply 'y' when prompted to accept the certificate chain (collective join)"
  echo "-------------------------------------------------------------------------"
  
  sleep 10
  
  $WLP_HOME/bin/collective join $SERVER_NAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin --keystorePassword=memberKSPassword --createConfigFile=$WLP_HOME/usr/servers/$SERVER_NAME/controller.xml

   if [[ $? != 0 ]]; then
   echo "#ERROR Failed to join $SERVER_NAME to the collective. See the error message that was returned!" | tee -a $LOG
   
   #cleanup the local server and packaged serverarchive
   delete_liberty_server $SERVER_NAME
   delete_package_server_archive $SERVER_NAME
   exit $?
  fi 


  echo "# Collective member $SERVER_NAME joined the collective, and is viewable from the Liberty Admin Center" | tee -a $LOG 

  sleep 5
}


start_local_liberty_server()
{
#start the Local Liberty server
  echo "" | tee -a $LOG
  echo "# Start the local Liberty Server member" | tee -a $LOG
  echo "$WLP_HOME/bin/server start $SERVER_NAME" | tee -a $LOG
  echo "" | tee -a $LOG
  
  $WLP_HOME/bin/server start $SERVER_NAME
  
   if [[ $? != 0 ]]; then
   echo "FAILED to start the local Liberty server $SERVER_NAME. See the error message that was returned!"
   exit $?
  fi 
  echo "----------------------------------------------------------------------------" 
  echo "Server $SERVER_NAME started! It is now viewable in the Liberty Admin Center!" 
  echo "----------------------------------------------------------------------------" 
}



delete_liberty_server()
{

#Delete the liberty server directory

  if [ -d "$WLP_HOME/usr/servers/$SERVER_NAME" ]; then
    echo "" | tee -a $LOG
    echo "# Delete the server directory"  | tee -a $LOG
    echo "rm -rf $WLP_HOME/usr/servers/$SERVER_NAME" | tee -a $LOG
    echo "" | tee -a $LOG

    rm -rf $WLP_HOME/usr/servers/$SERVER_NAME | tee -a $LOG

    echo "$WLP_HOME/usr/servers/$SERVER_NAME directory has been removed"  
    echo "" 
  fi
}



delete_package_server_archive()
{
#Delete a package Server archive


  echo "" | tee -a $LOG
  echo "# cleanup Liberty Archive zip file, if it exists" | tee -a $LOG
  echo "rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip" | tee -a $LOG
  echo "" | tee -a $LOG

  if [ -f "$LAB_FILES/packagedServers/$SERVER_NAME.zip" ]; then
     rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip ; 
     echo "$LAB_FILES/packagedServers/$SERVER_NAME.zip removed" 
  fi

}


process_remoteserver_log()
{
 
#Check if we find text 'ERROR' in the log from remote server. 

#If we find ERRROR, then remove the local Liberty server directory and package archive   
  echo ""
  echo "logRetreived: $logRetrieved"
  echo ""
  echo "remote log: $REMOTE_LOG"
  echo ""
  if [ "$logRetrieved" = "1" ]; then
    echo "# Found the log, now checking ofr ERRORS reported in the log" | tee -a $LOG
    gotErrors=$(cat $REMOTE_LOG | grep ERROR | wc -l)
    echo "gotErrors: $gotErrors"
    #If ERROR found in the log, delete the servers/$SERVER_NAME directory and the packageServer on controller host.
    if [ "$gotErrors" != "0" ]; then
      echo "OK to delete the server directory and packageServer archive"
      #cleanup the local server and packaged serverarchive
      delete_liberty_server $SERVER_NAME
      delete_package_server_archive $SERVER_NAME
      echo "" | tee -a $LOG
      echo "#------------------------------------------------------------------" | tee -a $LOG
      echo "# Errors found in $REMOTE_LOG" | tee -a $LOG
      echo "#" | tee -a $LOG
      echo "# ERROR! The joinRemoteMember.sh script ended with errors. Check the console messages. " | tee -a $LOG
      echo "# Then correct the errors and rerun the createMember.sh" | tee -a $LOG
      echo "#" | tee -a $LOG
      echo "# Verify the parameters passed into the'createMember.sh. Perhaps you specified the wrong hostname on the '-h' flag or incorrect serverName on the -n flag"  | tee -a $LOG
      echo "#" | tee -a $LOG
      echo "# You entered the command as $SAVE_COMMAND" | tee -a $LOG
      echo "------------------------------------------------------------------" | tee -a $LOG
    else #no errors found
      echo "#" | tee -a $LOG
      echo "#---------------------------------" | tee -a $LOG
      echo "# Yeah! No errors found in the log!" | tee -a $LOG
      echo "#---------------------------------" | tee -a $LOG
      echo "#" | tee -a $LOG
    fi
      
  fi
  
    
  echo "" 
  echo "remove_Remote_Member function completed" 
  echo "" 

}



setup_firewall_ports()
{

#The Controllers HTTPS port needs to be opened on server0.gym.lan

echo "" | tee -a $LOG
echo "# The Collective Controller HTTPS port $CONTROLLER_HTTPS_PORT needs to be open for joining members to the collective." | tee -a $LOG
echo "" | tee -a $LOG


#open Controller HTTPS port, if not found
  controllerHttpsPortFound=$(sudo firewall-cmd --list-ports | grep $CONTROLLER_HTTPS_PORT/tcp | wc -l)

  if [[ "$controllerHttpsPortFound" -lt 1 ]]; then
    echo "Need to open port $CONTROLLER_HTTPS_PORT for the colective controller HTTPS port"
    sudo firewall-cmd --permanent --zone=public --add-port=$CONTROLLER_HTTPS_PORT/tcp 
    sleep 7
  fi  

    
#reload the firewall settings
  echo "reloading the firewall rules!" 
  sudo firewall-cmd --reload 
  
  echo "WAITING for Firewall rules to be reloaded............ " 

  sleep 15
  

#List the ports 
  echo "" | tee -a $LOG
  echo "# List the opened ports"  | tee -a $LOG
  echo "" | tee -a $LOG
  echo "# $(sudo firewall-cmd --list-ports)" | tee -a $LOG
  
  echo "" | tee -a $LOG
  echo "#INFORMATION ONLY!!! The ports were opened by using the following commands on the Liberty Controller VM."  | tee -a $LOG
  echo "" | tee -a $LOG
  echo "#----------------------------------------------------------------------------" | tee -a $LOG
  echo "# Note: The Collective Controller HTTPS port must be opened for members to join the collective" | tee -a $LOG 
  echo "# firewall-cmd --list-ports" | tee -a $LOG 
  echo "# firewall-cmd --permanent --zone=public --add-port=$CONTROLLER_HTTPS_PORT/tcp" | tee -a $LOG
  echo "# firewall-cmd --reload" | tee -a $LOG
  echo "#----------------------------------------------------------------------------" | tee -a $LOG
  echo "" | tee -a $LOG
 
#verify the Controllers HTTPS port is opened. Exit if not opened.  
 
#Get updated state... 
   controllerHttpsPortFound=$(sudo firewall-cmd --list-ports | grep $CONTROLLER_HTTPS_PORT/tcp | wc -l)

#Variable is > 0 if the port is found in the command above, listing the opened ports. 
  if [[ "$controllerHttpsPortFound" -gt "0" ]];  then
    echo "----------------------------------------------------------------------------" 
    echo "Required port $CONTROLLER_HTTPS_PORT for the Liberty Controller HTTPS port is opened" 
    echo "Script will continue!" 
    echo "----------------------------------------------------------------------------" 
    sleep 7
  else 
    echo "Required port $CONTROLLER_HTTPS_PORT for the Liberty Controller HTTPS not opend." 
    echo "Exiting!" 
    echo ""
    echo "open the required ports using the following commands on the Liberty Controller VM." 
    echo "Then rerun the script."  
    echo "----------------------------------------------------------------------------" 
    echo "sudo firewall-cmd --permanent --zone=public --add-port=$CONTROLLER_HTTPS_PORT/tcp" 
    echo "----------------------------------------------------------------------------" 
  
    exit 1
  fi  
  
}


prepare_remote_member()
{
#Function called from the join_Remote_Member() function in this script.
#This function will scp Liberty Archive and a shell script to the remote Liberty Host. 
#The remote shell script runs which extracts the Liberty archive and joins the remote Lberty Server to the collective. 

echo "#---------------------------------------------" 
echo "# Now running prepare_remote_member() function" 
echo "#---------------------------------------------" 
echo ""



#check is the packagedServer archive file exists

if [ ! -f "$LAB_FILES/packagedServers/$SERVER_NAME.zip" ]; then
    echo "The Liberty Archive $LAB_FILES/packagedServers/$SERVER_NAME.zip does not exist. Make sure the server was packaged with the expected name."
    exit 1;
fi

#Attempt to unregister the remote host to the collective. Its OK if its not already registered.


echo ""
echo "# Attempt to unregister the remote host from the collective. Its OK if its not already registered." 
echo " "
echo  "$CONTROLLER_WLP_HOME/bin/collective unregisterHost $MEMBER_HOSTNAME --controller=admin:admin@$CONTROLLER_HOSTNAME:$CONTROLLER_HTTPS_PORT" 
echo "" 
echo "--------------------------------------------------------------------------------" 
echo "Reply 'y' when prompted to accept the certificate chain  (collective unregister)" 
echo "--------------------------------------------------------------------------------" 

sleep 10


$CONTROLLER_WLP_HOME/bin/collective unregisterHost $MEMBER_HOSTNAME --controller=admin:admin@$CONTROLLER_HOSTNAME:$CONTROLLER_HTTPS_PORT


#Register the remote host to the collective


echo "" | tee -a $LOG
echo "# Register the remote host to the collective" | tee -a $LOG
echo " "
echo "" | tee -a $LOG
echo  "$CONTROLLER_WLP_HOME/bin/collective registerHost $MEMBER_HOSTNAME --controller=admin:admin@$CONTROLLER_HOSTNAME:$CONTROLLER_HTTPS_PORT --hostJavaHome=/opt/IBM/ibm-java-x86_64-80/jre/ --rpcuser=techzone --rpcUserPassword='IBMDem0s!'" |  tee -a $LOG
echo "" | tee -a $LOG

echo "-----------------------------------------------------------------------------" 
echo "Reply 'y' when prompted to accept the certificate chain (collective register)" 
echo "-----------------------------------------------------------------------------" 

echo "" | tee -a $LOG

sleep 10


$CONTROLLER_WLP_HOME/bin/collective registerHost $MEMBER_HOSTNAME --controller=admin:admin@$CONTROLLER_HOSTNAME:$CONTROLLER_HTTPS_PORT --hostJavaHome=/opt/IBM/ibm-java-x86_64-80/jre/ --rpcuser=techzone --rpcUserPassword='IBMDem0s!'


if [[ $? != 0 ]]; then
   echo "#ERROR Failed to register $MEMBER_HOSTNAME with the controller. See the error message that was returned!" | tee -a $LOG
   
   #cleanup the local server and packaged serverarchive
   delete_liberty_server $SERVER_NAME
   delete_package_server_archive $SERVER_NAME
   
   exit $?
  fi 

echo "Host registered: $MEMBER_HOSTNAME" 


#The testConnection command is used to verify connectivity. The command validates RXA connectivity between the controller and the host where the member reside"

echo " " | tee -a $LOG
echo "# Test the connection between the controller and registered host." | tee -a $LOG
echo "$CONTROLLER_WLP_HOME/bin/collective testConnection $MEMBER_HOSTNAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin --autoAcceptCertificates" | tee -a $LOG
echo " " | tee -a $LOG


$CONTROLLER_WLP_HOME/bin/collective testConnection $MEMBER_HOSTNAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin --autoAcceptCertificates

#echo "return code from the collective testConnection command: $?"

if [[ $? != 0 ]]; then
   echo "#ERROR Testing the connnection between the Controller and $MEMBER_HOSTNAME FAILED. See the error message that was returned!" | tee -a $LOG
  
   #cleanup the local server and packaged serverarchive
   delete_liberty_server $SERVER_NAME
   delete_package_server_archive $SERVER_NAME
   
   exit $?
  fi 

echo "Test connection between Controller and host $MEMBER_HOSTNAME completed." 

sleep 7
    
echo "---------------------------------------------------------------------------"
echo "You will be prompted multiple times for the password for the techzone user"
echo ""
echo "Enter IBMDem0s! as the password when prompted."
echo "---------------------------------------------------------------------------"
sleep 7
    

echo " " | tee -a $LOG
echo "# Copy the Liberty Archive $SERVER_NAME.zip to the remote server $MEMBER_HOSTNAME" | tee -a $LOG
echo "scp $LAB_FILES/packagedServers/$SERVER_NAME.zip techzone@$MEMBER_HOSTNAME:/home/techzone/Downloads" | tee -a $LOG
echo " " | tee -a $LOG

scp $LAB_FILES/packagedServers/$SERVER_NAME.zip techzone@$MEMBER_HOSTNAME:/home/techzone/Downloads


echo " " | tee -a $LOG
echo "# Copy $LAB_FILES/joinRemoteMember.sh to the remote server $MEMBER_HOSTNAME" | tee -a $LOG
echo "scp $LAB_FILES/scripts/joinRemoteMember.sh techzone@$MEMBER_HOSTNAME:/home/techzone" | tee -a $LOG
echo " "  | tee -a $LOG

scp $SCRIPT_ARTIFACTS/joinRemoteMember.sh techzone@$MEMBER_HOSTNAME:/home/techzone

echo " " | tee -a $LOG
echo "# ssh to $MEMBER_HOSTNAME and run joinRemoteMember.sh" | tee -a $LOG
echo "ssh -t $MEMBER_HOSTNAME . /home/techzone/joinRemoteMember.sh $SERVER_NAME $HTTP_PORT  $CONTROLLER_HTTPS_PORT" | tee -a $LOG
echo " " | tee -a $LOG


#Join the remote server to the collective. The -t option is REQUIRED to run the ssh in interactive mode. Otherwise the command will fail, as you will be unable to respond to accept the key chain during the join command. 

ssh -t $MEMBER_HOSTNAME . /home/techzone/joinRemoteMember.sh $SERVER_NAME $HTTP_PORT $CONTROLLER_HTTPS_PORT


# We are back from running the joinRemoteMember script. Now get the logs from the remote host

echo "#----------------------------------------------- " | tee -a $LOG
echo "# joinRemoteMember.sh completed on $MEMBER_HOSTNAME" | tee -a $LOG
echo " " | tee -a $LOG
echo "# --> Now retrieving the logs from $MEMBER_HOSTNAME" | tee -a $LOG
echo "#----------------------------------------------- " | tee -a $LOG


# Retrieve the joinRemoteMember.log file from the remote host. 
echo " " | tee -a $LOG
echo "# Retreive the joinRemoteMember.log from the remote server $MEMBER_HOSTNAME" | tee -a $LOG
echo "scp techzone@$MEMBER_HOSTNAME:/home/techzone/2_joinRemoteMember.log $REMOTE_LOG" | tee -a $LOG
echo " " | tee -a $LOG

  
echo "---------------------------------------------------------------------------"
echo "You will be prompted for the password for the techzone user"
echo ""
echo "Enter IBMDem0s! as the password when prompted."
echo "---------------------------------------------------------------------------"
sleep 5

scp techzone@$MEMBER_HOSTNAME:/home/techzone/2_joinRemoteMember.log $REMOTE_LOG

echo ""
echo "The remote log name is: $REMOTE_LOG"
echo ""

if [ -f "$REMOTE_LOG" ]; then
    echo "$REMOTE_LOG retreived from remote Host $MEMBER_HOSTNAME" 
    logRetrieved=1   
    process_remoteserver_log $logRetrieved $REMOTE_LOG 
else 
   echo "#ERROR! Could not retreive $REMOTE_LOG from $SERVER_NAME" | tee -a $LOG
   echo "# Manual cleanup will be required to create a server with the SAME name: $SERVER_NAME" | tee -a $LOG
   logRetrieved=0
   
   exit 1
fi 


#End prepare_remote_member
} 




#MAIN PROGRAM

echo "========================="
echo "Running 'CreateMemiber.sh'"
echo "========================="
  
  create_liberty_server
  create_packaged_server
  
  if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    setup_firewall_ports
    join_Remote_Member    
  else 
    join_Local_Member
#    start_local_liberty_server
  fi
  
  
 echo "" 
 echo "The log files can be found in: $LOGS"
 echo "ls -l $LOGS"
 echo ""  
 #ls -l $LOGS
 
  
 echo "" | tee -a $LOG 
 echo "# End of createMember.sh script." | tee -a $LOG
 echo "" | tee -a $LOG 
 