ssh-gpg-smartcard-config
========================

This document covers the procedure for configurating a system to use gpg smartcards for ssh authentication. The benefit is a good model for `two-factor authentication <http://en.wikipedia.org/wiki/Two-factor_authentication>`_, something you have and something you know. In this example, there is a token and a passphrase. 

The `Gemalto USB Shell Token V2 <http://shop.kernelconcepts.de/product_info.php?cPath=1_26&products_id=119>`_ and the `OpenPGP SmartCard V2 <http://shop.kernelconcepts.de/product_info.php?products_id=42&osCsid=101f6f90ee89ad616d2eca1b31dff757>`_ are used here, though there are many combinations that will work.

Examples below are using a Fedora 17 x86_64 fresh install, there are other tutorials for other operating systems available online. See the CREDITS section below for alternate tutorials, examples, etc.

Configuring Authentication with GNOME-Shell
-------------------------------------------
To configure authentication using the previously generated GnuPG key, the GNOME-Shell needs some adjustements. With help from several resources, configure the system to allow ``gpg-agent`` to take over ssh authentication.

Certain software must be installed, including ``gnupg2`` (which is probably already installed), ``gnupg2-smime``, ``pcsc-lite``, and ``pcsc-lite-ccid``::

  # yum install gnupg2-smime pcsc-lite pcsc-lite-ccid
  .. snip ..
  Complete!

Configure GNOME-Shell to use gpg-agent
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Turn off ssh-agent inside gnome-keyring-daemon::

  $ gconftool-2 --type bool --set /apps/gnome-keyring/daemon-components/ssh false

Configure gpg to use agent (only for smartcard)::

  $ gpg --list-keys | head -n 1
  $ echo "use-agent" >> ~/.gnupg/gpg.conf

Enable ssh-agent drop in replacement support for gpg-agent::

  $ echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf

Intercept gnome-keyring-daemon and put gpg-agent in place for ssh authentication (Ubuntu)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Open Startup Applications

Uncheck "GPG Password Agent" and "SSH Key Agent"

.. image:: startup_apps_checked.png

Edit ``/usr/share/upstart/sessions/gpg-agent.conf`` so that the pre-start script contains the following::

  eval "$(gpg-agent --daemon --enable-ssh-support --sh)" >/dev/null
  initctl set-env --global GPG_AGENT_INFO=$GPG_AGENT_INFO
  initctl set-env --global SSH_AUTH_SOCK=$SSH_AUTH_SOCK
  initctl set-env --global SSH_AGENT_PID=$SSH_AGENT_PID

Add the following lines to the post-stop script section::

  initctl unset-env --global SSH_AUTH_SOCK
  initctl unset-env --global SSH_AGENT_PID

Disable the other system gpg-agent::

  mv /etc/X11/Xsession.d/90gpg-agent ~/bak/90gpg-agent

Note: We could have used the Xsession gpg-agent and trashed the upstart one, but there is an `open bug report <https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=642021>`_ for 90gpg-agent. Also, the upstart script has the capability of exporting the environment variables globally with initctl set-env --global.

Intercept gnome-keyring-daemon and put gpg-agent in place for ssh authentication (Fedora)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
If running gnome, this problem may be solved by running the following to disable gnome-keyring from autostarting its broken gpg-agent and ssh-agent implementation::

  mv /etc/xdg/autostart/gnome-keyring-gpg.desktop /etc/xdg/autostart/gnome-keyring-gpg.desktop.inactive

  mv /etc/xdg/autostart/gnome-keyring-ssh.desktop /etc/xdg/autostart/gnome-keyring-ssh.desktop.inactive

Next, place the following in ``~/.bashrc`` to ensure gpg-agent starts with ``--enable-ssh-support``
::

    if [ ! -f /tmp/gpg-agent.env ]; then
        killall gpg-agent;
        eval $(gpg-agent --daemon --enable-ssh-support > /tmp/gpg-agent.env);
    fi
    . /tmp/gpg-agent.env

Now go to next step (Reload GNOME-Shell) :)

Reload GNOME-Shell
------------------

Reboot the machine works the best.

Setting PINs
------------

Included with the gemalto token and GnuPG Smartcard version 2 should be a document describing the default PIN values. There is a regular PIN, which is used to unlock the token for Signing, Encryption or Authentication. Additionally, there is an Admin PIN, which is used to reset the PIN and/or the Reset Code for the key itself.

Admin PIN
~~~~~~~~~

::

  $ gpg --card-edit
  ..snip..

  gpg/card> admin
  Admin commands are allowed

  gpg/card> passwd
  gpg: OpenPGP card no. D27600012401020000050000158A0000 detected

  1 - change PIN
  2 - unblock PIN
  3 - change Admin PIN
  4 - set the Reset Code
  Q - quit

  Your selection? 3

Enter the Current Admin PIN

.. image:: http://sexysexypenguins.com/misc/gpg-admin.png

Then enter the New Admin PIN twice

.. image:: http://sexysexypenguins.com/misc/gpg-new-admin.png

PIN
~~~

::

  1 - change PIN
  2 - unblock PIN
  3 - change Admin PIN
  4 - set the Reset Code
  Q - quit

  Your selection? 1

Enter the Current PIN

.. image:: http://sexysexypenguins.com/misc/gpg-pin.png

Then enter the New PIN twice

.. image:: http://sexysexypenguins.com/misc/gpg-new-pin.png

**NOTE:** If the Admin PIN has not been entered, it may be required before changes are applied.

Generating an SSH Key using GnuPG
---------------------------------

There are several ways to generate an SSH Key using GnuPG. A common way is to link the new Authentication key to an already existing key::

  $ gpg --edit-key 8A8F1D53
  gpg (GnuPG) 1.4.12; Copyright (C) 2012 Free Software Foundation, Inc.
  This is free software: you are free to change and redistribute it.
  There is NO WARRANTY, to the extent permitted by law.

  Secret key is available.

  pub  3072R/8A8F1D53  created: 2012-10-06  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
  sub  3072R/2F15E06B  created: 2012-11-23  expires: 2022-11-21  usage: S
  sub  3072R/EB8B4EBD  created: 2012-11-24  expires: 2022-11-22  usage: E
  sub  3072R/6BB325E9  created: 2012-11-24  expires: 2022-11-22  usage: A
  [ultimate] (1). Clint Savage <herlo1@gmail.com>
  [ultimate] (2)  Clint Savage <herlo@fedoraproject.org>
  [ultimate] (3)  Clint Savage <csavage@linuxfoundation.org>

  gpg>

Once in the ``edit-key`` dialog, create a key on the card::

  gpg> addcardkey
  Signature key ....: 91BC 60CC B9EC 8E73 923A  FC6D 58CD 88A6 2F15 E06B
  Encryption key....: 0CC3 DC3E 0D17 6111 A62B  F656 63C6 4DA9 EB8B 4EBD
  Authentication key: 9EBF A9FE 8AE1 0FEB 1699  CE9A 779F 43D5 EC6F CC13

  Please select the type of key to generate:
     (1) Signature key
     (2) Encryption key
     (3) Authentication key
  Your selection? 3

  gpg: WARNING: such a key has already been stored on the card!

  Replace existing key? (y/N) y
  What keysize do you want for the Authentication key? (3072)
  Key is protected.

  You need a passphrase to unlock the secret key for
  user: "Clint Savage <herlo1@gmail.com>"
  3072-bit RSA key, ID 8A8F1D53, created 2012-10-06

  Please specify how long the key should be valid.
           0 = key does not expire
        <n>  = key expires in n days
        <n>w = key expires in n weeks
        <n>m = key expires in n months
        <n>y = key expires in n years
  Key is valid for? (0) 10y
  Key expires at Mon 21 Nov 2022 05:29:00 PM MST
  Is this correct? (y/N) y
  Really create? (y/N) y
  gpg: Note that the key does not use the suggested creation date

  pub  3072R/8A8F1D53  created: 2012-10-06  expires: never       usage: SC
                       trust: ultimate      validity: ultimate
  sub  3072R/2F15E06B  created: 2012-11-23  expires: 2022-11-21  usage: S
  sub  3072R/EB8B4EBD  created: 2012-11-24  expires: 2022-11-22  usage: E
  sub  3072R/6BB325E9  created: 2012-11-24  expires: 2022-11-22  usage: A

  [ultimate] (1). Clint Savage <herlo1@gmail.com>
  [ultimate] (2)  Clint Savage <herlo@fedoraproject.org>
  [ultimate] (3)  Clint Savage <csavage@linuxfoundation.org>

Upon completion of the key, be sure to save the record to the card and gpg key::

  gpg> save
  $

Verify SSH key is managed via gpg-agent
---------------------------------------

Assuming everything above is configured correctly, a simple test is performed with the SmartCard inserted::

  $ ssh-add -L
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDL/XmU......BL0luE= cardno:00050000158A

Resetting the GPG SmartCard
---------------------------

In some cases, it's going to be useful to rest the SmartCard. It can be done interactively::

  $ gpg-connect-agent
  > /hex
  > scd serialno
  S SERIALNO D276000124...........00016E00000 0
  OK
  > scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
  D[0000]  69 83                                              i.
  OK
  > scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
  D[0000]  69 82                                              i.
  OK
  > scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
  D[0000]  69 83                                              i.
  OK
  > scd apdu 00 e6 00 00
  D[0000]  90 00                                              ..
  OK
  > scd apdu 00 44 00 00
  D[0000]  90 00                                              ..
  OK
  > /echo card has been reset to factory defaults
  card has been reset to factory defaults
  > /bye

**NOTE:** If desired, this file can be stored them in a file and run with "gpg-connect-agent < FILE".

FILES
-----

`The github repository <https://github.com/herlo/ssh-gpg-smartcard-config/>`_ contains all the files to make the changes above. Please feel free to read through them.

CREDITS
-------

A special thanks to the following people and/or links.

  * `How to use gpg with ssh (with smartcard section) <http://www.programmierecke.net/howto/gpg-ssh.html>`_
  * `The GnuPG Smartcard HOWTO (Advanced Features) <http://www.gnupg.org/howtos/card-howto/en/smartcard-howto-single.html#id2507402>`_
  * `Smart Cards and Secret Agents <http://blog.flameeyes.eu/2010/08/smart-cards-and-secret-agents>`_
