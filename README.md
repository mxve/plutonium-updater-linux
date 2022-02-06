# Plutonium updater
#### Stop uploading, start downloading
###### (So catchy!)

## Features
- Version checking
- File hash (re)checking

![screenshot](https://screen.sbs/i/xbmyrmbx.png)

## Requirements
- jq
- wget
- bash

## Usage
- Download
  - ```wget https://raw.githubusercontent.com/mxve/plutonium-updater-linux/master/plutonium.sh```
- Make executable
  - ```chmod +x plutonium.sh```
- Run
  - ```./plutonium.sh```

#### Arguments:
- ```-d <path>```
  - Directory to install to, default is "plutonium"
- ```-f```
  - Force file hash recheck, otherwise only revision number will be checked
- ```-l```
  - Don't skip launcher assets
- ```-q```
  - Quiet(er), don't output every file action
