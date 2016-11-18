---
slug: using-dropbox-as-a-distributed-backup
author: Steve Good
date: 2011-10-22
title: Using Dropbox as a Distributed Backup
draft: false
tags:
- Dropbox
- Python
---

A while back I made some improvements to the backup scheme we use at [KaiNexus](http://kainexus.com/). The requirements were pretty simple and straight forward. All our backups had to be encrypted, offsite and distributed. While there are a number of for-pay backup solutions out there we were looking for the bare minimum and free solution.

At the office, we all use [Dropbox](http://db.tt/JbuaZVj) for file sharing so it seemed like a logical tool to use since we were all familiar with it. Dropbox lets us check off two requirements by being both off site and distributed. Here's my step-by-step guide on getting Dropbox setup on an Ubuntu server with minimal effort. I'm not covering the file encryption bit in this post but if you want to know how I did it let me know and I'll do a writup on it.

The steps outlined here were put together after reading through a couple of [other](http://welcometoubuntu.blogspot.com/2010/05/howto-install-python-255-on-ubuntu-1004.html) [guides](http://wiki.dropbox.com/TipsAndTricks/UbuntuServerInstall). Feel free to read those guides if you want but you should be able to get everything you need from what I have below.

## Install Python

1. Install build-essentials and gcc

    ```bash
    sudo apt-get install build-essential gcc
    ```

2. Download Python 2.5.5 (This seems to be the officially supported version)

    ```bash
    wget http://www.python.org/ftp/python/2.5.5/Python-2.5.5.tgz
    ```

3. Extract

    ```bash
    tar -xvzf Python-2.5.5.tgz
    ```

4. Compile and install

    ```bash
    cd Python-2.5.5
    ./configure --prefix=/usr/local/python2.5
    make
    sudo make install
    sudo ln -s /usr/local/python2.5/bin/python /usr/bin/python2.5
    ```

## Install Dropbox

1. Switch to root user

    ```bash
    sudo -s
    ```

2. Create dropbox user and group and set the user's home to be** ```/etc/dropbox```

    ```bash
    groupadd dropbox
    useradd -r -d /etc/dropbox -g dropbox -s /bin/false dropbox
    ```

3. Download the 64-bit Dropbox binary

    ```bash
    wget -O /tmp/dropbox.tar.gz http://www.dropbox.com/download/?plat=lnx.x86_64
    ```

4. Create the dropbox user's home and set the ownership and permissions

    ```bash
    mkdir -p /usr/local/dropbox /etc/dropbox
    chown dropbox.dropbox /etc/dropbox
    chmod 700 /etc/dropbox
    ```

5. Extract the dropbox binaries

    ```bash
    tar xvzf /tmp/dropbox.tar.gz -C /usr/local/dropbox --strip 1
    ```

6. Remove the dropbox archive

    ```bash
    rm /tmp/dropbox.tar.gz
    ```

7. Switch to the dropbox user

    ```bash
    su -l dropbox -s /bin/bash
    ```

8. Set the user's permissions

    ```bash
    umask 0027
    ```

9. Execute the dropbox daemon _(Note: A URL will be repeated in the terminal window if the install machine is not registered to an account. Navigate to the URL (while logged in under the account you wish to link) and wait for the prompt to notify you that you are now linked. You'll get a simple welcome message.)_

    ```bash
		/usr/local/dropbox/dropboxd
    ```

10. Terminate the dropbox daemon with ```ctrl+c```
11. Log out of the dropbox user

    ```bash
    exit
    ```

12. Create the control script

    ```bash
    cat >> EOF | sed -e "s,%,$,g" >/etc/init.d/dropbox
    ### BEGIN INIT INFO
    # Provides:          dropbox
    # Required-Start:    $local_fs
    # Required-Stop:     $local_fs
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: starts the dropbox service
    # Description:       starts dropbox using start-stop-daemon
    ### END INIT INFO

    DROPBOX_USERS="dropbox"
    DAEMON=/usr/local/dropbox/dropbox
    unset DISPLAY

    start() {
        echo "Starting dropbox..."
        for dbuser in %DROPBOX_USERS; do
            HOMEDIR=%(getent passwd %dbuser | cut -d: -f6)
            if [ -x %DAEMON ]; then
                HOME="%HOMEDIR" start-stop-daemon -b -o -c %dbuser -S -u %dbuser -x %DAEMON
            fi
        done
    }

    stop() {
        echo "Stopping dropbox..."
        for dbuser in %DROPBOX_USERS; do
            HOMEDIR=%(getent passwd %dbuser | cut -d: -f6)
            if [ -x %DAEMON ]; then
                start-stop-daemon -o -c %dbuser -K -u %dbuser -x %DAEMON
            fi
        done
    }

    status() {
        for dbuser in %DROPBOX_USERS; do
            dbpid=%(pgrep -u %dbuser dropbox)
            if [ -z %dbpid ] ; then
                echo "dropboxd for USER %dbuser: not running."
            else
                echo "dropboxd for USER %dbuser: running (pid %dbpid)"
            fi
        done
    }


    case "%1" in
      start)
        start
        sleep 1
        status
        ;;

      stop)
        stop
        sleep 1
        status
        ;;

      restart|reload|force-reload)
        stop
        start
        sleep 1
        status
        ;;

      status)
        status
        ;;

      *)
        echo "Usage: /etc/init.d/dropbox {start|stop|reload|force-reload|restart|status}"
        exit 1

    esac

    exit 0
    EOF
    ```

13. Allow the control script to me executed and set it to autostart

    ```bash
    chmod a+x /etc/init.d/dropbox
    update-rc.d dropbox defaults
    ```

14. Start dropbox

    ```bash
    /etc/init.d/dropbox start
    ```

You should now have Dropbox running as a service on your server. All that's left is to create your cron jobs that run your backup scripts and have those backup files placed into the _/etc/dropbox/Dropbox_ folder.
