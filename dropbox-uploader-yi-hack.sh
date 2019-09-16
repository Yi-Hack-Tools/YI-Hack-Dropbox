#!/bin/bash
CAMERAIP=''
FTPPORT=21
USER='root'
PASSWD=''
REMOTEROOTDIR=''
FOLDER=''

case "$(curl -s --max-time 2 -I http://dropbox.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) echo -e "\e[32mHTTP connectivity is up\e[0m";;
  5) echo -e "\e[31mThe web proxy won't let us through\e[0m" && exit;;
  *) echo -e "\e[31mCould not connect to dropbox.com: The network is down or very slow\e[0m" && exit;;
esac

if [ -d "/tmp/$FOLDER" ]; then
  echo -e "\e[31mdropbox-uploader for $FOLDER seems to be alerady running. Exiting.\e[0m" && exit
else
  echo -e "\e[32mReady to run.\e[0m" && mkdir /tmp/$FOLDER
fi

if find $HOME -maxdepth 1 -name '*Dropbox-Uploader*' -printf 1 -quit | grep -q 1
then
    echo found
else
    

  echo -e "\e[1mDropbox-Uploader was not found at $HOME\e[0m"
  echo -e "\e[1mDownloading now...\e[0m"
  git clone https://github.com/andreafabrizi/Dropbox-Uploader.git $HOME/Dropbox-Uploader
  chmod -R +x $HOME/Dropbox-Uploader
  echo -e "Now, please run $HOME/Dropbox-Uploader/dropbox_uploader.sh to set your account." && exit
fi
__cleanup ()
{
    echo -e "\e[31mExiting: Cleaning up.\e[0m" 
    rm -r /tmp/$FOLDER
}
trap __cleanup EXIT

cd /tmp/$FOLDER

echo -e "Listing files in the camera's sd card...\n"
mapfile -t CAMFILES < <(curl -l ftp://$CAMERAIP:$FTPPORT//tmp/sd/record/record --user $USER:$PASSWD)

bash $HOME/Dropbox-Uploader/dropbox_uploader.sh mkdir $REMOTEROOTDIR/$FOLDER
echo -e "Listing files in Dropbox... This may take a while\n"
mapfile -t REMOTE < <(bash $HOME/Dropbox-Uploader/dropbox_uploader.sh list $REMOTEROOTDIR/$FOLDER)

LASTREMOTE2=${REMOTE[@]:(-1)}
LASTREMOTE=$(echo $LASTREMOTE2 | cut -d' ' -f2-)

echo -e "the last remote is $LASTREMOTE"

echo -e "\e[1mFound' ${#CAMFILES[@]} 'directories in the camera's sd card:  \n"
printf '%s\n' "${CAMFILES[@]}"
echo -e "\e[0m=====================================================\n"

if [[ ${#REMOTE[@]} -eq 0 ]];
then
LASTCUTCONV='1'
echo "remote =0"
else
LASTCUT2=$(echo $LASTREMOTE | sed 's/[A-Za-z]*//g')
echo "LASTCUT2 IS $LASTCUT2"
  LASTCUT=$(echo ${LASTCUT2:0:4}'-'${LASTCUT2:4:2}'-'${LASTCUT2:6:2}' '${LASTCUT2:8:2})
echo "LASTCUT IS $LASTCUT"
LASTCUTCONV=$(date -d "$LASTCUT" +%s)
echo "LASTCUTCONV IS $LASTCUTCONV"
fi

for DIR in "${CAMFILES[@]}"
do
	
  DIRCUT2=$(echo $DIR | sed 's/[A-Za-z]*//g')
echo "DIRCUT2 IS $DIRCUT2"
  DIRCUT=$(echo ${DIRCUT2:0:4}'-'${DIRCUT2:4:2}'-'${DIRCUT2:6:2}' '${DIRCUT2:8:2})
echo "DIRCUT IS $DIRCUT"
  DIRCUTCONV=$(date -d "$DIRCUT" +%s)
echo "DIRCUTCONV IS $DIRCUTCONV"

    if [ $DIRCUTCONV -gt $LASTCUTCONV ];
    then
    echo "working with $DIR"
    wget -r -nH --cut-dirs=4 --no-parent --reject="tmp.*" --user=$USER --password=$PASSWD ftp://$CAMERAIP:$FTPPORT//tmp/sd/record/$DIR/*
    mapfile -t MEDIA < <(ls $DIR/)
		for FILE in "${MEDIA[@]}"
		do
			bash $HOME/Dropbox-Uploader/dropbox_uploader.sh -s upload $DIR/$FILE $REMOTEROOTDIR/$FOLDER/$DIR/$FILE
		done
     echo -e "\e[0m====================================================="
     echo -e "\e[1mremoving" $DIR
     echo -e "\e[0m"
     rm -r $DIR
fi  
	
done

rm -r /tmp/$FOLDER


