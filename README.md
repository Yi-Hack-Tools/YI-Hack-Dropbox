# YI-Hack-Dropbox
![](https://i.imgur.com/ODrurrc.png)

Uploads recorded media to Dropbox


This script will not run in any camera: it was made to run in a "normal" computer.

### Depends:
* curl
* wget

### Running:
```
git clone https://github.com/Yi-Hack-Tools/YI-Hack-Dropbox
chmod -R +x YI-Hack-Dropbox
./YI-Hack-Dropbox/dropbox-uploader-yi-hack.sh
```
You must edit the script in order to set some variables:
```
CAMERAIP=''       # the ip address of your camera.
FTPPORT=21        # 21 by default
USER='root'       # root by default
PASSWD=''         # the password of the camera
REMOTEROOTDIR=''  # the directory for the cameras
FOLDER=''         # directory inside the rootdir (e.g. the name of the camera)

```
### About the REMOTEROOTDIR variable:
Example:
```
├── MyCameras               -----> This is the REMOTEROOTDIR variable
│   ├── Kitchen             -----> This is the FOLDER variable (in this case, the name of the camera)
│   │   ├── 2019Y09M11D12H  -----> Contains the recorded media 
│   │   ├── 2019Y09M11D13H
│   │   ├── 2019Y09M11D14H
│   │   ├── ...
│   ├── Garden              -----> This is the FOLDER variable (for another camera, in another script)
│   │   ├── 2019Y09M12D09H 
│   │   ├── 2019Y09M12D10H
│   │   ├── 2019Y09M12D14H
```
