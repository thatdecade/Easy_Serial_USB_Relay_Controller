import controlP5.*;
import processing.serial.*;

ControlP5 cp5;

Serial myPort;

int SERIAL_BAUD = 9600;
int SERIAL_START_BYTE = 0xA0;

Table relay_config;

int RELAY_1_TABLE_INDEX = 0;
int RELAY_2_TABLE_INDEX = 1;
int RELAY_3_TABLE_INDEX = 2;
int RELAY_4_TABLE_INDEX = 3;
int RELAY_5_TABLE_INDEX = 4;
int RELAY_6_TABLE_INDEX = 5;
int RELAY_7_TABLE_INDEX = 6;
int RELAY_8_TABLE_INDEX = 7;

int RELAY_CLOSED = 1;
int RELAY_OPEN = 0;
int DISABLE_DEFAULT = 2;

boolean RELAY_CLOSED_BOOL = false;
boolean RELAY_OPEN_BOOL = true;

int[] toggleValues = {RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, };
int[] last_toggleValues = {DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, DISABLE_DEFAULT, };

int STARTING_X_POS = 30;
int SWITCH_X_SPACING = 50;

int LABEL_Y_POSITION = 100;

int LABEL_Y_CHAR_SPACING = 12;

int relay_counter = 0;

boolean table_is_ok = false;

boolean com_is_ok = false;
boolean error_displayed = false;

boolean info_was_clicked = false;
boolean info_close_was_clicked = false;
boolean dont_run_info_on_startup = false;
boolean dont_run_info_close_on_startup = false;

int window_x;
int window_y;

void setup() 
{
  int longest_string = 0;
  int table_index = 0;
  
  cp5 = new ControlP5(this);

  surface.setTitle("Relay Controller v0.1");
  
  //change icon
  File f = new File(sketchPath("icon.png"));
  if (f.exists()) 
  {
    PImage icon = loadImage("icon.png");
    surface.setIcon(icon);
  } 
  else
  {
    println("icon.png does not exist");
  }

  //load table
  File f2 = new File(sketchPath("relay_config.csv"));
  if (f2.exists()) 
  {
    table_is_ok = true;
    relay_config = loadTable("relay_config.csv", "header");
  }
  else
  {
    println("relay_config.csv does not exist, using defaults");
    
    relay_config = new Table();
    relay_config.addColumn("label");
    relay_config.addColumn("comport");
    relay_config.addColumn("channel");
    relay_config.addColumn("default");
    
    TableRow row1 = relay_config.addRow();
    row1.setString("label", "relay_config.csv is missing");
    row1.setString("comport", "null");
    row1.setInt("channel", 0);
    row1.setInt("default", 2);
    
  }
  
  //parse basic info from table
  for (TableRow row : relay_config.rows()) 
  {
    //window size
    String label = row.getString("label");
    if(longest_string < label.length())
    {
      longest_string = label.length();
    }
    
    //defaults
    toggleValues[table_index] = row.getInt("default");
    if(toggleValues[table_index] == DISABLE_DEFAULT)
    {
       last_toggleValues[table_index] = toggleValues[table_index];
    }
    table_index++;
  }
  
  //change window dimensions based on number of switches and label text
  window_x = STARTING_X_POS+SWITCH_X_SPACING*relay_config.getRowCount();
  window_y = LABEL_Y_POSITION+longest_string*LABEL_Y_CHAR_SPACING+40;
  
  size(400,400);
  surface.setResizable(true);
  surface.setSize(window_y, window_x);
  smooth();
  
  relay_counter = 0;
  create_front_page();
}

void set_relay(int relay_index, int relay_state)
{
  TableRow row = relay_config.getRow(relay_index);
  String comport = row.getString("comport");
  int channel = row.getInt("channel");
  String[] ports = Serial.list();

  com_is_ok = false;
  
  for (String p : ports)
  {
    if (p.equals(comport))
    {
      com_is_ok = true;
      open_serial_port(comport);
      myPort.write(SERIAL_START_BYTE);
      myPort.write(channel);
      myPort.write(relay_state);
      myPort.write(SERIAL_START_BYTE + channel + relay_state); //checksum
      close_serial_port();
    }
  }
}

void open_serial_port(String port_number)
{
   myPort = new Serial(this, port_number, SERIAL_BAUD);
}
  
void close_serial_port()
{
  myPort.clear();
  myPort.stop();
}
  
void create_relay_switch(int table_index, String switch_name, String label_name)
{
  boolean initial_state = false;
  
  if(relay_config.getRowCount() > table_index)
  { 
    TableRow row = relay_config.getRow(table_index);
    
    if(toggleValues[table_index]==RELAY_CLOSED) 
    {
      initial_state = RELAY_CLOSED_BOOL;
    }
    else
    {
      initial_state = RELAY_OPEN_BOOL;
    }
    
    // create a toggle and change the default look to a (on/off) switch look
    cp5.addToggle(switch_name)
       .setPosition(40,STARTING_X_POS+SWITCH_X_SPACING*relay_counter)
       .setSize(50,20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .setState(initial_state)
       .setColorCaptionLabel(255)
       .setCaptionLabel(row.getString("comport") + " - CH" + row.getString("channel"))
       ;
    
    cp5.addTextlabel(label_name)
                    .setText(row.getString("label"))
                    .setPosition(LABEL_Y_POSITION,(STARTING_X_POS+SWITCH_X_SPACING*relay_counter)-5)
                    .setColorValue(0x0)
                    .setFont(createFont("Georgia",20))
                    ;
                    
    relay_counter++; //used for spacing of the buttons
  }
}
  
void draw() {
  
  //check for info button press
  if(info_was_clicked)
  {
    info_was_clicked = false;
    dont_run_info_on_startup = false;
    dont_run_info_close_on_startup = false;
    
    remove_front_page(); 
    create_info_page();
  }
  
  if(info_close_was_clicked)
  {
    info_close_was_clicked = false;
    dont_run_info_on_startup = false;
    dont_run_info_close_on_startup = false;
    
    remove_info_page(); 
    
    relay_counter = 0;
    create_front_page();
  }

  if(error_displayed == false && com_is_ok == false)
  {
    error_displayed = true;
    
    cp5.addTextlabel("error_label")
              .setText("Check Config: COM Port Error")
              .setPosition(10,10)
              .setColorValue(128)
              .setColor(0xffff0000)
              .setFont(createFont("Georgia",12))
              ;
  
  }
  
  if(error_displayed == true && com_is_ok == true)
  {
    error_displayed = false;
    cp5.remove("error_label");
  }
  
  //check for switch changes, command relays
  for (int i=0; i<relay_config.getRowCount(); i++) 
  {
     if(last_toggleValues[i] != toggleValues[i])
     {
       last_toggleValues[i] = toggleValues[i]; 
       set_relay(i, toggleValues[i]);
   
     }
  }
  
  background(255);
  pushMatrix();
  popMatrix();
}

void create_front_page()
{
  if(table_is_ok)
  {
    //Note: each switch has a coorsponding function of the same name to handle state changes
    create_relay_switch(RELAY_1_TABLE_INDEX, "Relay1", "label1");
    create_relay_switch(RELAY_2_TABLE_INDEX, "Relay2", "label2");
    create_relay_switch(RELAY_3_TABLE_INDEX, "Relay3", "label3");
    create_relay_switch(RELAY_4_TABLE_INDEX, "Relay4", "label4");
    create_relay_switch(RELAY_5_TABLE_INDEX, "Relay5", "label5");
    create_relay_switch(RELAY_6_TABLE_INDEX, "Relay6", "label6");
    create_relay_switch(RELAY_7_TABLE_INDEX, "Relay7", "label7");
    create_relay_switch(RELAY_8_TABLE_INDEX, "Relay8", "label8");

    cp5.addButton("info")
     .setValue(0)
     .setPosition(window_y-45,5)
     .setSize(40,19)
     ;
  }
  else
  {    
    //display error message
    TableRow row = relay_config.getRow(RELAY_1_TABLE_INDEX);
    cp5.addTextlabel("label1")
                    .setText(row.getString("label"))
                    .setPosition(LABEL_Y_POSITION,(STARTING_X_POS+SWITCH_X_SPACING)-5)
                    .setColorValue(0x0)
                    .setFont(createFont("Georgia",20))
                    ;
  }
}

void remove_front_page()
{
  remove_relay(RELAY_1_TABLE_INDEX, "Relay1", "label1");
  remove_relay(RELAY_2_TABLE_INDEX, "Relay2", "label2");
  remove_relay(RELAY_3_TABLE_INDEX, "Relay3", "label3");
  remove_relay(RELAY_4_TABLE_INDEX, "Relay4", "label4");
  remove_relay(RELAY_5_TABLE_INDEX, "Relay5", "label5");
  remove_relay(RELAY_6_TABLE_INDEX, "Relay6", "label6");
  remove_relay(RELAY_7_TABLE_INDEX, "Relay7", "label7");
  remove_relay(RELAY_8_TABLE_INDEX, "Relay8", "label8");
  cp5.remove("info");
}

void create_info_page()
{
  cp5.addButton("close_info")
     .setCaptionLabel("close")
     .setValue(0)
     .setPosition(window_y-45,5)
     .setSize(40,19)
     ;
     
  Textarea myTextarea = cp5.addTextarea("txt")
                  .setPosition(25,50)
                  .setSize(window_y-25-25,window_x-50-25)
                  .setFont(createFont("arial",12))
                  .setLineHeight(14)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100));
                  ;
                  
  myTextarea.setText("Relay Controller v1.0\n"
                    +"Author: Dustin Westaby 2018\n"
                    +"\n"
                    +"Written in java using OpenProcessing. "
                    +"Works with most USB controlled Relays.\n"
                    +"\n"
                    +"csv Example:\n"
                    +"\n"
                    +"label,comport,channel,default\n"
                    +"Relay Name 1,COM10,1,1\n"
                    +"Relay Name 2,COM10,2,1\n"
                    +"Relay Name 3,COM10,3,0\n"
                    +"Relay Name 4,COM10,4,0\n"
                    +"Relay Name 5,COM10,1,1\n"
                    +"Relay Name 6,COM10,2,1\n"
                    +"Relay Name 7,COM10,3,0\n"
                    +"Relay Name 8,COM10,4,0\n"
                    +"\n"
                    +"Supports up to 8 relays on multiple com ports. Leave extra rows blank for unused relays.\n"
                    +"\n"
                    +"csv column descriptions:\n"
                    +"\n"
                    +"Label: Text displayed next to the switch in the app\n"
                    +"Com Port: The com port number for that relay, ex: COM2\n"
                    +"Channel: Channel number for a relay. Set to 1 for a single relay.\n"
                    +"Default: 0=Open, 1=Closed, 2=Disable default set relay on load\n"
                    +"\n"
                    +"Troubleshooting:\n"
                    +"\n"
                    +"The COM number must match the relay device under windows device manager.  Check that no other applications have locked the port.  If neeeded, restart your pc to force the connection from the other application to close.\n"
                    +"\n"
                    );
}

void remove_info_page()
{
  cp5.remove("close_info");
  cp5.remove("txt");
}

void remove_relay(int table_index, String switch_name, String label_name)
{
  if(relay_config.getRowCount() > table_index)
  { 
    cp5.remove(switch_name);
    cp5.remove(label_name);
  }
}

void info(int theValue) 
{
  if(dont_run_info_on_startup)
  {
    info_was_clicked = true;
  }
  
  dont_run_info_on_startup = true;
}

void close_info(int theValue) 
{
  if(dont_run_info_close_on_startup)
  {
    info_close_was_clicked = true;
  }
  
  dont_run_info_close_on_startup = true;
}

void Relay1(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_1_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_1_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay2(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_2_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_2_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay3(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_3_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_3_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay4(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_4_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_4_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay5(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_5_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_5_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay6(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_6_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_6_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay7(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_7_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_7_TABLE_INDEX] = RELAY_OPEN;
  }
}

void Relay8(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_8_TABLE_INDEX] = RELAY_CLOSED;
    
  } else {
    //toggle right
    toggleValues[RELAY_8_TABLE_INDEX] = RELAY_OPEN;
  }
}
