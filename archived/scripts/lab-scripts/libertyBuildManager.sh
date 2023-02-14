#########################
#  libertyBuildManager.sh
#########################

#-install
#-create
#-package


#  -c COMMAND -v LIBETYVERSION 
#  -c install -v 22.0.0.8 

if [[ "$#" -lt 4 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-c command to run: <install | create | package>"
  echo "-v Verion of Liberty to install <22.0.0.8 | 22.0.0.12>"
  echo ""
  echo "example: libertyBuildManager.sh -c install -v 22.0.0.8"
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
    -c|--command)
    COMMAND_INPUT="$2"
    let "numKeys+=1" 
    shift # past argument
    ;;
    -v|--verion)
    LIBERTY_VERSION="$2"
     let "numKeys+=1"
    shift # past argument
    ;;
  esac
shift # past argument or value
#echo "numKeys: $numKeys"
done

#Make sure all of the required keys were passed in (-n -p -s -h)
if [[ $numKeys != 2 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "-c command to run: <install | create | package>"
  echo "-v Verion of Liberty to install <22.0.0.8 | 22.0.0.12>"
  echo ""
  echo "example: libertyBuildManager.sh -c install -v 22.0.0.8"
  echo ""
   echo "---------------------------------------"
  exit 1
fi


#Ensure the -c flag matches install | create | pacgae for this lab environment

echo "The '-c $COMMAND_INPUT' flag was specified for the script"

 if [[ "$COMMAND_INPUT" = "install" ]] || [[ "$COMMAND_INPUT" = "create" ]] || [[ "$COMMAND_INPUT" = "package" ]]; then
     echo "The command input is: $COMMAND_INPUT"
else 
     echo "The -c flag specified contains an invalid command parameter."
      echo "   specify 'install' to install Liberty"
      echo "   specify 'create' to create a Liberty server"
      echo "   specify 'package' to create a server package for a server"
     exit 1      
fi


#Verify -v flag matches 22.0.0.8 or 22.0.0.12
if [[ "$LIBERTY_VERSION" = "22.0.0.8" ]]; then 
    LIBERTY_ARCHIVE="wlp-kernel-22.0.0.8.zip"
elif [[ "$LIBERTY_VERSION" = "22.0.0.12" ]]; then 
    LIBERTY_ARCHIVE="wlp-kernel-22.0.0.12.zip"
else 
    echo "Only 22.0.0.8 and 22.0.0.12 are valid versions of Liberty for the lab environment"
    echo ""
    echo "Check your input paramters and rerun the script"
    exit 1	
fi

COMMAND_SAVE="libertyBuildManager.sh -c $COMMAND_INPUT -v $LIBERTY_VERSION" 
HOME_DIR=/home/techzone
LAB_FILES_DIR=$HOME_DIR/liberty_admin_pot/LabFiles/lab_1040
SCRIPT_ARTIFACTS=$LAB_FILES_DIR/scripts/scriptArtifacts
WORK_DIR=$HOME_DIR/lab-work
LIBERTY_ROOT=$WORK_DIR/Liberty-Builds
PACKAGED_SERVER_DIR=$WORK_DIR/packagedServers
WLP_HOME=$LIBERTY_ROOT/$LIBERTY_VERSION/wlp
PBW_SERVER_NAME="pbwServerX"

#INPUT_PORTS=$3
#HTTP_PORT=$(echo $3 | cut -f1 -d:)
#HTTPS_PORT=$(echo $3 | cut -f2 -d:)
#echo "http port: $HTTP_PORT"
#echo "https port: $HTTPS_PORT"




install_liberty()
{
#create a directory under Liberty_Builds for liberty 22.0.0.x
#unzip archive from Stundent labfiles to Liberty_Builds to 22.0.0.x dir

#Create the $LIBERTY_ROOT, if it does not already exist
if [ ! -d "$LIBERTY_ROOT" ]; then
    echo "Create the $LIBERTY_ROOT directory"
    mkdir $LIBERTY_ROOT
fi

#Fail if the $LIBERTY_ROOT/$LIBERTY_VERSION already exists
if [ ! -d "$LIBERTY_ROOT/$LIBERTY_VERSION" ]; then
    echo "Create the $LIBERTY_ROOT/$LIBERTY_VERSION directory"
    mkdir $LIBERTY_ROOT/$LIBERTY_VERSION
    unzip ~/Student/LabFiles/$LIBERTY_ARCHIVE -d $LIBERTY_ROOT/$LIBERTY_VERSION
else 
    echo "The drectory already exists: $LIBERTY_ROOT/$LIBERTY_VERSION"
    echo ""
    echo "Liberty $LIBERTY_VERSION may already be installed in $LIBERTY_ROOT"
    echo "" 
    echo "Verify the input parameters on the script" 
    echo "" 
    echo "The command you entered is: $COMMAND_SAVE"
    echo ""
    exit 1    
fi

}  



create_server()
{
#create server pbwServerX
#copy in the PBW server.xml
#create lib dir for db2 lbs
#copy in the db2 libs
#create configDropins/overrrides 
#copy in the memberOverrides.xml
#Update ports in the memberOverrides.xml file

#  -c COMMAND -v LIBETYVERSION 
#  -c install -v 22.0.0.8 

#fail if Liberty is not installed for the specified verison
if [ ! -d "$WLP_HOME" ]; then
    echo "Liberty is not installed for the spcified verison $LIBERTY_VERSION in directory $WLP_HOME"
   echo ""
   echo "You entered the following command: $COMMAND_SAVE"
   echo ""
   echo "Correct the input paramters for the script, and rerun the script."
   exit 1
fi

#fail if Liberty server pbwServerX is already created in the specified version
if [ -d "$WLP_HOME/usr/servers/$PBW_SERVER_NAME" ]; then
   echo "The $PBW_SERVER_NAME server already seems to be created for $LIBERTY_VERSION in $WLP_HOME"
   echo ""
   echo "You entered the following command: $COMMAND_SAVE"
   echo ""
   echo "Correct the input paramters for the script, and rerun the script. Or, delete the $LIBERTY_ROOT/$LIBERTY_VERSION directory and retry."
   exit 1
fi


$WLP_HOME/bin/server create $PBW_SERVER_NAME
rc=$?
if [[ "$rc" != "0" ]]; then
  echo "Could not create the Liberty Server $PBW_SERVER_NAME, exiting!"
  exit 1
fi  
  

\cp $LAB_FILES_DIR/plantsbywebsphereee6.ear $WLP_HOME/usr/servers/$PBW_SERVER_NAME/apps

mkdir $WLP_HOME/usr/shared/config/lib

\cp /opt/IBM/db2_drivers/* $WLP_HOME/usr/shared/config/lib

\cp $LAB_FILES_DIR/server.xml $WLP_HOME/usr/servers/$PBW_SERVER_NAME


#Create the configDropins/overrides directory
  echo "" | tee -a $LOG
  echo "# create the configDropins/overrides directory" | tee -a $LOG
  echo "mkdir $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins" | tee -a $LOG
  echo "mkdir $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins/overrides" | tee -a $LOG
  echo "" | tee -a $LOG
    
    
  mkdir $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins | tee -a $LOG
  mkdir $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins/overrides | tee -a $LOG
  echo "Librty server configDropins folders created" 


#Copy the memberOverride.xml into the configDropins/overrides directory
  echo "" | tee -a $LOG
  echo "# Copy the memberOverride.xml into the configDropins/overrides directory" | tee -a $LOG
  echo "cp $SCRIPT_ARTIFACTS/memberOverride.xml $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins/overrides/." | tee -a $LOG
  echo "" | tee -a $LOG  
  
  cp $SCRIPT_ARTIFACTS/memberOverride.xml $WLP_HOME/usr/servers/$PBW_SERVER_NAME/configDropins/overrides/. 
  
  sleep 5
  

#Install the additional features required for the server
$WLP_HOME/bin/installUtility install $PBW_SERVER_NAME --acceptLicense
$WLP_HOME/bin/installUtility install collectiveMember-1.0 --acceptLicense
$WLP_HOME/bin/installUtility install dynamicRouting-1.0 --acceptLicense
$WLP_HOME/bin/installUtility install sessionDatabase-1.0 --acceptLicense


}





create_packaged_server()
{

#Package the Liberty Archive if it is for a REMOTE deployment
  echo "Package the Liberty Archive" 

echo "PACKAGED_SERVER_DIR: $PACKAGED_SERVER_DIR"

FULL_PATH_PACKAGED_SERVER_PATH=$PACKAGED_SERVER_DIR/$LIBERTY_VERSION-$PBW_SERVER_NAME

#First verify the server you intend to package exists in $WLP_HOME
if [ ! -d "$WLP_HOME/usr/servers/$PBW_SERVER_NAME" ]; then
   echo "The $PBW_SERVER_NAME does not exist for $LIBERTY_VERSION in $WLP_HOME"
   echo ""
   echo "You entered the following command: $COMMAND_SAVE"
   echo ""
   echo "Correct the input paramters for the script, and rerun the script. Or, run the script with the 'create' flag to create the server."
   exit 1
fi

  
#Create the packagedServers directory if it does not already exist
if [ ! -d "$PACKAGED_SERVER_DIR" ]; then
    echo "Create the $PACKAGED_SERVER_DIR directory"
    mkdir $PACKAGED_SERVER_DIR
fi

#Create the packagedServers BACKUP directory if it does not already exist
if [ ! -d "$PACKAGED_SERVER_DIR/backups" ]; then
    echo "Create the $PACKAGED_SERVER_DIR/backups directory"
    mkdir $PACKAGED_SERVER_DIR/backups
fi

#If server package with same name already exists, make a backup of it, and recreate a new one

echo "Full path of server package archive: $FULL_PATH_PACKAGED_SERVER_ARCHIVE" 

if [ -f "$FULL_PATH_PACKAGED_SERVER_PATH.zip" ]; then
    echo "copy archive: \cp $FULL_PATH_PACKAGED_SERVER_PATH.zip $PACKAGED_SERVER_DIR/backups:"
    
    \cp $FULL_PATH_PACKAGED_SERVER_PATH.zip $PACKAGED_SERVER_DIR/backups
    
    echo "rm archive"
    rm $FULL_PATH_PACKAGED_SERVER_PATH.zip ;
    echo "removed $FULL_PATH_PACKAGED_SERVER_PATH.zip"
fi

  
    echo "" | tee -a $LOG
    echo "# Package the Liberty Archive. Package incudes Binaries and application" | tee -a $LOG
    echo "$WLP_HOME/bin/server package $PBW_SERVER_NAME --archive="$FULL_PATH_PACKAGED_SERVER_PATH.zip" --include=all" | tee -a $LOG
    echo "" | tee -a $LOG
  
    $WLP_HOME/bin/server package $PBW_SERVER_NAME --archive="$FULL_PATH_PACKAGED_SERVER_PATH.zip" --include=all 
     
     rc=$?
    if [[ $rc != 0 ]]; then
      echo "FAILED to create the Liberty server package. See the error message that was returned!"
      exit $rc
    fi   
    
    echo "Liberty server package created: $FULL_PATH_PACKAGED_SERVER_PATH.zip" 
    sleep 5
  
}
  


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
  
#MAIN PROGRAM

echo "================================"
echo "Running 'libertyBuildManager.sh'"
echo "================================"
  

if [[ "$COMMAND_INPUT" = "install" ]]; then 
    install_liberty
fi

if [[ "$COMMAND_INPUT" = "create" ]]; then 
    create_server
fi
    

if [[ "$COMMAND_INPUT" = "package" ]]; then 
    create_packaged_server
fi
        
 
  
  
  
  
  
  
  
  
