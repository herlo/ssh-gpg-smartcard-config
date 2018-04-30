=========================
Setup GPG Agent for macOS
=========================

This document doesn't go into setting up a GPG smartcard with keys, only how to setup the GPG smartcard agent.
These instructions should work for Bash, ZSH, and any other POSIX compliant shell.

Homebrew
--------

These instructions use `Homebrew <https://brew.sh/>`_ to install a few needed packages. Please reference their
website to install it.

Install packages
----------------

::

    $ brew install gpg2 pidof pinentry-mac

Homebrew's version of gpg2 will be located at ``/usr/local/bin/gpg2``.

``pidof`` is used a script below to check if gpg-agent is running. You can use other methods to determine this
but using ``pidof`` was the simplest.

Create gpg.conf
---------------

Edit the file ``$HOME/.gnupg/gpg.conf`` and copy paste the following into it::

    ask-cert-level
    use-agent
    keyserver keys.fedoraproject.org

You can change keyserver to be any keyserver. The Fedora Project URL is used as an example.

Create gpg-agent.conf
---------------------

Edit the file ``$HOME/.gnupg/gpg-agent.conf`` and copy paste the following into it::

    pinentry-program /usr/local/bin/pinentry-mac
    enable-ssh-support
    default-cache-ttl 600
    max-cache-ttl 7200
    debug-level basic
    log-file $HOME/.gnupg/gpg-agent.log

Directory Permissions
---------------------

Make sure the .gnupg directory has the correct permissions::

    $ chmod -R og-rwx $HOME/.gnupg

Setup Shell rc File
-------------------

The following will work in both Bash and ZSH.

Edit your ``$HOME/.bashrc`` or ``$HOME/.zshrc`` file and add the following at the bottom::

    # Start gpg-agent if it's not running
    if [ -z "$(pidof gpg-agent 2> /dev/null)" ]; then
        gpg-agent --homedir $HOME/.gnupg --daemon --sh --enable-ssh-support > $HOME/.gnupg/env
    fi

    # Import various environment variables from the agent.
    if [ -f "$HOME/.gnupg/env" ]; then
        source $HOME/.gnupg/env
    fi

You can also put the above script in a separate file and source it into your rc file. Which ever
works for you.

Verify Correct Setup
--------------------

Open a new shell session or source your shell's rc file and use ``ssh-add`` to verify everything is working::

    $ ssh-add -L
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJU3H3jjShU6o04lK......0yQrd1oR2nQ8qEQQ== cardno:000604227008

Conclusion
----------

With this setup, the gpg-agent should be started on shell start if it's not already started.
The SSH_AUTH_SOCK is set to the standard socket location to be used by ssh or anything else
that wants to use GPG like git.
