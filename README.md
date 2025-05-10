# Debian-preseed
Tools and (above all) a few reasonable configs to quickly create custom Debian ISO images.

----

### General info
The [Debian GNU/Linux Installation Guide](https://www.debian.org/releases/stable/amd64/index.en.html) refers to `preseeding` as a "way to set answers to questions asked during the installation process, without having to manually enter the answers". This provides for a method to automate installations as much as possible: almost zero-click!<br/>
The process starts by means of two files included in this repository:
1. `preseed_cfg.tmpl`: a reasonably complete preseed file, see [an example here](https://www.debian.org/releases/stable/example-preseed.txt), which must be customized through...
2. `dicustomizer.sh`: an interactive Bash script which asks questions, such as `hostname`, `IP address`, and will produce the actual `preseed.cfg` file
<br/>
Once the preseed file is available an ISO file must be fabricated by injecting `preseed.cfg` into `initrd`. Additional customization is done on `isolinux` to start the installation without requiring any input from the user.<br/>
The ISO file is based on an official Debian installation ISO, e.g. `debian-12.10.0-amd64-netinst.iso`, which must be downloaded separately.<br/>

----

### Procedure
1. Set up the directory structure
```
$ ./preseed_init.sh -d <project_name>
[+] Creating/updating hierarchy in directory '<project_name>.proj'
[+] NEW directory <project_name>.proj created, OK
[+] NEW directory <project_name>.proj/destination_iso created, OK
[+] NEW directory <project_name>.proj/source_iso created, OK
[+] NEW directory <project_name>.proj/workdir created, OK
[+] NEW directory <project_name>.proj/loopdir created, OK
```

2. Download the source ISO file
```
$ curl -sSLfO https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso

$ mv debian-12.10.0-amd64-netinst.iso source_iso/
```

3. Generate the customized `preseed.cfg`
```
$ ./dicustomizer.sh
```

4. Finally, create the customized ISO
```
$ sudo ./mkiso_preseed.sh
```
**NOTE**: **root** credentials needed

----

#### Useful links
- https://wiki.debian.org/DebianInstaller/Preseed
- https://wiki.debian.org/DebianInstaller/Preseed/EditIso

