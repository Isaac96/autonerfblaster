import processing.io.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*; 

PImage img;
Rectangle[] faceRect; 

Capture cam;
OpenCV opencv; 
SoftwareServo panServo;
SoftwareServo trigServo;

int widthCapture=320; 
int heightCapture=240;
int fpsCapture=30; 
int panpos=90;
int firePos = 80;
int readyPos = 0;
long time;
int wait = 500;

int targetCenterX;
int targetCenterY;

int threshold = 20;
int thresholdLeft;
int thresholdRight;
int moveIncrement = 2;


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
  panServo = new SoftwareServo(this);
  trigServo = new SoftwareServo(this);
  panServo.attach(17);
  trigServo.attach(4);

  cam = new Capture(this, widthCapture, heightCapture);
  cam.start(); 

  opencv = new OpenCV(this, widthCapture, heightCapture); 
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
}

void  draw() 
{
  if (millis() - time >= wait)
  {
    trigServo.write(readyPos);
    isFiring = false;
  }
  if (isFiring) 
  {
    trigServo.write(firePos);
    tint(255, 0, 0);
  } else
  {
    trigServo.write(readyPos);
    noTint();
  }
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

  if ((faceRect != null) && (faceRect.length != 0))
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
    if (!manual) {
      //Handle rotation
      if (targetCenterX < thresholdLeft)
      {
        panpos -=  moveIncrement;
        //delay(70);
      }
      if (targetCenterX > thresholdRight)
      {
        panpos+=  moveIncrement;
        //delay(70);
      }

      //Fire
      if ((targetCenterX >= thresholdLeft) && (targetCenterX <= thresholdRight))
      {
        isFiring = true;
        println("Gotem");
        noFill();
      }
    }
  }
}
void keyPressed() {
  if (key == 'm') {
    manual = !manual;
    println("manual mode toggled");
    isFiring = false;
  } else if (key == 'a' && manual) {
    panpos-= moveIncrement;
    println("left");
  } else if (key == 'f' && manual) {
    isFiring = !isFiring;
  } else if (key == 'd' && manual) {
    panpos+= moveIncrement;
    println("right");
  } else if (key == 'c' )
  {
    panServo.write(90);
  } else {
    println(key);
  }
}