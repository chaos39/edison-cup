# Better Cup - Intel Edison Board Code

The code running on the Edison board for the Better Cup project.


## Installation

SSH on the Edison, and run the commands below to install Intel's MRAA and UPM
libraries.

```bash
echo "src iotkit http://iotdk.intel.com/repos/1.5/intelgalactic" > /etc/opkg/iotkit.conf
opkg update
opkg upgrade
```

While SSHed on the Edison, run the commands below to install Cairo.

```bash
echo "src all http://iotdk.intel.com/repos/1.5/iotdk/all" > /etc/opkg/iotdk-extras.conf
echo "src core2-32 http://iotdk.intel.com/repos/1.5/iotdk/core2-32" >> /etc/opkg/iotdk-extras.conf
echo "src i586 http://iotdk.intel.com/repos/1.5/iotdk/i586" >> /etc/opkg/iotdk-extras.conf
echo "src x86 http://iotdk.intel.com/repos/1.5/iotdk/x86" >> /etc/opkg/iotdk-extras.conf
opkg update
opkg install libcairo-dev
```

While SSHed on the Edison, run the commands below to enable Bluetooth.

```bash
systemctl disable bluetooth
rfkill unblock all
/lib/systemd/systemd-rfkill save rfkill0
/lib/systemd/systemd-rfkill save rfkill1
/lib/systemd/systemd-rfkill save rfkill2
/lib/systemd/systemd-rfkill save rfkill3
```

While SSHed on the Edison, point it to your test server, for development.

```bash
mkdir -p ~/.edison-cup
echo "http://192.168.2.2:3000" > ~/.edison-cup/server.url
```


## License

This project is Copyright (c) 2015 Victor Costan and Staphany Park, and
distributed under the MIT License.
