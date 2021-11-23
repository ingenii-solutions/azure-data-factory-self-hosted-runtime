=========================================================
README for Installing the IBM Data Server Driver Package
=========================================================

1. Linux or Unix
2. Windows
3. Mac

1. Linux or Unix
================

    1. Copy the IBM Data Server Driver Package software vxxx_xxx_dsdriver.tar.gz archive onto the target machine.

    2. Extract the IBM Data Server Driver Package archive.

          gunzip vxxx_xxx_dsdriver.tar.gz
          tar -xvf vxxx_xxx_dsdriver.tar

          A dsdriver subdirectory is created in the directory where you ran the extract commands.

    3. To extract the Java and ODBC/CLI drivers, go to the dsdriver directory and run this command: ./installDSDriver

          The installDSDriver script creates the db2profile and db2cshrc script files.

    4. Run one of the following script files based on your shell to setup your environment

          64-Bit Bash or Korn shell:  . ./db2profile (Between the 2 dots there is a space)
          64-Bit C shell: source db2cshrc

         32-Bit Bash or Korn shell:  . ./db2profile32 (Between the 2 dots there is a space)
          32-Bit C shell: source db2cshrc32

2. Windows
==========

    1. Run the setup.exe from an user account that is part of the Administrators group

    2. The default installation path is Program Files\IBM\IBM DATA SERVER DRIVER

    3. The default common application data path will be under ProgramData\IBM\DB2\driver_copy_name\

3.Mac
=====

    1. Double-click the vxx_xxx_macos_dsdriver.dmg file to mount the disk image. A new Finder window opens with the contents of the disk image.

          If the Finder window does not open, double-click the dsdriver icon on your desktop.

    2. In the Finder window, double-click the installDSDriver icon to install the driver package to the default location /Applications/dsdriver

          The installDSDriver script creates the db2profile and db2cshrc script files.

    3. Run one of the following script files based on your shell to setup your environment:

          Bash or Korn shell:  . ./db2profile (Between the 2 dots there is a space)
          C shell: source db2cshrc

=============================================================
Configuring and validating the IBM Data Server Driver Package
=============================================================

Testing connectivity to the database
https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.swg.im.dbclient.install.doc/doc/t0070358.html

============
Useful Links
============

Supported database application programming interfaces
https://www.ibm.com/support/knowledgecenter/SSEPGG_11.1.0/com.ibm.db2.luw.apdv.gs.doc/doc/c0007011.html

IBM data server driver configuration file
https://www.ibm.com/support/knowledgecenter/SSEPGG_11.1.0/com.ibm.swg.im.dbclient.config.doc/doc/c0054555.html

