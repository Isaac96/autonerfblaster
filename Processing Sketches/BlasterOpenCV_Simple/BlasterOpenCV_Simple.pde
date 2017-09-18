import codeanticode.gsvideo.*; 
import monclubelec.javacvPro.*; 
import java.awt.*; 
import processing.serial.*;

PImage img;
Rectangle[] faceRect; 

GSCapture cam; 
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

void setup()
{ 
  size (widthCapture, heightCapture); 
  frameRate(fpsCapture); 
  background(0);
  
  //cam = new Capture(this, cameras[19]);
  cam = new GSCapture(this, widthCapture, heightCapture, "0"); 
  cam.start(); 
  
  opencv = new OpenCV(this); 
  opencv.allocate(widthCapture, heightCapture); 
  
  //Comment or delete the platform you're NOT on.
  //opencv.cascade("FRONTALFACE_ALT", true);    //Windows location
  opencv.cascade("/usr/local/share/OpenCV/haarcascades/","haarcascade_frontalface_alt.xml");    //Mac location
  
  println(Serial.list()); 
  port = new Serial(this, Serial.list()[0], 57600); 
  port.write(90 + "a"); 
  delay(1000);                    
}

void  draw() 
{
  if (cam.available() == true) 
  { 
    cam.read();  
    img = cam.get(); 

    opencv.copy(img);
     
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
    faceRect = opencv.detect(3,false);
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
        spos = spos-moveIncrement;
        delay(70);
    }
    if(targetCenterX > thresholdRight)
    {
        spos = spos+moveIncrement;
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
  
 port.write(spos + "a");
 delay(40);  
}
