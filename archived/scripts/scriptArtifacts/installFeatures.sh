Var=$(echo 'cat //featureManager/feature/text()' | xmllint --shell  /home/techzone/Labfiles/server.xml  |grep -Ev '^/ >|^ -+$')


/home/techzone/wlp/bin/installUtility install $Var