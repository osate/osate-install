# OSATE Installation script

This repository provides an automated installation script for OSATE
from https://osate.org.

It has been tested on Linux and macOS.


## Usage

From the terminal, simply issue the following command


```
./install-script.sh
```

The script will directly download the latest release of OSATE, and
install it in the `osate2-<release>` directory.

For macOS platform, the script will ask for an adminator password to
remove `osate.app` from quarantine as detailed here:
https://osate.org/download-and-install.html#detailed-installation-for-macos