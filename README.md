# Easy USB Relay Controller (serial)
Written in java using OpenProcessing libraries.  Works with most USB Relays sold on Amazon.  Single and MultiChannel Relays.

**Basic Usage:**

Update the relay_config.csv to match your relay settings.  The app supports up to 8 relays.  Leave rows blank for unused relays.
- Label: Text displayed next to the switch in the app
- Com Port: The com port number for that relay, ex: COM2
- Channel: Channel number for a relay.  Set to 1 for a single relay. 1,2 for 2 channel, and so on
- Default: When the app loads, it will set the relays to the default selection.  0=Open, 1=Closed, 2=Disable default set on load

Launch app and click the switches to Close / Open the relays.

**Serial Format:**

Byte 1: Start Byte 0xA0
Byte 2: Channel Number
Byte 3: Relay State
Byte 4: Checksum

Example: 0xA0 0x01 0x01 0xA2
