# QEMU Scripts

## Purpose
This repository provides scripts for using QEMU for virtual machines 
WITHOUT having to consciously remember all the details of the
commands to enter in the command line terminal.

## Limitations
* These scripts are built for Linux host systems.  I do not have a 
newer Apple computer with an Apple silicon processor, and I do not 
have a copy of Windows.
* These scripts are built for my computers.  Your needs may be 
different.
* I wrote these scripts to use QEMU to perform the same tasks that I 
used as a VirtualBox user.  QEMU has numerous functions and 
capabilities not covered here.
* I encourage you to borrow ideas from this repository to start your 
own repository and make your best use of QEMU.

## Getting Started
* Use the "git clone" command to download this repository to your 
Linux computer.
* Set up the working directory for your virtual machine.
    * From this repository's root directory, enter the command 
`bash setup.sh`.  When prompted, provide the nickname you wish to use
for your virtual machine.
    * Other scripts are also available that perform the same function as 
the setup.sh script but with the nickname of the virtual machine 
filled in.
* Go to the working directory for the virtual machine you wish to 
create.  Enter the command `bash start.sh` to begin the process of
building and booting up your virtual machine.
* After you shut down your virtual machine, you can boot it up again 
with the start.sh script.
* If you wish to reset your virtual machine, use the reset.sh script to
start over with the ISO file and rebuild your virtual machine with the
same parameters as before.
* If you wish to rebuild your virtual machine with new specs, use the 
rebuild.sh to start over with the ISO file, enter new specs, and 
rebuild your virtual machine with different parameters.
* If you wish to start over with a brand new ISO file, use the nuke.sh 
script to delete the old ISO file, download a new ISO file, and 
rebuild your virtual machine with different parameters.

## Why have you stopped using VirtualBox?
VirtualBox is not as easy and seamless as it used to be.  I've been 
finding that it eats up computing resources, and things don't always 
work as well as they used to.

## Why is QEMU better?
* QEMU is free and open source.
* QEMU is more efficient than VirtualBox.
* If you know what you're doing, QEMU is more stable and reliable.
* QEMU supports Linux, MacOS, and Windows hosts.  VirtualBox no longer 
supports MacOS, presumably because of the change from Intel processors 
to Apple silicon processors.

## Why aren't you using one of the QEMU front-ends, such as GNOME Boxes or Virt Manager?
I encountered pesky problems with all of them, such as weird error 
messages, freeze-ups, and crashes.  
