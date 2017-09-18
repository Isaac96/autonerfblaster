import codeanticode.gsvideo.*; 
//import processing.video.*;
import monclubelec.javacvPro.*; 
import java.awt.*; 
import processing.serial.*;
import controlP5.*;

PImage img;
PFont font;
Rectangle[] faceRect; 

GSCapture cam; 
OpenCV opencv; 

int widthCapture=640; 
int heightCapture=480;
int fpsCapture=12; 
int spos=90;
int millis0=0;

int targetCenterX;
int targetCenterY;
String debugText = "";

boolean targetFound = false;
int trackingLostHash = 0;
int hashLimit = 5;
int threshold = 20;
int thresholdLeft;
int thresholdRight;

Serial port;

ControlP5 cp5;
boolean showUI = true;
int slider1 = 0;
int slider2 = 193;
int slider3 = 255;
int circleExpand = 0;
int circleWidth = 3;
Textlabel labelDebugText;
Textlabel labelFIRE;

void setup()
{ 
        size (widthCapture, heightCapture); 
        frameRate(fpsCapture); 
        background(0);
        
        //cam = new Capture(this, cameras[19]);
        cam = new GSCapture(this, widthCapture, heightCapture, "0"); 
        cam.start(); 
        
        font = loadFont("orbitron-medium-48.vlw");
        
        opencv = new OpenCV(this); 
        opencv.allocate(widthCapture, heightCapture); 
        
        //Set the OPENCV DETECTION TYPE
        //Comment or delete the platform you're NOT on.
        //opencv.cascade("FRONTALFACE_ALT", true);    //Windows location
        opencv.cascade("/usr/local/share/OpenCV/haarcascades/","haarcascade_frontalface_alt.xml");    //Mac location 
        
        //select second com-port from the list
        println(Serial.list()); // List COM-ports
        //port = new Serial(this, Serial.list()[5], 57600); 
        
        //UI
        cp5 = new ControlP5(this); 
        
        cp5.addSlider("slider1")
           .setPosition(75,400)
           .setSize(100,20)
           .setRange(0,255)
           .setValue(0)
           .setCaptionLabel("RED")
           ;
           
        cp5.addSlider("slider2")
           .setPosition(275,400)
           .setSize(100,20)
           .setRange(0,255)
           .setValue(193)
           .setCaptionLabel("SATURATION")
           ;
         
        cp5.addSlider("slider3")
           .setPosition(475,400)
           .setSize(100,20)
           .setRange(0,255)
           .setValue(255)
           .setCaptionLabel("BRIGHTNESS")
           ;
           
        cp5.addSlider("circleExpand")
           .setPosition(75,430)
           .setSize(100,20)
           .setRange(-50,300)
           .setValue(circleExpand)
           .setCaptionLabel("RADIUS")
           ;
           
        cp5.addSlider("circleWidth")
           .setPosition(275,430)
           .setSize(100,20)
           .setRange(1,15)
           .setValue(circleWidth)
           .setCaptionLabel("THICKNESS")
           ;
           
        cp5.addSlider("threshold")
           .setPosition(475,430)
           .setSize(100,20)
           .setRange(1,250)
           .setValue(threshold)
           .setCaptionLabel("THRESHOLD")
           ;
                      
        labelDebugText = cp5.addTextlabel("debug info")
          .setText(debugText)
          .setPosition(10,465)
          .setColorValue(0xffffffff)
          ;
        
        
        labelFIRE = cp5.addTextlabel("FIRE")
          .setText("")
          .setPosition(305,20)
          .setColorValue(0xffffffff)
          ;
        
       //delay(5000);                    
}


void  draw() 
{
  background(0);
  if (cam.available() == true) 
  { 
    cam.read();  
    img = cam.get(); 

    opencv.copy(img);
    image(img,0,0); 
    //background(img);
    //tint(slider1, slider2, slider3);
    //image(img,0,0); 
    //blend(img, 0, 0, widthCapture, heightCapture, 0, 0, widthCapture, heightCapture, OVERLAY);
    faceRect = opencv.detect(3,false);
  }
  
  if((faceRect != null) && (faceRect.length != 0))
  {
    //Targeting Lines
    targetCenterX = faceRect[0].x + (faceRect[0].width/2);
    targetCenterY = faceRect[0].y + (faceRect[0].height/2);    
    stroke(255,255,255,128);
    strokeWeight(1);
    
    //Horizontal and Vertical Lines
    line(targetCenterX, 0, targetCenterX, height);
    line(0, targetCenterY, width, targetCenterY);
    
    //draw fire threshold area for width
    thresholdLeft = (widthCapture/2)-threshold;
    thresholdRight =  (widthCapture/2)+threshold;
    
    line(thresholdLeft, 0, thresholdLeft, heightCapture); //left line
    line(thresholdRight, 0, thresholdRight, heightCapture); //right line
    
    //Circle
    noFill();
    strokeWeight(circleWidth);
    ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand, faceRect[0].height+circleExpand);
    
    //Targeting Circle
    strokeWeight(1);
    ellipse(targetCenterX+2, targetCenterY+2, 5, 5);
    //Map targetCenterX to angle using //map(value, low1, high1, low2, high2)
    float value = targetCenterX;
    float mappedValue = map(value, 0, width, 70, 110);
    spos = round(mappedValue);
    strokeWeight(1);
    
    line(targetCenterX, targetCenterY, 0, 0);
    
    //Fire
    if((targetCenterX >= thresholdLeft) && (targetCenterX <= thresholdRight))
    {
      labelFIRE.setText("FIRE!");
    }
    else
    {
      labelFIRE.setText("TARGET OUT OF RANGE");
    }
   
  }
  else
  {
    //No person found text
    fill(0);
    textAlign(CENTER);
    textFont(font, 24);
    text("SEARCHING FOR TARGET...", (width/2)+1, (height/2)+1);
   
    fill(255);
    textAlign(CENTER);
    textFont(font, 24);
    text("SEARCHING FOR TARGET...", width/2, height/2);  
    labelFIRE.setText("");
  }
  
  //Turret pan positioning
   port.write("s"+spos);
   println("s"+spos);
   debugText = "Angle: " + spos + "   targetCenterX: " + targetCenterX + "   frame rate: " + int(frameRate); 
   labelDebugText.setText(debugText);
   delay(40);
   //background(0);
   
}

void mousePressed()
{
  /*if(mouseY < 375)
  {
    showUI = !showUI;
  }
  if(showUI)
  {
    cp5.hide();
  }
  else
  {
    cp5.show();
  }*/
}

public void stop()
{
  super.stop();
}
