# TM-CP1B Quick Start Guide
<div align=center>  <img src=".\image\image.png" width=70%></div>

- Connect the power and plug in the network cable
    -   The power supply range is 9V-36V, with the positive terminal near the LED end. <br>Note: Incorrect polarity can cause damage to the machine.
        <div align=left>  <img src=".\image\image-1.png" width=40%></div>

    -   The default network connection method of the machine is DHCP to automatically obtain an IP address.<br> 
        After the network is connected normally, the two indicator lights on the network port will light up simultaneously.
- Obtain the IP address of the machine<br>
    -   Use LAN IP address scanning software [Advanced_IP_Scanner](https://download.advanced-ip-scanner.com/download/files/Advanced_IP_Scanner_2.5.4594.1.exe) to obtain all scanned LAN IP addresses.
    -   After downloading and installing the software, open the software and you will see the following interface. Click Scan to start scanning.
        <div align=left>  <img src=".\image\image-2.png" width=80%></div>

    -   The machine with the device name coolpi in the scanning results corresponds to the DHCP address of the machine.

- Login device<br>
    -   Enter the following link in the browser to enter the login interface:<br>
        https://your_ipaddress:9090/<br>  
        Replace 'your_ipaddress' with the actual IP address of the machine.<br>  
        <div align=left>  <img src=".\image\image-5.png" width=80%></div>

    -   Enter your username and password, then click login.<br> The default username for the machine is admin, and the password is admin.
        <div align=left>  <img src=".\image\image-6.png" width=80%></div>

    -   Click on the terminal to enter the shell interface, where you can update various devices of the system or operating system.
        <div align=left>  <img src=".\image\image-8.png" width=80%></div>

- Interface operation
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
        <div align=left>  <img src=".\image\image-10.png" width=80%></div>

    -   WIFI

        The default WIFI module model used by the machine is BL-R7601MU5, which uses the MT7601U chip. <br>
        The system has already integrated drivers and firmware by default, and can be used by plugging in the module.
        <div align=left>  <img src=".\image\image-11.png" width=80%></div>

    -   LORA(To be updated)

- Common problems and solutions
    -   How to change default password？
        ```
        usermod -p $(openssl passwd -1 123) admin //Change the admin password to 123
        ```
    -   How to add a new user?
        As shown in the following figure, new users can be added and permissions can be configured through the backend management software.
        <div align=left>  <img src=".\image\image-9.png" width=80%></div>
    -   How to connect to WiFi network？
        ```
        /*Find available WiFi networks*/
        nmcli dev wifi list
        /*To connect to a WiFi network, you need to replace<SSID>with the network name you want to connect to, and<password>with the password for that network:*/
        nmcli --ask dev wifi connect <SSID> password <password> 
        ```
    -   Unable to register for 4G network?
        
        Pay attention to the insertion direction of the SIM card as shown in the figure below, with the notch facing outward.
        <div align=left>  <img src=".\image\sim.png" width=80%></div>


  































    












































