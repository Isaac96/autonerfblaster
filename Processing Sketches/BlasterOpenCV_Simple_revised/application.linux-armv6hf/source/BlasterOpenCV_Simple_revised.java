import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import processing.video.*; 
import java.awt.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BlasterOpenCV_Simple_revised extends PApplet {





//import codeanticode.gsvideo.*; 
//import monclubelec.javacvPro.*; 
 


PImage img;
Rectangle[] faceRect; 

//GSCapture cam; 
Capture cam;
OpenCV opencv; 

int widthCapture=640; 
int heightCapture=480;
int fpsCapture=30; 
int spos=90;

int targetCenterX;
int targetCenterY;

int threshold = 20;
int thresholdLeft;
int thresholdRight;
int moveIncrement = 2;
Serial port;

int circleExpand = 20;
int circleWidth = 3;

boolean isFiring = false;
boolean isFound = false;

public void setup()
{ 
   
  frameRate(fpsCapture); 
  background(0);
  
  cam = new Capture(this, widthCapture, heightCapture);
  //cam = new GSCapture(this, widthCapture, heightCapture, "0"); 
  cam.start(); 
  
  opencv = new OpenCV(this, widthCapture, heightCapture); 
  //opencv.allocate(widthCapture, heightCapture); 
  
  //Comment or delete the platform you're NOT on.
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);    //Windows location
  //opencv.cascade("/usr/local/share/OpenCV/haarcascades/","haarcascade_frontalface_alt.xml");    //Mac location
  
  println(Serial.list()); 
  port = new Serial(this, Serial.list()[0], 57600); 
  port.write("c"); 
  delay(1000);                    
}

public void  draw() 
{
  if (cam.available() == true) 
  { 
    cam.read();  
    img = cam.get(); 

    opencv.loadImage(img);
     
    if(isFiring) 
    {
      tint(255, 0, 0);
    }
    else
    {
      noTint();
    }
    image(img,0,0);
    blend(img, 0, 0, widthCapture, heightCapture, 0, 0, widthCapture, heightCapture,HARD_LIGHT);
    faceRect = opencv.detect();
  }
  
  stroke(255,255,255);
    strokeWeight(1);
    thresholdLeft = (widthCapture/2)-threshold;
    thresholdRight =  (widthCapture/2)+threshold;
    
    stroke(255,255,255, 128);
    strokeWeight(1);
    line(thresholdLeft, 0, thresholdLeft, heightCapture); //left line
    line(thresholdRight, 0, thresholdRight, heightCapture); //right line
  
  if((faceRect != null) && (faceRect.length != 0))
  {
    isFound = true;
    //Get center point of identified target
    targetCenterX = faceRect[0].x + (faceRect[0].width/2);
    targetCenterY = faceRect[0].y + (faceRect[0].height/2);    
        
    //Draw circle around face
    noFill();
    strokeWeight(circleWidth);
    stroke(255,255,255);
    ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand, faceRect[0].height+circleExpand);
    
    //Handle rotation
    if(targetCenterX < thresholdLeft)
    {
        port.write("-");
        delay(70);
    }
    if(targetCenterX > thresholdRight)
    {
        port.write("+");
        delay(70);
    }
    
    //Fire
    if((targetCenterX >= thresholdLeft) && (targetCenterX <= thresholdRight))
    {
      port.write("f");
      isFiring = true;
      noFill();
      strokeWeight(2);
      stroke(255,255,255, 128);
      ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand+15, faceRect[0].height+circleExpand+ 15);
    }
    else
    {
      isFiring = false;
    }
  }
  
 delay(40);  
}
  public void settings() {  size (640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BlasterOpenCV_Simple_revised" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
