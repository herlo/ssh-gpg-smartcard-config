SSH authentication using a GPG smart card on Windows
===============================================================

The YubiKey 4 and YubiKey NEO support the OpenPGP interface for smart
cards which can be used with GPG4Win for encryption and signing, as well
as for SSH authentication. These in turn can be used by several other
useful tools, like Git, pass, etc. This guide will help you set up the
required software for getting things to work.

GPG4Win
-------

First things first. The core of everything is GPG4Win. Install the
latest version. You will also need to autostart gpg-connect-agent.exe
(which comes with GPG4Win) when your computer starts. You can do this by
creating a shortcut to 

`"C:\Program Files (x86)\GNU\GnuPG\gpg-connect-agent.exe" /bye`

and placing it in your Startup program group in your Start menu.
Changing the Run: setting from Normal window to Minimized makes it
slightly less obtrusive at login.

If you haven't already, you will need to setup a PGP key on your NEO.

GPG4Win's smart card support is not rock solid; occasionally you might
get error messages when trying to access the YubiKey. It might happen
after removing and re-inserting the YubiKey, or after your computer has
been in sleep mode, etc. This can be resolved by restarting gpg-agent
using the following commands:

```
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```

You might want to put these commands in a BAT-file for quick access.

Enable SSH authentication
-------------------------

GPG4Win has support for SSH authentication built-in, which is compatible
with the Pageant protocol used by PuTTY. By enabling this support
GPG4Win can act as a drop-in replacement for Pageant. Enabling this is
done by creating (or editing) the gpg-agent.conf file and adding the
following line to it:

`enable-putty-support`

The file is found in the gnupg directory: %APPDATA%\gnupg (at least on
Windows 10). The gpg-agent will need to be restarted (as described in
the previous section) for this change to take effect. Once enabled, any
application which supports SSH authentication using Pageant should
"just work".

PuTTY
-----

If you've installed GPG4Win and enabled PuTTY support, then PuTTY should
work out of the box. You can download and install PuTTY [here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).
