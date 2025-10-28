# TM-CP2B Quick Start Guide
<div align=center>  <img src=".\image\侧视.jpg" width=50%></div>

## Login steps
- Connect the power and plug in the network cable
    -   The power supply range is 9V-36V, with the negative terminal near the LED end. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=center>  <img src=".\image\极性.jpg" width=30%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.
- Obtain the IP address of the machine<br>
    -   Use LAN IP address scanning software [Advanced_IP_Scanner](https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe) to obtain all scanned LAN IP addresses.
    -   After downloading and installing the software, open the software and you will see the following interface. Click Scan to start scanning.The IP address corresponding to the "CP2B" device is the actual IP address of the machine.


        <div align=center>  <img src=".\image\IP.jpg" width=50%></div>

    -   The machine with the device name cp2b in the scanning results corresponds to the DHCP address of the machine.

- Login device<br>
    -   Enter the following link in the browser to enter the login interface:<br>
        https://your_ipaddress:9090/<br>  
        Replace "your_ipaddress" with the actual IP address of the machine.<br>  
        <div align=center>  <img src=".\image\logic.jpg" width=50%></div>

    -   Enter your username and password, then click login.<br> The default username for the machine is "admin", and the password is "admin".
        <div align=center>  <img src=".\image\logic1.jpg" width=50%></div>

    -   Click on the terminal to enter the shell interface, where you can update various devices of the system or operating system.
        <div align=center>  <img src=".\image\shell.jpg" width=50%></div>
    -   You can also log in to the machine using SSH or console interface. The machine does not have SSH service installed by default. Please refer to the following command for installation:
        ```
        sudo apt install ssh
        ```
        The machine integrates a USB to UART circuit internally, and uses a Type-C cable to connect the console interface to the computer. The computer will detect a serial device, and if it is used for the first time, a [USB driver](https://www.wch.cn/download/file?id=65) is required.

## Interface operation
- Interface
    -   The correspondence between ttySx device nodes and interfaces.
        
        ttyS1 -- RS485-2(A2 B2)

        ttyS2 -- RS485-1(A1 B1)

        ttyS3 -- TTL(TX RX)

        ttyS4 -- LORA

        spidev0.0 -- LORA-WAN

        ttyUSB0-ttyUSB3 -- 4G-LTE

    -   RS485&TTL

        ```
        stty -F /dev/ttyS1 raw speed 115200 //Configure RS485 baud rate to 115200
        echo "hello world" > /dev/ttyS1     //Send "hello world" to RS485 port
        ```
        You can also operate the serial port through C or Python.
    -   4G-LTE 

        After inserting the 4G module and SIM card, the machine will automatically complete the dialing operation after booting up. 
        
        After successful dialing, the system will display the following ppp0 network nodes.

        The default 4G-LET module model currently used is EC20.
        <div align=center>  <img src=".\image\4G.png" width=50%></div>

    -   WIFI&BT

        The default WIFI module model used by the machine is BL-M8800DU6-D80, which uses the AIC8800D80 chip. Support wifi 802.11a/b/g/n/ac/ax and bt5.4.<br>
        The system has already integrated drivers and firmware by default, and can be used by plugging in the module.
        <div align=center>  <img src=".\image\WIFI.png" width=50%></div>

    -   LORA-WAN

        - CP2B supports LORA WAN modules with SPI interfaces, such as the EBYTE E106 series, as shown in the following figure, which defaults to using the MINI-PCIE interface.
        <div align=center>  <img src=".\image\E106.png" width=50%></div>

        - Test according to the following steps.
        
            ```
                git clone https://github.com/coolpi-george/sx1302.git /*Clone code to any path on the CP3B*/
                cd sx1302
                git checkout cp2b
                make clean all
                make -j8
                cp tools/reset_lgw.sh util_chip_id/
                cp tools/reset_lgw.sh packet_forwarder/
                cp tools/reset_lgw.sh libloragw/
                cd util_chip_id/
                sudo ./chip_id                                       /*Obtain module EUI*/
                [sudo] password for admin:  
                CoreCell reset through GPIO55...
                Opening SPI communication interface
                Note: chip version is 0x10 (v1.0)
                INFO: using legacy timestamp
                ARB: dual demodulation disabled for all SF
        
                INFO: concentrator EUI: 0x0016c001f11a1f85
        
                Closing SPI communication interface
                CoreCell reset through GPIO55...
                cd libloragw/
                sudo ./test_loragw_reg                             /*Traverse the registers of the module*/
                CoreCell reset through GPIO55...
                Opening SPI communication interface
                Note: chip version is 0x10 (v1.0)
                ## TEST#1: read all registers and check default value for non-read-only registers
                ------------------
                 TEST#1 PASSED
                ------------------
        
                ## TEST#2: read/write test on all non-read-only, non-pulse, non-w0clr, non-w1clr registers
                ------------------
                 TEST#2 PASSED                                    /*The successful identification module is running normally*/
                ------------------
        
                Closing SPI communication interface
                CoreCell reset through GPIO55...
                ```
                - Configure as gateway and connect to TNN server according to [Official Documents](https://semtech.my.salesforce.com/sfc/p/ #E0000000JelG/a/RQ0000043BUT/kDK2Unqnoazf9_UbC7um6mY7NnVzIWECoCudd3xuUnU).
            ```
## Update the firmware
- Download firmware and upgrade tools from [Google Drive](https://drive.google.com/drive/folders/1rpwDABPB5bxYspOhQ6YbhDFaWXRB4QgH?usp=sharing)or[Baidu Cloud](https://pan.baidu.com/s/1hJfx2A-HToroDK6UYPIOIQ?pwd=eut4) .
<div align=center>  <img src=".\image\google.jpg" width=50%></div>

- Connect the USB port of CP2b to the computer.
<div align=center>  <img src=".\image\USB.jpg" width=50%></div>

- Install USB driver using the DriveAssitant-v5.12 tool.
<div align=center>  <img src=".\image\0001.png" width=50%></div>

- Press and hold the REC button on the machine, then turn on the power and the machine will enter MASKROM mode.
<div align=center>  <img src=".\image\key.JPG" width=50%></div>

- Open RKdevtool, by default, the firmware path has already been selected. Click on 'Run' directly.
<div align=center>  <img src=".\image\download.jpg" width=50%></div>

## Compile and update the kernel
  - Synchronize kernel code and compile
    ```
    git clone https://github.com/coolpi-george/coolpi-kernel.git
    git checkout linux-6.1-stan-rkr5.1
    ./build-kernel.sh arm
    ``` 
  - update kernel
  
    After compilation, the following deb file will be generated and copied to the machine for installation using the "dpkg -i linux-image-6.1.115_6.1.115-21_armhf.deb" command. 
    <div align=center>  <img src=".\image\DEB.jpg" width=50%></div>     

## Common problems and solutions

  -  How to change default password？
        ```
        sudo passwd admin
        ```
  -  How to add a new user?
        As shown in the following figure, new users can be added and permissions can be configured through the backend management software.
        <div align=center>  <img src=".\image\user.jpg" width=50%></div>
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
    In the process of user development, after building their own application, it is usually necessary to back up the file system and then copy it to other machines. The following provides [backup scripts](https://github.com/coolpi-george/backup/blob/main/backup-cp2b.sh) and operation methods:  

       -  It is best to use a file system with a capacity greater than twice that of a USB flash drive, for example, if the file system is 4GB, choose an 8GB capacity USB flash drive and format it in NTFS format.  
       -  Copy the script file to a USB drive.  
       -  Insert the USB drive into the USB port of the CP1B machine and turn it on.  
       -  Use the following command to mount a USB drive to the/mnt directory.  
        ``` sudo mount /dev/sda1 /mnt```  
       -  Enter the/mnt directory and execute the script.    
            ``` 
            cd /mnt  
            sudo ./backup-cp2b.sh
            ```
       - After the script is executed, the root directory of the USB drive will generate a * * *. img file, which can be used to replace the rootfs. img file in the compressed image file.
        <div align=center>  <img src=".\image\rootfs.jpg" width=50%></div>
  - How to make mass production firmware?  
    The mass production process can be completed using production tools, which require loading production firmware and cannot use development firmware. The following steps for generating production firmware are introduced:  
       - Open the folder shown in the following figure, double-click to execute mkupdate.bat, and the script will generate update.img after running    
    <div align=center>  <img src=".\image\update.jpg" width=50%></div>
    <div align=center>  <img src=".\image\123.jpg" width=50%></div>

       - Open the factory tool, load update.img, run, and the machine will automatically execute the burning process when it enters maskrom mode. It is recommended not to burn more than 16 machines simultaneously.
    <div align=center>  <img src=".\image\factory.jpg" width=50%></div>



  































    












































