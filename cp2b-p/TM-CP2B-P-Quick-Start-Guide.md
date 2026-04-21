# TM-CP2B-P Quick Start Guide
<div align=center>  <img src=".\image\001.png" width=50%></div>

## Login steps
- The console interface is connected to the computer through a USB-Typec cable, and the computer will recognize one serial device. The integrated USB to serial chip model inside the machine is CH340, and the [USB driver](https://file.wch.cn/download/file?id=5) needs to be installed before use. The default baud rate for the serial port is 115200.Username: "admin" Password: "admin".
<div align=center>  <img src=".\image\002.png" width=50%></div>

- You can also log in to the device through a browser. The machine has a built-in cockpit backend by default. Enter https://your-ip-address:9090 to enter the following login interface. Username: "admin" Password: "admin".  
<div align=center>  <img src=".\image\logic.jpg" width=50%></div>

## Interface operation
<div align=center>  <img src=".\image\003.png" width=50%></div>

- Interface
    -   The correspondence between ttySx device nodes and interfaces.
        
        ttyS1 -- RS485-2(A2 B2)

        ttyS2 -- RS485-1(A1 B1)

        ttyS3 -- ADC(AI1 AI2)

        ttyS4 -- LORA

        spidev0.0 -- LORAWAN

        ttyUSB0-ttyUSB3 -- 4G-LTE

    -   RS485

        ```
        stty -F /dev/ttyS1 raw speed 115200                                //Configure RS485 baud rate to 115200
        echo "hello world" >/dev/ttyS1                                    //Send "hello world" to RS485 port
        ```
        You can also operate the serial port through C or Python.
    -   CANFD
        ```
        sudo apt install can-utils                                         //Install the CAN test tool
        ifconfig -a                                                        //Check the device node
        ip link set can0 down                                              //Disable CAN0
        ip link set can0 type can bitrate 1000000 dbitrate 3000000 fd on   //Set the arbitration segment to 1M baud rate and the data segment to 3M baud rate
        ip -details link show can0                                         //Print CAN0 configuration information
        ip link set can0 up                                                //Start the CAN controller
        cansend can0 123##1DEADBEEF                                        //Send (standard frame, data frame, ID: 123, date: DEADBEEF)
        cansend can0 00000123##1DEADBEEF                                   //Send (Extended frame, Data frame, ID: 00000 123, date: DEADBEEF)
        candump can0 &                                                     //CAN reception, enable printing, wait for reception
        ```
    -   DI[1:4]
    <div align=center>  <img src=".\image\004.png" width=50%></div>

    Before using the DI interface, the COM pin of C2B-P must be connected to the positive or negative pole of an external power source. When the positive pole is connected, the external low-level input DI interface is at an effective level. When the COM end is connected to the negative pole, the external high-level input DI interface is at an effective level.  

    The COM pin can also be connected to the VOUT output terminal of CP2B-P, in which case the short-circuit DI and GND signals are effective levels.

    GPIO default signal is 0, valid signal is 1.

    |  NUM   | GPIO  |
    |  ----  | ----  |
    | DI1  | GPIO36 |
    | DI2  | GPIO37 |
    | DI3  | GPIO41 |
    | DI4  | GPIO57 |

    ```
    cat /sys/class/gpio/gpio36/value /*Get the status of DI1*/
    cat /sys/class/gpio/gpio37/value /*Get the status of DI2*/
    cat /sys/class/gpio/gpio41/value /*Get the status of DI3*/
    cat /sys/class/gpio/gpio57/value /*Get the status of DI4*/
    ```

    -   DO[1:4]
    <div align=center>  <img src=".\image\005.png" width=50%></div>

    The four digital output interfaces of CP2B-P are NPN type outputs, which can withstand a maximum voltage of 36V and a maximum driving current of 500mA per channel.
    |  NUM   | GPIO  |
    |  ----  | ----  |
    | DO1  | GPIO6 |
    | DO2  | GPIO7 |
    | DO3  | GPIO12 |
    | DO4  | GPIO13 |

    ```
    echo 1 >/sys/class/gpio/gpio6/value  /*DO1 channel output low*/
    echo 1 >/sys/class/gpio/gpio7/value  /*DO2 channel output low*/
    echo 1 >/sys/class/gpio/gpio12/value /*DO3 channel output low*/
    echo 1 >/sys/class/gpio/gpio13/value /*DO4 channel output low*/
    ```
    -   AI[1:2]  
    The data of the analog channel is obtained through the ttyS3 serial interface, with a communication baud rate of 9600.  
    Two analog input channels support 0 to 10V or 4 to 20mA analog signal input.   
    The interface defaults to current input mode and has a 500 ohm resistance to ground.   
    If a voltage signal needs to be input, the channel needs to be configured as a voltage input type first, otherwise it will cause accuracy loss.    
    The ADC accuracy is 10 bits, and the value range obtained for the corresponding voltage type is 0 to 1024.0 represents the input voltage of 0V, and 1024 represents the input voltage of 10V.  
    The range of values for current input types is from 0 to 1024, where 0 represents an input current of 0mA and 1024 represents an input current of 20mA.

    Send command format
    | HEAD0 | HEAD1 | CMD | DATA |
    |:-:|:-:|:-:|:-:| 
    |0xAA|0x55|CMD|DATA|   

    Command Word
    | CMD | Instructions |
    |----|----|
    |0x01|Obtain channel ADC sampling values and transmit 2 channel values at a time.|
    |0x02|Set the channel input type, voltage or current.|
    |0x03|Get the type of input channel.|
    |0x04|Set up automatic scheduled sending of sampling results.|

    Data
    | CMD | Data |Instructions |
    |----|----|----|
    |0x01|NULL|NULL|
    |0x02|0x11/0x10/0x01/0x00|The high position represents AI2 channel, and the low position represents AI1 channel. 1 represents current input type, 0 represents voltage input type.0X10 represents that AI2 channel is a current type input and AI1 channel is a voltage type input.|
    |0x03|NULL|NULL|
    |0x04|0X00:0X64|Configure the automatic sending time, with a minimum time unit of 10ms and a maximum of 1S. 0x00 disable automatic reporting,0X01 represents 10ms, 0x64 represents 0X64 * 10ms=1S.|
    ```
    echo -ne "\xaa\x55\x01\x00" >/dev/ttyS3      //Get the ADC value of the analog channel.
    echo -ne "\xaa\x55\x02\x10" >/dev/ttyS3      //AI2 is configured as a current type input, and AI1 is configured as a voltage type input.
    echo -ne "\xaa\x55\x03\x00" >/dev/ttyS3      //Get the input type of the analog channel.
    echo -ne "\xaa\x55\x04\x02" >/dev/ttyS3      //Configure 20ms automatic reporting of ADC values for two channels.
    echo -ne "\xaa\x55\x04\x00" >/dev/ttyS3      //Disable automatic reporting.
    ```
    Receive data format
    | HEAD0 | HEAD1 | DATA0 | DATA1 | DATA2 | DATA3 |
    |:-:|:-:|:-:|:-:|:-:|:-:| 
    |0xAA|0x55|DATA0|DATA1|DATA2|DATA3| 
    |0xAA|0x55|AI1L|AI1H|AI2L|AI2H| 

    ```
    /*Receive Example*/
    0xaa 0x55 0xff 0x03 0x00 0x00 /* AI1 channel is 0x3ff, AI2 channel is 0x00 */  

    Voltage = 0x3ff*10V/0x400=9.99V       //Voltage type input
    Current = 0x3ff*20mA/0x400=19.98mA    //Current type input
    ```
    -   4G-LTE 
    
        The default 4G-LET module model currently used is EG25-GL.
        The insertion direction of Nano-SIM card is as follows.
        <div align=center>  <img src=".\image\007.png" width=50%></div>       

        Modify APN Username and Password.The information is obtained from the service provider.
        ```
        sudo vim /etc/ppp/quectel-pppd.sh
        ```
        <div align=center>  <img src=".\image\006.png" width=50%></div>  

        The machine will automatically complete the dialing operation after booting up. 
        
        After successful dialing, the system will display the following ppp0 network nodes.

        <div align=center>  <img src=".\image\4G.png" width=50%></div>     

    -   WIFI&BT

        The default WIFI module model used by the machine is BL-M8800DU6-D80, which uses the AIC8800D80 chip.  
        Support wifi 802.11a/b/g/n/ac/ax and bt5.4.<br>
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
<div align=center>  <img src=".\image\008.png" width=50%></div>

- Connect the USB port of CP2b-P to the computer.
<div align=center>  <img src=".\image\009.png" width=50%></div>

- Install USB driver using the DriveAssitant-v5.12 tool.
<div align=center>  <img src=".\image\0001.png" width=50%></div>

- Enter LOADER or MASKROM burning mode
  - Press and hold the REC button on the machine, then turn on the power and the machine will enter MASKROM mode.  
  - You can also enter the "sudo reboot loader" command on the serial command line to enter LOADER mode.  
  - You can also enter "ctrl+c" on the serial command line to enter the uboot command line at the moment of startup, and then enter the rbrom command. The machine will also enter MASKROM mode.  
  - Both LOADER and MASKROM states can update images.
<div align=center>  <img src=".\image\010.png" width=50%></div>

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

## Install NodeRed

-   Run the following command to install node_red

    ```
    sudo apt update
    sudo apt install curl
    curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g --unsafe-perm node-red
    ```
-   Set up startup upon startup
    ```
    sudo vim /etc/systemd/system/node-red.service
    ```
    Add the following content
    ```
    [Unit]
    Description=Node-RED
    After=network.target

    [Service]
    ExecStart=/usr/bin/node /usr/bin/node-red
    User=admin

    [Install]
    WantedBy=multi-user.target
    ```
    Start the service and set up startup, check the service status.
    ```
    sudo systemctl daemon-reload
    sudo systemctl start node-red
    sudo systemctl enable node-red
    sudo systemctl status node-red
    ```
-   Set Password  
    Generate username and password, using admin as an example here
    ```
    admin@cp2b:~$ node-red admin hash-pw
    Password: $2y$08$cUm1LgtBnDt.b.az4IiLeuPCNb0LFv.hbnd71OWwd94j.GMF/WVnW
    ```
    Open the settings. js file, modify the content of adminAuth, and copy the string from earlier. Save and exit.
    ```
    vim /home/admin/.node-red/settings.js

    /*******************************************************************************
     * Security
     *  - adminAuth
     *  - https
     *  - httpsRefreshInterval
     *  - requireHttps
     *  - httpNodeAuth
     *  - httpStaticAuth
    ******************************************************************************/
 
    /** To password protect the Node-RED editor and admin API, the following
     * property can be used. See https://nodered.org/docs/security.html for detaails.
     */
    adminAuth: {
        type: "credentials",
        users: [{
            username: "admin",
            password: "$2y$08$cUm1LgtBnDt.b.az4IiLeuPCNb0LFv.hbnd71OWwd94j.GMF/WVnW",
            permissions: "*"
        }]
    }
    ```
-   Browser input http://your-ip-address:1880 Enter your username and password to log in.
    <div align=center>  <img src=".\image\015.png" width=50%></div> 

## Install Docker

-   Install related dependencies
    ```
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
-   Pull image
    ```
    admin@cp2b-p:~$ sudo docker run hello-world
    Hello from Docker!
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
    1. The Docker client contacted the Docker daemon.
    2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm32v7)
    3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
    4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
    $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker ID:
    https://hub.docker.com/

    For more examples and ideas, visit:
    https://docs.docker.com/get-started/

    ```
-   Replace the source
    The image pulling speed is relatively slow. You can try changing the image source.
    ```
    sudo vim /etc/docker/daemon.json
    ```
    Copy the following content
    ```
    {
        "registry-mirrors": [
            "https://docker.m.daocloud.io"
        ]
    }

    ```
    Restart service
    ```
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    ```
    
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
        
       - Ensure that the SIM card is inserted in the correct direction?
       - Ensure that APN Username and Password have been correctly configured?
       - Use the following command to confirm that the 4G module has recognized,Registering a 4G module normally will generate four nodes, ttyUSB0 to ttyUSB3.
        ```
        ls /dev/| grep ttyUSB* 
        ```

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



  































    












































