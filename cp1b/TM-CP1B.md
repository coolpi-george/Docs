# TM-CP1B Quick Start Guide
<div align=center>  <img src=".\image\image.png" width=50%></div>

## Login steps
- Connect the power and plug in the network cable
    -   The power supply range is 9V-36V, with the positive terminal near the LED end. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=center>  <img src=".\image\image-1.png" width=50%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.
- Obtain the IP address of the machine<br>
    -   Use LAN IP address scanning software [Advanced_IP_Scanner](https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe) to obtain all scanned LAN IP addresses.
    -   After downloading and installing the software, open the software and you will see the following interface. Click Scan to start scanning.The IP address corresponding to the "CP1B" device is the actual IP address of the machine.


        <div align=center>  <img src=".\image\image-2.png" width=50%></div>

    -   The machine with the device name coolpi in the scanning results corresponds to the DHCP address of the machine.

- Login device<br>
    -   Enter the following link in the browser to enter the login interface:<br>
        https://your_ipaddress:9090/<br>  
        Replace "your_ipaddress" with the actual IP address of the machine.<br>  
        <div align=center>  <img src=".\image\image-5.png" width=50%></div>

    -   Enter your username and password, then click login.<br> The default username for the machine is "admin", and the password is "admin".
        <div align=center>  <img src=".\image\image-6.png" width=50%></div>

    -   Click on the terminal to enter the shell interface, where you can update various devices of the system or operating system.
        <div align=center>  <img src=".\image\image-8.png" width=50%></div>

## Interface operation
- Interface
    -   The correspondence between ttySx device nodes and interfaces.
        
        ttyS0 -- LORA

        ttyS1 -- RS485

        ttyS4 -- RS232

        ttyUSB0-ttyUSB3 -- 4G-LTE

    -   RS485&RS232

        ```
        stty -F /dev/ttyS1 raw speed 115200 //Configure RS485 baud rate to 115200
        echo "hello world" > /dev/ttyS1     //Send "hello world" to RS485 port
        ```
        You can also operate the serial port through C or Python.
    -   4G-LTE 

        After inserting the 4G module and SIM card, the machine will automatically complete the dialing operation after booting up. 
        
        After successful dialing, the system will display the following ppp0 network nodes.

        The default 4G-LET module model currently used is EC20.
        <div align=center>  <img src=".\image\image-10.png" width=50%></div>

    -   WIFI

        The default WIFI module model used by the machine is BL-R7601MU5, which uses the MT7601U chip. <br>
        The system has already integrated drivers and firmware by default, and can be used by plugging in the module.
        <div align=center>  <img src=".\image\image-11.png" width=50%></div>

    -   LORA

        The module defaults to using ttyS0 as the communication port, and the GPIO corresponding to the M0 M1 signal selected for 
        mode is shown in the following figure. M0 of the module corresponds to GPIO66, M1 corresponds to GPIO67, and AUX signal corresponds 
        to GPIO70.
        <div align=center>  <img src=".\image\lora.png" width=50%></div>

        Several working modes of LORA module.
        |  Configuration mode |  M0 M1 level |
        |:-:|:-:|
        | Configuration  |  M0=0 M1=0|
        |  Working |  M0=1 M1=0 |
        |  Low power |  M0=1 M1=1 |

        Operation steps

        1.Enter configuration mode（M0=0 M1=0）
        ```
        stty -F /dev/ttyS0 raw speed 9600       //Configure ttyS0 rate to 9600
        echo 0 > /sys/class/gpio/gpio66/value   //Configure M0 to low
        echo 0 > /sys/class/gpio/gpio67/value   //Configure M1 to low
        ```

        2.Configure group number and address

        ```
        echo -ne '\x80\x18\x01\x00' >/dev/ttyS0      //Configure Configure group number to 0x00
        echo -ne '\x80\x19\x01\x00' >/dev/ttyS0      //Configure Configure group number to 0x00

        ```
        3.Configure channels and power
        <div align=center>  <img src=".\image\lora-1.png" width=50%></div>

        For example, channel 20 [10100], power 21dBm [11], airspeed 9.6K [011]

        Sort as 1010011011, convert to hexadecimal as 0x9b

        The command is: 800601029b

        ```
        echo -ne '\x80\x06\x01\x02\x9b' >/dev/ttyS0      //Configure Configure group number to 0x01

        ```
        4.Switch to normal working mode（M0=1 M1=0）
        ```
        echo 1 > /sys/class/gpio/gpio66/value   //Configure M0 to high
        echo 0 > /sys/class/gpio/gpio67/value   //Configure M1 to low
        ```
        5.Transparent transmission of data

        Note that the receiving module needs to maintain the same address and channel as the sending module.
        ```
        echo -e 'hello coolpi' >/dev/ttyS0
        ```
        <div align=center>  <img src=".\image\lora-2.png" width=50%></div>       
## Update the firmware
- Download firmware and upgrade tools from [Google Drive](https://drive.google.com/drive/folders/1rpwDABPB5bxYspOhQ6YbhDFaWXRB4QgH?usp=sharing)or[Baidu Cloud](https://pan.baidu.com/s/1hJfx2A-HToroDK6UYPIOIQ?pwd=eut4) .
<div align=center>  <img src=".\image\google.png" width=50%></div>

- Connect the USB port of CP1b to the computer.
- Install USB driver using the DriveAssitant-v5.12 tool.
<div align=center>  <img src=".\image\0001.png" width=50%></div>

- Press and hold the REC button on the machine, then turn on the power and the machine will enter MASKROM mode.
<div align=center>  <img src=".\image\0002.png" width=50%></div>

- Open SocToolKit tool, load firmware and upgrade.
<div align=center>  <img src=".\image\0003.png" width=50%></div>

## Compile and update the kernel
  - Synchronize kernel code and compile
    ```
    git clone https://github.com/coolpi-george/coolpi-kernel.git
    git checkout linux-5.10-gen-rkr8
    ./build-kernel.sh
    sudo ./build-fatboot.sh
    ``` 
  - update kernel
  
    After compilation,the kernel root directory will generate coolpi-boot.img. 

    Press and hold the REC button to power on, and the machine enters maskrom mode.

    

    As shown in the following figure, load the kernel file and burn it. 
    <div align=center>  <img src=".\image\0004.png" width=50%></div>    

    If the kernel updates the. ko file, use the following command to synchronize after entering the system
    ```
    sudo rm /lib/modules/5.10.209/ -R
    sudo tar -zxvf /boot/firmware/modules.tar.gz -C /lib
    sync
    ```     

## Common problems and solutions

  -  How to change default password？
        ```
        sudo passwd admin
        ```
  -  How to add a new user?
        As shown in the following figure, new users can be added and permissions can be configured through the backend management software.
        <div align=center>  <img src=".\image\image-9.png" width=50%></div>
  -  How to connect to WiFi network？
        ```
        /*Find available WiFi networks*/
        nmcli dev wifi list
        /*To connect to a WiFi network, you need to replace<SSID>with the network name you want to connect to, and<password>with the password for that network:*/
        nmcli --ask dev wifi connect <SSID> password <password> 
        ```
  -  Unable to register for 4G network?
        
        Pay attention to the insertion direction of the SIM card as shown in the figure below, with the notch facing outward.
        <div align=center>  <img src=".\image\sim.png" width=50%></div>

  -  How to Backup File System?  
    In the process of user development, after building their own application, it is usually necessary to back up the file system and then copy it to other machines. The following provides [backup scripts](https://forum.cool-pi.com/assets/uploads/files/1761125092204-backup-cp1b.sh) and operation methods:  

       -  It is best to use a file system with a capacity greater than twice that of a USB flash drive, for example, if the file system is 4GB, choose an 8GB capacity USB flash drive and format it in NTFS format.  
       -  Copy the script file to a USB drive.  
       -  Insert the USB drive into the USB port of the CP1B machine and turn it on.  
       -  Use the following command to mount a USB drive to the/mnt directory.  
        ``` sudo mount /dev/sda1 /mnt```  
       -  Enter the/mnt directory and execute the script.    
            ``` 
            cd /mnt  
            sudo ./backup-cp1b.sh
            ```
       - After the script is executed, the root directory of the USB drive will generate a * * *. img file, which can be used to replace the rootfs. img file in the compressed image file.
        <div align=center>  <img src=".\image\replace.png" width=50%></div>
  - How to make mass production firmware?  
    The mass production process can be completed using production tools, which require loading production firmware and cannot use development firmware. The following steps for generating production firmware are introduced:  
       - Open the SocToolKit software and select the chip model and storage type as shown in the following figure.    
    <div align=center>  <img src=".\image\update-1.png" width=50%></div>
       - Right click on the watch to add files.
    <div align=center>  <img src=".\image\update-2.png" width=50%></div>
       - Select 6 files and click Create, wait for the creation to complete.
    <div align=center>  <img src=".\image\update-3.png" width=50%></div>



  































    












































