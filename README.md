# upwork-linux-hidraw-configuration

This version of script should work with Debian 11 / kernel 5.10.x
The script should be run like this

```bash
git clone $THIS\_REPO
cd $THIS\_REPO
bash build-new-kernel.sh
```

or if using different kernel version and config

```bash
SOURCEDIR=linux-$VERSION CONFIG=/boot/config-$VERSION bash-new-kernel.sh
```

