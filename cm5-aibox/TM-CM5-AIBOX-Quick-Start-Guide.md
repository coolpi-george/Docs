# TM-CM5-AIBOX Quick Start Guide
<div align=center>  <img src=".\image\1.png" width=50%></div>

## Login steps
- Connect the power and plug in the network cable
    -   The power supply range is 9V-30V, use 3.5mm pitch phoenix terminal connectors. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=center>  <img src=".\image\2.png" width=40%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.

- Login device<br>
    -   You can log in using the console interface
        <div align=center>  <img src=".\image\3.png" width=50%></div>  

    -   The console is a USB to serial chip CH340, and the driver needs to be [Download](https://www.wch.cn/download/file?id=65) and installed before use.
  
    -   The default baud rate for console serial port is 115200.
    -   You can also log in to the machine via the graphical interface by connecting an HDMI monitor, keyboard, and mouse, then entering the username and password. The default username and password are: admin
        <div align=center>  <img src=".\image\4.png" width=50%></div> 
        
## Interface operation
- Interface
    -   IO
        <div align=center>  <img src=".\image\5.png" width=50%></div>

        |  Name   | Description  |   Name   | Description  |
        |  ----  | ----  |  ----  | ----  |
        | B1  | RS485-1B |H  | CAN2.0-H |
        | A1  | RS485-1A  |L  | CAN2.0-L |
        | G  | GND |G  | GND |
        | B2  | RS485-2B  |RX  | TTL-RXD(5V) |
        | A2  | RS485-2A |TX  | TTL-TXD(5V) |
        | 5V  | 5V-OUT(100mA) |G  | GND |

    -   The correspondence between ttySx device nodes and interfaces.

        ttyS4 -- RS485-1 (A1 B1)

        ttyS7 -- RS485-2 (A2 B2)

        ttyS9 -- UART-TTL(5V) (IO0 IO1) //These two pins can be configured for UART(default) 、GPIO and I2C functions.

        ttyUSB0-ttyUSB3 -- 4G-LTE

    -   RS485&RS232

        ```
        stty -F /dev/ttyS4 raw speed 115200 //Configure RS485 baud rate to 115200
        echo "hello world" > /dev/ttyS1     //Send "hello world" to RS485 port
        ```
        - You can also operate the serial port through C or Python.
    -   4G-LTE 

        - The machine defaults to using ModemManager to manage the 4G-LTE network. If no SIM card is inserted, the following status will be displayed.

        <div align=center>  <img src=".\image\6.png" width=50%></div>

        - Insert the SIM card and restart the machine, and the following interface will appear. After configuring the APN, it will automatically connect to the network.

        <div align=center>  <img src=".\image\7.png" width=50%></div>

        - You can obtain APN ，username and password from different operators through the following connections. 

            [https://bigfun.tripod.co.uk/](https://bigfun.tripod.co.uk/)

        - The SIM card insertion direction is as follows.The metal finger is facing upwards, and the notch is facing inside the machine.
        <div align=center>  <img src=".\image\8.png" width=50%></div>  

    -   WIFI
        - The default WIFI module model used by the machine is RTL8852BE, Supports WIFI6 and BT5.2 protocols. <br>
        - The system has already integrated drivers and firmware by default, and can be used by plugging in the module.<br>
        - Users can replace different WIFI modules according to their actual product needs, with M.2 (PCIe+USB) interface.
        <div align=center>  <img src=".\image\9.png" width=20%></div>

    -   CAN-2.0B
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
- Download firmware and upgrade tools from [Google Drive](https://drive.google.com/drive/folders/1rpwDABPB5bxYspOhQ6YbhDFaWXRB4QgH?usp=sharing) or [Baidu Cloud](https://pan.baidu.com/s/1hJfx2A-HToroDK6UYPIOIQ?pwd=eut4) .
<div align=center>  <img src=".\image\10.png" width=50%></div>

- Connect the USB3.0-OTG port of CM5-AIBOX to the computer.
  
<div align=center>  <img src=".\image\11.png" width=50%></div>

  
- Install USB driver using the DriveAssitant-v5.12 tool. Drivers and burning tools can be obtained from the tools directory on the cloud drive.

<div align=center>  <img src=".\image\12.png" width=50%></div>

- Press and hold the REC button on the machine, then turn on the power and the machine will enter Loader mode.

<div align=center>  <img src=".\image\13.png" width=50%></div>

- Open RKDevTool tool, Switch from loader mode to maskrom mode as shown in the following figure.
    - Open the tool and discover the loader device.
  
    <div align=center>  <img src=".\image\14.png" width=50%></div>

    - Switch to Maskrom mode according to the following diagram.
  
    <div align=center>  <img src=".\image\15.png" width=50%></div>

    - Check the option to force writing by address, click run, and wait for the burning to complete.
    <div align=center>  <img src=".\image\16.png" width=50%></div>

    - The loader.bin and uboot.img can be obtained from the loader directory on the cloud drive.
    <div align=center>  <img src=".\image\17.png" width=50%></div>

## Compile and update the kernel 

- Synchronize kernel code and compile

    ```
    git clone https://github.com/coolpi-george/coolpi-kernel.git
    git checkout linux-6.1-stan-rkr3.1
    ./build-kernel.sh arm64
    ``` 
- update kernel
  
    After compilation, the following deb file will be generated and copied to the machine for installation using the "dpkg -i linux-image-6.1.75_6.1.75-23_arm64.deb" command. 

## Compile and update the uboot
- Synchronize kernel code and compile
    ```
    git clone https://github.com/coolpi-george/coolpi-loader.git
    git checkout linux-6.1-stan
    ./make.sh coolpi_rk3588_aibox --spl-new
    ``` 
- After compilation is complete, a coolpi_ * _nor_upgrade.img file will be generated in the out directory, which merges loader.bin and uboot.img. It can be upgraded in the system using the following command: 
    ```
    sudo dd if=./coolpi_ * _nor_upgrade.img of=/dev/mtdblock0 bs=1M
    ```
    <div align=center>  <img src=".\image\19.png" width=50%></div>
    
- Alternatively, the RKDevTool can be used to upgrade the loader and uboot separately, as shown in the following figure. It is necessary to configure the storage, address, and check the option to force write to address.
    <div align=center>  <img src=".\image\20.png" width=50%></div>

## How to run AI models
- CM5-AIBOX supports multiple AI hardware, RK3588 comes with 6Tops NPU,Hailo8 AI module,Deepx AI module and RK182X(Adaptation in progress) AI module.
- RK3588 NPU
    ```
    cd /home/admin/share/rockchip/rknn_model_zoo
    ./build-linux.sh -t rk3588 -a aarch64 -d yolov5
    cd install/rk3588_linux_aarch64/rknn_yolov5_demo/
    ./rknn_yolov5_demo model/yolov5s_relu.rknn model/bus.jpg
    ```
    <div align=center>  <img src=".\image\22.png" width=1000%></div>
    <div align=center>  <img src=".\image\21.png" width=80%></div>

- Hailo8

- Deepx
    ```
    cd /home/admin/share/deepx/dx-all-suite/dx-runtime/dx_app
    ./bin/yolo_multi -c example/yolo_multi/ppu_yolo_multi_demo.json
    ```
    <div align=center>  <img src=".\image\23.png" width=1000%></div>
- RK182X(to be updated)
## Common problems and solutions

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
