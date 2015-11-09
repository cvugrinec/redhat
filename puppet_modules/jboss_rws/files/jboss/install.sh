# Init
userPass="Jboss4All!"
BASEDIR=$(dirname $0)
installPath=`cat $BASEDIR/installer.xml  | grep installpath | sed -e 's/<[\/]installpath>//' | sed -e 's/<installpath>//g'` 

# Cleanup DIR and Symlinks and kill existing jboss
jbossProc=`ps -ef | grep -i jboss | grep -v grep`
if [[ $jbossProc != "" ]]
then
   kill $(ps -ef | grep -i jboss | grep -v grep | awk ' { print $2 } ') 
fi
if [ -d $installPath ]
then
   rm -rf $installPath
fi
if [ -f /opt/jboss ]
then
  rm -f /opt/jboss
fi

# Installation with silent installer
echo -e "$userPass\n$userPass\n"  | java -jar $BASEDIR/jboss-eap-6.4.0-installer.jar --file $BASEDIR/installer.xml

# Creating symbolic link
cd /opt
ln -s $installPath jboss
