import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class java_app extends PApplet {






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

boolean RELAY_CLOSED_BOOL = false;
boolean RELAY_OPEN_BOOL = true;

int[] toggleValues = {RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, RELAY_OPEN, };

int STARTING_X_POS = 30;
int SWITCH_X_SPACING = 50;

int LABEL_Y_POSITION = 100;

int LABEL_Y_CHAR_SPACING = 12;

int relay_counter = 0;

public void setup() 
{
  int longest_string = 0;
  
  surface.setTitle("Relay Controller v0.1");

  relay_config = loadTable("relay_config.csv", "header");

  for (TableRow row : relay_config.rows()) 
  {
    String label = row.getString("label");
    
    if(longest_string < label.length())
    {
      longest_string = label.length();
    }
  }
  
  //change window dimensions based on number of switches and label text
  int window_x = STARTING_X_POS+SWITCH_X_SPACING*relay_config.getRowCount();
  int window_y = LABEL_Y_POSITION+longest_string*LABEL_Y_CHAR_SPACING+40;
  
  
  surface.setResizable(true);
  surface.setSize(window_y, window_x);
  
  
  cp5 = new ControlP5(this);

  //Note: each switch has a coorsponding function of the same name to handle state
  create_relay_switch(RELAY_1_TABLE_INDEX, "Relay1", "label1");
  create_relay_switch(RELAY_2_TABLE_INDEX, "Relay2", "label2");
  create_relay_switch(RELAY_3_TABLE_INDEX, "Relay3", "label3");
  create_relay_switch(RELAY_4_TABLE_INDEX, "Relay4", "label4");
  create_relay_switch(RELAY_5_TABLE_INDEX, "Relay5", "label5");
  create_relay_switch(RELAY_6_TABLE_INDEX, "Relay6", "label6");
  create_relay_switch(RELAY_7_TABLE_INDEX, "Relay7", "label7");
  create_relay_switch(RELAY_8_TABLE_INDEX, "Relay8", "label8");
  
}

public void set_relay(int relay_index, int relay_state)
{
  TableRow row = relay_config.getRow(relay_index);
  String comport = row.getString("comport");
  int channel = row.getInt("channel");
  
  println("comport = " + comport);
  println("channel = " + channel);
  
  open_serial_port(comport);
  myPort.write(SERIAL_START_BYTE);
  myPort.write(channel);
  myPort.write(relay_state);
  myPort.write(SERIAL_START_BYTE + channel + relay_state); //checksum
  close_serial_port();
}

public void open_serial_port(String port_number)
{
  myPort = new Serial(this, port_number, SERIAL_BAUD);
}
  
public void close_serial_port()
{
  myPort.clear();
  myPort.stop();
}
  
public void create_relay_switch(int table_index, String switch_name, String label_name)
{
  boolean initial_state = false;
  
  if(relay_config.getRowCount() > table_index)
  {
    TableRow row = relay_config.getRow(table_index);
    toggleValues[table_index] = row.getInt("default");
    
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
       ;
    
    cp5.addTextlabel(label_name)
                    .setText(row.getString("label"))
                    .setPosition(LABEL_Y_POSITION,(STARTING_X_POS+SWITCH_X_SPACING*relay_counter)-5)
                    .setColorValue(0x0)
                    .setFont(createFont("Georgia",20))
                    ;
                    
    relay_counter++;
  }
}
  
public void draw() {
  background(255);
  pushMatrix();
  popMatrix();
}

public void Relay1(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    //toggleValues[RELAY_1_TABLE_INDEX] = row.getInt("default");
    toggleValues[RELAY_1_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_1_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_1_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_1_TABLE_INDEX]);
  }
  
  set_relay(RELAY_1_TABLE_INDEX, toggleValues[RELAY_1_TABLE_INDEX]);
}

public void Relay2(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_2_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_2_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_2_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_2_TABLE_INDEX]);
  }
  
  set_relay(RELAY_2_TABLE_INDEX, toggleValues[RELAY_2_TABLE_INDEX]);
}

public void Relay3(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_3_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_3_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_3_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_3_TABLE_INDEX]);
  }
  
  set_relay(RELAY_3_TABLE_INDEX, toggleValues[RELAY_3_TABLE_INDEX]);
}

public void Relay4(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_4_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_4_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_4_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_4_TABLE_INDEX]);
  }
  
  set_relay(RELAY_4_TABLE_INDEX, toggleValues[RELAY_4_TABLE_INDEX]);
}

public void Relay5(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_5_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_5_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_5_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_5_TABLE_INDEX]);
  }
  
  set_relay(RELAY_5_TABLE_INDEX, toggleValues[RELAY_5_TABLE_INDEX]);
}

public void Relay6(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_6_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_6_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_6_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_6_TABLE_INDEX]);
  }
  
  set_relay(RELAY_6_TABLE_INDEX, toggleValues[RELAY_6_TABLE_INDEX]);
}

public void Relay7(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_7_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_7_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_7_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_7_TABLE_INDEX]);
  }
  
  set_relay(RELAY_7_TABLE_INDEX, toggleValues[RELAY_7_TABLE_INDEX]);
}

public void Relay8(boolean theFlag) {
  if(theFlag==false) {
    //toggle left
    toggleValues[RELAY_8_TABLE_INDEX] = RELAY_CLOSED;
    //println(toggleValues[RELAY_8_TABLE_INDEX]);
    
  } else {
    //toggle right
    toggleValues[RELAY_8_TABLE_INDEX] = RELAY_OPEN;
    //println(toggleValues[RELAY_8_TABLE_INDEX]);
  }
  
  set_relay(RELAY_8_TABLE_INDEX, toggleValues[RELAY_8_TABLE_INDEX]);
}
  public void settings() {  size(400,400);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "java_app" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
