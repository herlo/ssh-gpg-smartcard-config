ssh-gpg-smartcard-config
========================

This document covers the procedure for configurating a system to use gpg smartcards for ssh authentication. The benefit is a good model for `two-factor authentication <http://en.wikipedia.org/wiki/Two-factor_authentication>`_, something you have and something you know. In this example, there is a token and a passphrase. 

The `Gemalto USB Shell Token V2 <http://shop.kernelconcepts.de/product_info.php?cPath=1_26&products_id=119>`_ and the `OpenPGP SmartCard V2 <http://shop.kernelconcepts.de/product_info.php?products_id=42&osCsid=101f6f90ee89ad616d2eca1b31dff757>`_ are used here, though there are many combinations that will work.

Examples below are using a Fedora 17 x86_64 fresh install, there are other tutorials for other operating systems available online. See the CREDITS section below for alternate tutorials, examples, etc.

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
  sub  3072R/4E2D6F5A  created: 2012-10-06  expires: 2022-12-30  usage: E   
  sub  3072R/2F15E06B  created: 2012-11-23  expires: 2022-11-21  usage: S   
  sub  3072R/EB8B4EBD  created: 2012-11-24  expires: 2022-11-22  usage: E   
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

Configuring Authentication with GNOME-Shell
-------------------------------------------
To configure authentication using the previously generated GnuPG key, the GNOME-Shell needs some adjustements. With help from several resources, configure the system to allow ``gpg-agent`` to take over ssh authentication.

Certain software must be installed, including ``gnupg2`` (which is probably already installed), ``gnupg2-smime`` and ``pcsc-lite``::

  # yum install gnupg2-smime pcsc-lite
  .. snip ..
  Complete!



