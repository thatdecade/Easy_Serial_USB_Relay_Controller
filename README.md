# Easy USB Relay Controller (serial)
Written in java using OpenProcessing libraries.  Works with most USB Relays sold on Amazon, both Single and MultiChannel Relays.  Lots of configuration options.

Windows exe requires Java 8 or higher installed.

![](https://farm2.staticflickr.com/1962/44912786921_54c25e985b.jpg)

**Basic Usage:**

Update the relay_config.csv to match your relay settings. Launch app and click the switches to Close / Open the relays.

- Label: Text displayed next to the switch in the app
- Com Port: The com port number for that relay, ex: COM2
- Channel: Channel number for a relay.  Set to 1 for a single relay. 1,2 for 2 channel, and so on
- Default: When the app loads, it will set the relays to the default selection.  0=Open, 1=Closed, 2=Disable default set on load

The app supports up to 8 relays.  Leave rows blank for unused relays.

**Serial Format:**

* Byte 1: Start Byte 0xA0
* Byte 2: Channel Number
* Byte 3: Relay State
* Byte 4: Checksum

Example: 0xA0 0x01 0x01 0xA2

**Troubleshooting:**

The COM number must match the relay device under windows device manager.  Check that no other applications have locked the port.  If neeeded, restart your pc to force the connection from the other application to close.

**relay_config.csv Example:**

label,comport,channel,default  
Relay Name 1,COM10,1,1  
Relay Name 2,COM10,2,1  
Relay Name 3,COM10,3,0  
Relay Name 4,COM10,4,0  
Relay Name 5,COM10,1,1  
Relay Name 6,COM10,2,1  
Relay Name 7,COM10,3,0  
Relay Name 8,COM10,4,0  
