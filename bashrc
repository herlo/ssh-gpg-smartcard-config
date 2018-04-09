# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# Start gpg-agent if it's not running
if ! pidof gpg-agent > /dev/null; then
    gpg-agent --homedir $HOME/.gnupg --daemon --sh --enable-ssh-support > $HOME/.gnupg/env
fi
if [ -f "$HOME/.gnupg/env" ]; then
    source $HOME/.gnupg/env
fi
gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1

