####################
#  deleteMember.sh
####################
if [[ "$#" -lt 4 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-n Liberty member to remove"
  echo "-h Liberty member hostname" 
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: deleteMember.sh -n server1 -h server0.gym.lan"
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
    -h|--hostName)
    MEMBER_HOSTNAME="$2"
     let "numKeys+=1"
    shift # past argument
    ;;
   esac
shift # past argument or value
#echo "numKeys: $numKeys"
done

#Make sure all of the required keys were passed in (-n -h)
if [[ $numKeys != 2 ]]; then
  echo "---------------------------------------"
  echo "Missing required FLAGS, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-n Liberty member name"
  echo "-h Liberty member hostname" 
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: deleteMember.sh -n server1 -h server0.gym.lan"
  echo ""
  echo "---------------------------------------"
  exit 1
fi

SAVE_COMMAND="deleteMember.sh -n $SERVER_NAME -h $MEMBER_HOSTNAME"
LAB_HOME=/home/techzone
LAB_FILES=/home/techzone/liberty_admin_pot
LOGS=$LAB_FILES/logs
LOG=$LOGS/3_deleteMember-$SERVER_NAME.log
WLP_HOME=$LAB_HOME/wlp

CONTROLLER_HOSTNAME=`hostname`
CONTROLLER_HTTPS_PORT=9493

KNOWN_REMOTE_HOST1="server1.gym.lan"
SCRIPT_ARTIFACTS=$LAB_FILES/scripts/scriptArtifacts


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


# Remove any old log file

if [ ! -d "$LOGS" ]; then
     mkdir $LOGS ;
     echo "Create Logs Directory: $LOGS"
fi

if [  -f "$LOG" ]; then
    rm $LOG ;
    echo "removed old log"
fi



echo "#----------------------------------" | tee $LOG
echo "# Now running deleteMember.sh" | tee -a $LOG
echo "#----------------------------------" | tee -a $LOG

sleep 7


WLP_HOME=$LAB_HOME/wlp

if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    WLP_HOME_REMOTE="/opt/IBM/wlp"
fi


#List the variables used in the script

echo "" | tee -a  $LOG
echo "#-------------------------------------------------------------" | tee -a  $LOG
echo "# Deleting $MEMBER_TYPE Liberty server: $SERVER_NAME from the collective" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "" | tee -a  $LOG
echo "# List variables used in the script" | tee -a  $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "# Member Hostname: $MEMBER_HOSTNAME" | tee -a $LOG
echo "# Lab Home: $LAB_HOME" | tee -a $LOG
echo "# Lab Files Directory: $LAB_FILES" | tee -a $LOG
echo "# Liberty Home directory on Controllers Host: $WLP_HOME" | tee -a $LOG
if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    echo "# Liberty Home directory on $MEMBER_HOSTNAME: $WLP_HOME_REMOTE" | tee -a $LOG
fi    
echo "# Controller Hostname: $CONTROLLER_HOSTNAME" | tee -a $LOG
echo "# Name of Liberty Server being Unregistered: $SERVER_NAME" | tee -a $LOG
echo "# Controller HTTPS Port: $CONTROLLER_HTTPS_PORT" | tee -a $LOG
echo "-------------------------------------------------------------" | tee -a $LOG


read -p "Do you wish to continue with the parameters specified? (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo continuing...
    ;;
    * )
        exit 1
    ;;
esac

 

remove_Remote_Member()
{
  echo "" 
  echo "# Removing remote member $SERVER_NAME on $MEMBER_HOSTNAME from the collecive" 
  echo "" 
  
  echo "---------------------------------------------------------------------------"
  echo "You will be prompted for the password for the techzone user"
  echo ""
  echo "Enter IBMDem0s! as the password when prompted."
  echo "---------------------------------------------------------------------------"
  sleep 10
  
  echo "" | tee -a $LOG
  echo "# Copy the deleteRemoteMember.sh script to $MEMBER_HOSTNAME" | tee -a $LOG
  echo "scp $SCRIPT_ARTIFACTS/deleteRemoteMember.sh techzone@$REMOTE_HOST:/home/techzone" | tee -a $LOG
  echo "" | tee -a $LOG
  
  scp $SCRIPT_ARTIFACTS/deleteRemoteMember.sh techzone@$MEMBER_HOSTNAME:/home/techzone
  
  echo "" | tee -a $LOG
  echo "# ssh into $MEMBER_HOSTNAME to remove the member and cleanup the $SERVER_NAME directory" | tee -a $LOG
  echo "ssh -t $MEMBER_HOSTNAME . /home/techzone/deleteRemoteMember.sh $SERVER_NAME $CONTROLLER_HTTPS_PORT" | tee -a $LOG
  echo "" | tee -a $LOG
 
  ssh -t $MEMBER_HOSTNAME . /home/techzone/deleteRemoteMember.sh $SERVER_NAME $CONTROLLER_HTTPS_PORT

# We are back from running the deleteRemoteMember script. Now get the logs from the remote host

  echo "#----------------------------------------------- " | tee -a $LOG
  echo "# deleteRemoteMember.sh completed on $MEMBER_HOSTNAME" | tee -a $LOG
  echo " " | tee -a $LOG
  echo "# --> Now retrieving the logs from $MEMBER_HOSTNAME" | tee -a $LOG
  echo "#----------------------------------------------- " | tee -a $LOG

# Retrieve the deleteRemoteMember.log file from the remote host. 


  echo "" | tee -a $LOG
  echo "# Retreive the deleteRemoteMember.log file from the remote Host" | tee -a $LOG
  echo "scp techzone@$MEMBER_HOSTNAME:/home/techzone/4_deleteRemoteMember.log $LOGS/4_deleteRemoteMember_$SERVER_NAME.log" | tee -a $LOG
  echo "" | tee -a $LOG  
  
  echo "---------------------------------------------------------------------------"
  echo "You will be prompted for the password for the techzone user"
  echo ""
  echo "Enter IBMDem0s! as the password when prompted."
  echo "---------------------------------------------------------------------------"
  sleep 7

#copy the log file from remote host to Controller host
  scp techzone@$MEMBER_HOSTNAME:/home/techzone/4_deleteRemoteMember.log $LOGS/4_deleteRemoteMember_$SERVER_NAME.log


#Check if we have successfull retreived the log

  if [ -f "$LOGS/4_deleteRemoteMember_$SERVER_NAME.log" ]; then
    echo "$LOGS/4_deleteRemoteMember_$SERVER_NAME.log retreived from remote Host $MEMBER_HOSTNAME"
    logRetrieved=1 
  else 
     echo "ERROR! Could not retreive '4_deleteRemoteMember.log' from $MEMBER_HOSTNAME" 
     logRetrieved=0
  fi 
  
  
 
# remove the  Liberty server directory and server package on the Controller host. 
##### UGGH We cannot do this if the remote delete script fails....   
  
#Check if we find text 'ERROR' in the log from reote server. If not, ts OK to delete the local server directory, since the remote server should be clean and server removed from collective.   
  echo "logRetreived: $logReftreived"
  
  if [ "$logRetrieved" = "1" ]; then
    echo "Found the log, now check if there are ERRORS reported in the log"
    
    #gotErrors is > 1 if ERROR reported in log
    gotErrors=$(cat $LOGS/4_deleteRemoteMember_$SERVER_NAME.log | grep ERROR | wc -l)
    echo "gotErrors: $gotErrors"
    
    #If no errors in the log, delete the servers/$SERVER_NAME directory on controller host.
    if [ "$gotErrors" = "0" ]; then
      echo "OK to delete the server directory on the controller host"
      if [ -d "$WLP_HOME/usr/servers/$SERVER_NAME" ]; then
        echo "" | tee -a $LOG
        echo "# Delete the server directory on controller"  | tee -a $LOG
        echo "# rm -rf $WLP_HOME/usr/servers/$SERVER_NAME" | tee -a $LOG
        echo "" | tee -a $LOG
  
        rm -rf $WLP_HOME/usr/servers/$SERVER_NAME
  
        echo "$WLP_HOME/usr/servers/$SERVER_NAME directory has been removed"  
      else 
        echo "No Problem! The $WLP_HOME/usr/servers/$SERVER_NAME has already been removed"
        echo "The script will continue"
      fi
      #remove the server package for the server
      if [ -f "$LAB_FILES/packagedServers/$SERVER_NAME.zip" ]; then
         echo "" | tee -a $LOG
         echo "# Delete the server package" | tee -a $LOG
         echo "# rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip ;" | tee -a $LOG
         echo "" | tee -a $LOG
         
         rm  $LAB_FILES/packagedServers/$SERVER_NAME.zip ; 
         echo "$LAB_FILES/packagedServers/$SERVER_NAME.zip removed" 
      fi  
    else #errors found in the log. Do not cleanup the local Liberty server directory.
      echo "" | tee -a $LOG
      echo "#------------------------------------------------------------------" | tee -a $LOG
      echo "# Errors found in $LOGS/4_deleteRemoteMember_$SERVER_NAME.log" | tee -a $LOG
      echo "# We will NOT delete $WLP_HOME/usr/servers/$SERVER_NAME" | tee -a $LOG
      echo "#" | tee -a $LOG
      echo "# ERROR! The deleteMember.sh script ended with errors. Check the console messages." | tee -a $LOG
      echo "# Then correct the errors and rerun the deleteMember.sh" | tee -a $LOG
      echo "#" | tee -a $LOG
      echo "# Verify the parameters passed into the'deleteMember.sh" | tee -a $LOG
      echo "# Perhaps you specified the wrong hostname on the '-h' flag or incorrect serverName on the -n flag" | tee -a $LOG 
      echo "#" | tee -a $LOG
      echo "# You entered the command as $SAVE_COMMAND" | tee -a $LOG
      echo "#------------------------------------------------------------------" | tee -a $LOG
    fi  
  fi
  
    
  echo "" 
  echo "remove_Remote_Member function completed" 
  echo "" 
  
}  
  

remove_Collective_Member()  
{

#remove Local Liberty server from the collective
     
  echo "" | tee -a $LOG
  echo "# removing member from  the collecive...." | tee -a $LOG
  echo "$WLP_HOME/bin/collective remove $SERVER_NAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin"  | tee -a $LOG
  echo "" | tee -a $LOG
  
  echo "----------------------------------------------------------------------------------"
  echo "Type 'y' when prompted to accept the certificate chain (collective remove member)." 
  echo "----------------------------------------------------------------------------------"
  sleep 10
    
  
  $WLP_HOME/bin/collective remove $SERVER_NAME --host=$CONTROLLER_HOSTNAME --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin

  if [[ $? != 0 ]]; then
   rc=$?
   echo "ERROR! Failed to remove $SERVER_NAME to the collective. See the error message that was returned!"
   exit $rc
  fi 

  echo "" 
  echo "Collective member $SERVER_NAME was removed from the collective." 
  echo "" 
  
}



  
remove_Local_Member() 
{ 
######################################################
#To know if a local Liberty server with the name specified is joined in the collective, the server directory must include /usr/server/serverName/resoures/collective
#
#So do not try to remove a collective member on the local host if its not expected to be a member. 
#Check if the /resources/collective directory exists for the server on the controller host
######################################################

 if [ ! -d "$WLP_HOME/usr/servers/$SERVER_NAME/resources/collective" ]; then
   echo "" | tee -a $LOG
   echo "# $WLP_HOME/usr/servers/$LIBERTY_SERVER is not a registered collective member on $MEMBER_HOSTNAME"  | tee -a $LOG
   echo "" | tee -a $LOG
   echo "# $SERVER_NAME may be registered on a different host: 'server1.gym.lan'"  | tee -a $LOG
   echo "" | tee -a $LOG
   
   exit 1
fi  
   

#check status of the server and verify it exists locally, and if its running. 
#rc=0: Server is running
#rc=1: Server not running
#rc=2: Server does not exist
#rc>2 bad errors!

  echo "" 
  echo "# See if the server exists and is it running" 
  echo "$WLP_HOME/bin/server status $SERVER_NAME"
  echo "" 
 
  $WLP_HOME/bin/server status $SERVER_NAME
  rc=$?
  echo "rc = $rc" 
  
  if [[ "$rc" > "2" ]]; then 
     echo "Could not verify Liberty Server $SERVER_NAME on $HOSTNAME."
     echo "See error massages!"
     exit $rc
  fi
  
  if [[ "$rc" = "2" ]]; then 
     echo "Server $SERVER_NAME does not exist on $HOSTNAME."
     echo "Verify the input paramters and that you are tryng to remove the member from the correct HOST"
     echo "Exiting with return code $rc from 'server status' command"
     exit 2
  else 
     echo "" | tee -a $LOG
     echo "# Stop the local Liberty Server member" | tee -a $LOG
     echo "$WLP_HOME/bin/server stop $SERVER_NAME" | tee -a $LOG
     echo "" | tee -a $LOG
 
     $WLP_HOME/bin/server stop $SERVER_NAME
  
     echo " " 
     echo "Server $SERVER_NAME has been stopped."
     echo " " 
  fi   


# Call routine to remove member from the collective
  remove_Collective_Member 

# remove the  Liberty server directory. This only gets called if the member was successfully removed from the collective.  
 
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


#MAIN PROGRAM

echo "========================="
echo "Running 'removeMember.sh'"
echo "========================="
  
 
  if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    remove_Remote_Member    
  else 
    remove_Local_Member
  fi
 
 echo "" | tee -a $LOG
 echo "The log files can be found in: $LOGS" | tee -a $LOG
 echo "ls -l $LOGS" | tee -a $LOG
 echo ""   | tee -a $LOG
 #ls -l $LOGS | tee -a $LOG
 
 echo "End of deleteMember.sh script." | tee -a $LOG
 
 