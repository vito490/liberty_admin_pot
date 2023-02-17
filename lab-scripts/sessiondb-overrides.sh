#########################
#  sessiondb-overrides.sh
#########################
if [[ "$#" -lt 6 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
   echo "Usage:" 
  echo "-n Liberty member name"
  echo "-v Verion of Liberty to install <22.0.0.8 | 22.0.0.12>"
  echo "-h Liberty member hostname" 
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: asessiondb-overrides -n server1 -v 22.0.0.8 -h server0.gym.lan"
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
    -v|--verion)
    LIBERTY_VERSION="$2"
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

#Make sure all of the required keys were passed in (-n -s -h)
if [[ $numKeys != 3 ]]; then
  echo "---------------------------------------"
  echo "Missing required FLAGS, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-n Liberty member name"
  echo "-v Verion of Liberty to install <22.0.0.8 | 22.0.0.12>"
  echo "-h Liberty member hostname" 
  echo "   specify 'server0.gym.lan' for creating a local collective member"
  echo "   specify 'server1.gym.lan' for creating a remote collective member"
  echo ""
  echo "example: sessiondb-overrides -n server1 -v 22.0.0.8 -p 9080:9443 -h server0.gym.lan"
  echo ""
  echo "---------------------------------------"
  exit 1
fi

#Lab environment variable
LAB_HOME=/home/techzone
WORK_DIR=$LAB_HOME/lab-work
LAB_FILES=$LAB_HOME/liberty_admin_pot
SCRIPT_ARTIFACTS=$LAB_FILES/lab-scripts/scriptArtifacts
LOGS=$WORK_DIR/logs
SAVE_COMMAND="sessiondb-override.sh -n $SERVER_NAME -v $LIBERTY_VERSION -h $MEMBER_HOSTNAME"


LIBERTY_ROOT=$WORK_DIR/liberty-staging
WLP_HOME="$LIBERTY_ROOT/$LIBERTY_VERSION-$SERVER_NAME/wlp"  #this needs to be the liberty home for the verion of Liberty unzipped

LOG=$LOGS/sessiondb-overrides-$LIBERTY_VERSION-$SERVER_NAME.log

#Controller variables
CONTROLLER_NAME="CollectiveController"
CONTROLLER_ROOT_DIR="$WORK_DIR/liberty-controller"
CONTROLLER_HTTPS_PORT=9491
CONTROLLER_HOSTNAME=`hostname`
CONTROLLER_WLP_HOME="$CONTROLLER_ROOT_DIR/wlp"


#Remote member variables
KNOWN_REMOTE_HOST1="server1.gym.lan"


#Ensure the -h flag contains a valid hostname for this lab environment

 if [[ "$MEMBER_HOSTNAME" = "$CONTROLLER_HOSTNAME" ]] || [[ "$MEMBER_HOSTNAME" = "$KNOWN_REMOTE_HOST1" ]]; then
      echo " "
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
  WLP_HOME_REMOTE="/opt/IBM/liberty-staging"
fi


echo "#----------------------------------" 
echo "# Now running sessiondb-overrides.sh" 
echo "#----------------------------------" 

sleep 5


# List the variables used in the script
echo " "  
echo "#-------------------------------------------------------------" 
echo "# Applying server configuration overrides for $MEMBER_TYPE Liberty server: $SERVER_NAME" 
echo "#-------------------------------------------------------------" 
echo " "  
echo "# Command entered: $SAVE_COMMAND" 
echo "" 


remote-sessiondb-overrides()
{


echo "# scp command: scp $SCRIPT_ARTIFACTS/sessiondb-override.xml techzone@$MEMBER_HOSTNAME:$WLP_HOME_REMOTE/$LIBERTY_VERSION-$SERVER_NAME/wlp/usr/servers/$SERVER_NAME/configDropins/overrides"

scp $SCRIPT_ARTIFACTS/sessiondb-override.xml techzone@$MEMBER_HOSTNAME:$WLP_HOME_REMOTE/$LIBERTY_VERSION-$SERVER_NAME/wlp/usr/servers/$SERVER_NAME/configDropins/overrides

if [[ $? = 0 ]]; then  
  echo ""
  echo "============================================================="
  echo ""
  echo "SUCCESS: Applying the sessiondb overides file was successful."
  echo ""
  echo "============================================================="
  echo ""
else  
  echo ""
  echo "============================================================="
  echo ""
  echo "ERROR: Could not copy the sessiondb overrides file to the server $SERVER_NAME on host $MEMBER_HOSTNAME"
  echo ""
  echo "---> Verify the server exists on the specified HOST."
  echo "---> Verify the input paramters on the script are corect and be sure you have specified the correct servername, hostname, and version."
  echo ""
  echo "============================================================="
  exit 1
fi  

}



local-sessiondb-overrides() 
{ 
 
#copy the sessiondb overrides file if the server directroy exists


if [ -d "$WLP_HOME/usr/servers/$SERVER_NAME" ]; then
  echo "# cp command: cp $SCRIPT_ARTIFACTS/sessiondb-override.xml $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides"

  cp $SCRIPT_ARTIFACTS/sessiondb-override.xml $WLP_HOME/usr/servers/$SERVER_NAME/configDropins/overrides
else
  echo "The server $WLP_DIR/usr/servers/$SERVER_NAME directory was not found"
  exit 1
fi

  
if [[ $? = 0 ]]; then  
    echo ""
    echo "============================================================="
    echo ""
    echo "SUCCESS: Applying the sessiondb overides file was successful."
    echo ""
    echo "============================================================="
    echo ""  
  else  
    echo ""
    echo "============================================================="
    echo ""
    echo "ERROR: Could not copy the sessiondb overrides file to the server $SERVER_NAME on host $MEMBER_HOSTNAME"
    echo ""
    echo "---> Verify the server exists on the specified HOST."
    echo "---> Verify the input paramters on the script are corect and be sure you have specified the correct servername, hostname, and version."
    echo ""
    echo "============================================================="
    exit 1
fi  

} 


#MAIN PROGRAM

echo "================================"
echo "Running 'sessiondb-overrides.sh'"
echo "================================"
   
  if [[ "$MEMBER_TYPE" = "remote" ]]; then 
    remote-sessiondb-overrides
  else 
    local-sessiondb-overrides
  fi
 
  
 echo "" 
 echo "# End of sessiondb-overrides.sh script."
 echo ""
 