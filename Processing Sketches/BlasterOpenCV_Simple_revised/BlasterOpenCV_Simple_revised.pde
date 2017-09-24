import gab.opencv.*;
import processing.video.*;
import java.awt.*; 
import processing.serial.*;

PImage img;
Rectangle[] faceRect; 

Capture cam;
OpenCV opencv; 

int widthCapture=320; 
int heightCapture=240;
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
boolean manual = false;

void setup()
{ 
  size (320, 240); 
  frameRate(fpsCapture); 
  background(0);

  cam = new Capture(this, widthCapture, heightCapture);

  cam.start(); 

  opencv = new OpenCV(this, widthCapture, heightCapture); 

  //Comment or delete the platform you're NOT on.
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);    //Windows location


  println(Serial.list()); 
  port = new Serial(this, Serial.list()[2], 57600); 
  println("Serial open");
  port.write("c"); 
  println("Serial open");
  //delay(1000);
  println("Serial open");
}

void  draw() 
{
  if (cam.available() == true) 
  { 
    cam.read();  
    img = cam.get(); 

    opencv.loadImage(img);

    image(img, 0, 0);
    blend(img, 0, 0, widthCapture, heightCapture, 0, 0, widthCapture, heightCapture, HARD_LIGHT);
    faceRect = opencv.detect();
  }

  stroke(255, 255, 255);
  strokeWeight(1);
  thresholdLeft = (widthCapture/2)-threshold;
  thresholdRight =  (widthCapture/2)+threshold;

  stroke(255, 255, 255, 128);
  strokeWeight(1);
  line(thresholdLeft, 0, thresholdLeft, heightCapture); //left line
  line(thresholdRight, 0, thresholdRight, heightCapture); //right line

  if ((faceRect != null) && (faceRect.length != 0) && !manual)
  {
    isFound = true;
    //Get center point of identified target
    targetCenterX = faceRect[0].x + (faceRect[0].width/2);
    targetCenterY = faceRect[0].y + (faceRect[0].height/2);    

    //Draw circle around face
    noFill();
    strokeWeight(circleWidth);
    stroke(255, 255, 255);
    ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand, faceRect[0].height+circleExpand);

    //Handle rotation
    if (targetCenterX < thresholdLeft)
    {
      if (!manual) {
        port.write("+");
        //gdelay(70);
      }
    }
    if (targetCenterX > thresholdRight)
    {
      if (!manual) {
        port.write("-");
        //delay(70);
      }
    }

    //Fire
    if ((targetCenterX >= thresholdLeft) && (targetCenterX <= thresholdRight))
    {
      if (!manual) {
        //port.write("f");
        isFiring = true;
        println("Gotem");
        noFill();
        //strokeWeight(2);
        //stroke(255,255,255, 128);
        //ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand+15, faceRect[0].height+circleExpand+ 15);
      }
    } else
    {
      isFiring = false;
    }
  } 
  if (isFiring) 
  {
    tint(255, 0, 0);
    port.write("f");
  } else
  {
    noTint();
  }
  //delay(40);
}
void keyPressed() {
  if (key == 'm') {
    manual = !manual;
    println("manual mode toggled");
    isFiring = false;
  } else if (key == 'a' && manual) {
    port.write("+");
    println("left");
  } else if (key == 'f' && manual) {
    isFiring = !isFiring;
  } else if (key == 'd' && manual) {
    port.write("-");
    println("right");
  } else {
    println(key);
  }
}