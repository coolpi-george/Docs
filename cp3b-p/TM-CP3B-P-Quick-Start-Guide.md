# TM-CP3B-P Quick Start Guide
<div align=center>  <img src=".\image\正面.jpg" width=50%></div>

## Login steps
- Connect the power and plug in the network cable
    -   The power supply range is 9V-36V, with the positive terminal near the USB end. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=center>  <img src=".\image\power.png" width=40%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.
- Obtain the IP address of the machine<br>
    -   Use LAN IP address scanning software [Advanced_IP_Scanner](https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe) to obtain all scanned LAN IP addresses.
    -   After downloading and installing the software, open the software and you will see the following interface. Click Scan to start scanning.The IP address corresponding to the "CP3B" device is the actual IP address of the machine.


        <div align=center>  <img src=".\image\image-2.png" width=50%></div>

    -   The machine with the device name CP3B in the scanning results corresponds to the DHCP address of the machine.

- Login device<br>
    -   Enter the following link in the browser to enter the login interface:<br>
        https://your_ipaddress:9090/<br>  
    -   Replace "your_ipaddress" with the actual IP address of the machine. such as "https://172.16.19.111:9090".<br>  
        <div align=center>  <img src=".\image\image-5.png" width=50%></div>

    -   Enter your username and password, then click login.<br> The default username for the machine is "admin", and the password is "admin".
        <div align=center>  <img src=".\image\image-6.png" width=50%></div>

    -   Click on the terminal to enter the shell interface, where you can update various devices of the system or operating system.
        <div align=center>  <img src=".\image\image-8.png" width=50%></div>

    -   You can also log in using the console interface
        <div align=center>  <img src=".\image\console.png" width=50%></div>   

    -   The console is a USB to serial chip CH340, and the driver needs to be [Download](https://www.wch.cn/download/file?id=65) and installed before use.
  
    -   The default baud rate for console serial port is 115200.
## Interface operation
- Interface
   <div align=center>  <img src=".\image\port.png" width=50%></div>

    -   The correspondence between ttySx device nodes and interfaces.
        
        spidev0.0 -- TBUS //Extended I/O Module Communication Interface

        ttyS1 -- RS485-1 (A1 B1)

        ttyS7 -- RS485-2 (A2 B2)

        ttyS9 -- RS485-3 (A3 B3)

        ttyS5 -- RS232   (T1 R1)

        ttyS3 -- UART-TTL(5V) (IO0 IO1) //These two pins can be configured for UART(default) 、GPIO and I2C functions.

        ttyUSB0-ttyUSB3 -- 4G-LTE

    -   RS485&RS232

        ```
        stty -F /dev/ttyS1 raw speed 115200 //Configure RS485 baud rate to 115200
        echo "hello world" > /dev/ttyS1     //Send "hello world" to RS485 port
        ```
        - You can also operate the serial port through C or Python.
    -   4G-LTE 

        - The dialing script is located in the following directory:
            ```
            /etc/ppp/quectel-pppd.sh
            ```
        - Operators in different regions need to configure APN, username, and password, which can be directly modified in the following location in the dialing script:
        <div align=center>  <img src=".\image\ppp.png" width=50%></div>

        - You can obtain APN ，username and password from different operators through the following connections. 

            [https://bigfun.tripod.co.uk/](https://bigfun.tripod.co.uk/)


        - Inserting the 4G module and SIM card,Correctly configure APN username and password, the machine will automatically complete the dialing operation after booting up. 
        
        - After successful dialing, the system will display the following ppp0 network nodes.

        - The default 4G-LET module model currently used is EC20.
        <div align=center>  <img src=".\image\image-10.png" width=50%></div>

    -   WIFI/BT
        - The default WIFI module model used by the machine is BL-M8800DU6-D80, which uses the AIC8800D80 chip. Support wifi 802.11a/b/g/n/ac/ax and bt5.4.<br>
        - The system has already integrated drivers and firmware by default, and can be used by plugging in the module.  

        <div align=center>  <img src=".\image\WIFI.png" width=50%></div>

    -   CAN
         - Implements CAN V2.0B at 1Mb/s.
         - Two receive buffers with prioritized message storage.
         - Three Transmit Buffers with Prioritization and Abort Features.
         - How to operate?
            ```
            ifconfig -a   //Query current network devices

            ip link set can0 down  //Close CAN0

            ip link set can0 type can bitrate 500000  //Set bit rate to 500KHz

            ip -details -statistics link show can0   //Print can0 information

            ip link set can0 up  //Activate CAN0

            cansend can0 123#DEADBEEF  //Send (standard frame, data frame, ID: 123, data: DEADBEEF)

            cansend can0 123#R  //Send (standard frame, remote frame, ID: 123)

            cansend can0 00000123#12345678  //Send (Extended frame, Data frame, ID: 00000 123, data: 12345678):

            cansend can0 00000123#R //Send (Extended Frame, Remote Frame, ID: 00000 123)

            candump can0 //Enable printing and wait for reception
            ```
    -   Extended I/O
        -   Data Format
            | CMD | ADDRESS | DATA0 | DATA1 |
            |----|----|----|----|  
        -   Communication Process
            - Configure io module address,the default address for the IO module is 0xaa.
            - Send Command  
            - If it is a read command, obtain the return value
        -   Command Word
            | CMD | Instructions |
            |----|----|
            |0x99|write address command|
            |0x4b|write io command|
            |0x4c|write io bit command|
            |0x3a|read io command|
        -   Example  
            ```
            https://github.com/coolpi-george/spi-test.git  //Download test script
            sudo apt install python3-pip                   
            pip install spidev --break-system-packages     //Install spidev library
            cd spi-test                                    //Enter the script directory     
            python3 spidev_test.py                         //Execute script 
            Please enter multiple hexadecimal numbers separated by spaces, or 'exit' to quit:   //Enter the command
            ```
            - Write address  
              ``99 aa 01 00                                //Configure module address as 0x01,0xaa is default address  ``
            - Write io  
              ``4b 01 ff 00                                //All 8 IO channels are turned on  ``  
              ``4b 01 00 00                                //All 8 IO channels are turned off  ``
            - Write io bit  
              ``4c 01 01 01                                //Turn on the first bit of io, keep the other bits unchanged  ``  
              ``4c 01 02 01                                //Turn on the second bit of io, keep the other bits unchanged  ``  
              ``4c 01 02 00                                //Turn off the second bit of io, keep the other bits unchanged  ``  
            - Read io  
              ``3a 01 01 00                                //Read 8 IO channels command  ``  
              ``ff                                         //Get return value  ``
    -   Extended ADC

            
    
## Update the firmware
- Download firmware and upgrade tools from [Google Drive](https://drive.google.com/drive/folders/1rpwDABPB5bxYspOhQ6YbhDFaWXRB4QgH?usp=sharing)or[Baidu Cloud](https://pan.baidu.com/s/1hJfx2A-HToroDK6UYPIOIQ?pwd=eut4) .
<div align=center>  <img src=".\image\download.png" width=50%></div>

- Connect the USB port of CP3B to the computer.
  
<div align=center>  <img src=".\image\USB.png" width=50%></div>
  
- Install USB driver using the DriveAssitant-v5.12 tool.

<div align=center>  <img src=".\image\0001.png" width=50%></div>

- Press and hold the REC button on the machine, then turn on the power and the machine will enter Loader mode.
<div align=center>  <img src=".\image\rec.png" width=50%></div>

- Open RKDevTool tool, Switch from loader mode to maskrom mode as shown in the following figure.
    - Open the tool and discover the loader device.
  
    <div align=center>  <img src=".\image\loader.png" width=50%></div>

    - Switch to Maskrom mode according to the following diagram.
  
    <div align=center>  <img src=".\image\maskrom.png" width=50%></div>

    - Check the option to force writing by address, click run, and wait for the burning to complete.
    <div align=center>  <img src=".\image\download1.png" width=50%></div>

## Compile and update the kernel
  - Synchronize kernel code and compile
    ```
    git clone https://github.com/coolpi-george/coolpi-kernel.git
    git checkout linux-6.1-stan-rkr3.1
    ./build-kernel.sh arm64
    ``` 
  - update kernel
  
    After compilation, the following deb file will be generated and copied to the machine for installation using the "dpkg -i linux-image-6.1.75_6.1.75-23_arm64.deb" command. 

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
  -  How to modify the startup image?
        - Modify the content of the attached image and copy it to the /boot/firmware directory of the machine.
        - Be sure not to change the file name and format (BMP).
        <div align=center>  <img src=".\image\logo.bmp" width=50%></div>
        <div align=center>  <img src=".\image\logo_kernel.bmp" width=50%></div>
  -  How to backup an image?
        - Copy the script shown in the figure to a USB drive, insert the USB drive into the machine, and then execute the script with administrator privileges in the background, waiting for the backup to complete.
        - Note that the space on the USB flash drive must be greater than twice the size of the machine's root partition.
        - Replace the Ubuntu * * *. img file in the Image directory of the burning tool with the generated image, and burn it for testing on a new machine.
  
            [Dump-emmc](https://forum.cool-pi.com/assets/uploads/files/1751280412284-dump-emmc.sh)
  -  How to install Docker?
        Refer to the following document to install Docker.  

        https://forum.cool-pi.com/topic/1276/install-docker-engine-on-ubuntu

  































    












































