Initial draft of Windows instructions

Follow the instructions at https://developers.yubico.com/PGP/SSH_authentication/Windows.html

The final setp is to get gpg-agent to start when you login.  You can do this by creating a shortcut to 
"C:\Program Files (x86)\GNU\GnuPG\gpg-connect-agent.exe" /bye
and placing it in your Startup program group.  You might wnat to change the Run: setting from "Normal window" to "Minimized" to make it not show up when you login.

