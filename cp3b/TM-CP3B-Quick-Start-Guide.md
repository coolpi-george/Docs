# TM-CP3B Quick Start Guide
<div align=center>  <img src=".\image\9.png" width=50%></div>

## Login steps
- Connect the power and plug in the network cable
    -   The power supply range is 9V-36V, with the positive terminal near the HDMI end. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=center>  <img src=".\image\power.png" width=40%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.
- Obtain the IP address of the machine<br>
    -   Use LAN IP address scanning software [Advanced_IP_Scanner](https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe) to obtain all scanned LAN IP addresses.
    -   After downloading and installing the software, open the software and you will see the following interface. Click Scan to start scanning.The IP address corresponding to the "CP1B" device is the actual IP address of the machine.


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

## Interface operation
- Interface
   <div align=center>  <img src=".\image\port.png" width=50%></div>

    -   The correspondence between ttySx device nodes and interfaces.
        
        spi1  -- LORA WAN

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

    -   WIFI
        - The default WIFI module model used by the machine is RTL8852BE, Supports WIFI6 and BT5.2 protocols. <br>
        - The system has already integrated drivers and firmware by default, and can be used by plugging in the module.<br>
        - Users can replace different WIFI modules according to their actual product needs, with M.2 (PCIe+USB) interface.
        <div align=center>  <img src=".\image\wifi.png" width=50%></div>

    -   LORA WAN
  
        - CP3B supports LORA WAN modules with SPI interfaces, such as the EBYTE E106 series, as shown in the following figure, which defaults to using the MINI-PCIE interface.
        <div align=center>  <img src=".\image\e106.png" width=50%></div>

        - Test according to the following steps.

        ```
        git clone https://github.com/coolpi-george/sx1302.git /*Clone code to any path on the CP3B*/
        cd sx1302
        make clean all
        make -j8
        cp tools/reset_lgw.sh util_chip_id/
        cp tools/reset_lgw.sh packet_forwarder/
        cp tools/reset_lgw.sh libloragw/
        cd util_chip_id/
        sudo ./chip_id                                       /*Obtain module EUI*/
        [sudo] password for admin:  
        CoreCell reset through GPIO36...
        Opening SPI communication interface
        Note: chip version is 0x10 (v1.0)
        INFO: using legacy timestamp
        ARB: dual demodulation disabled for all SF

        INFO: concentrator EUI: 0x0016c001f11a1f85

        Closing SPI communication interface
        CoreCell reset through GPIO36...
        cd libloragw/
        sudo ./test_loragw_reg                             /*Traverse the registers of the module*/
        CoreCell reset through GPIO36...
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
        CoreCell reset through GPIO36...
        ```
        - Configure as gateway and connect to TNN server according to [Official Documents](https://semtech.my.salesforce.com/sfc/p/#E0000000JelG/a/RQ0000043BUT/kDK2Unqnoazf9_UbC7um6mY7NnVzIWECoCudd3xuUnU).
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
            
    
## Update the firmware
- Download firmware and upgrade tools from [Baidu Cloud](https://pan.baidu.com/s/1hJfx2A-HToroDK6UYPIOIQ?pwd=eut4) or [OneDrive](https://coolpi-my.sharepoint.com/:f:/g/personal/coolpi_coolpi_onmicrosoft_com/ErrRcBe6gjJGhPSiLJ2sSWwBORMfKRcSEUMdfd5yX6Z2Ow).
<div align=center>  <img src=".\image\onedrive.png" width=50%></div>

- Connect the USB port of CP3B to the computer.
  
<div align=center>  <img src=".\image\otg.png" width=50%></div>
  
- Install USB driver using the DriveAssitant-v5.12 tool.

<div align=center>  <img src=".\image\0001.png" width=50%></div>

- Press and hold the REC button on the machine, then turn on the power and the machine will enter Loader mode.
<div align=center>  <img src=".\image\REC.png" width=50%></div>

- Open RKDevTool tool, Switch from loader mode to maskrom mode as shown in the following figure.
    - Open the tool and discover the loader device.
  
    <div align=center>  <img src=".\image\loader.png" width=50%></div>

    - Switch to Maskrom mode according to the following diagram.
  
    <div align=center>  <img src=".\image\maskrom.png" width=50%></div>

    - Check the option to force writing by address, click run, and wait for the burning to complete.
    <div align=center>  <img src=".\image\download.png" width=50%></div>

## Compile and update the kernel
  - Synchronize kernel code and compile
    ```
    git clone https://github.com/coolpi-george/coolpi-kernel.git
    git checkout linux-6.1-stan-rkr3.1
    ./build-kernel.sh
    ``` 
  - update kernel
  
    After compilation,the kernel root directory will generate out folder. Copy all the contents of the out folder to the/boot/firmware directory of the machine.
    ```
    sudo cp -rfp out/* /boot/firmware/
    sudo tar -zxvf out/modules.tar.gz -C /lib
    sudo tar -zxvf out/headers.tar.gz -C /usr
    sync & reboot
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

  































    












































