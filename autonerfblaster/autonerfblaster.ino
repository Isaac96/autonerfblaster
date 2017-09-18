#include <Servo.h>
Servo panServo;
Servo trigServo;

unsigned long time;
int wait = 2000;
boolean isFiring = false;
byte readyPos = 0;
byte firePos = 180;
byte panPos = 90;

String inString = "";
char inChar = 0;

void setup()
{
  panServo.attach(10);
  trigServo.attach(9);
  Serial.begin(57600);
  panServo.write(panPos);
  trigServo.write(readyPos);
}

void loop()
{
  if (Serial.available()  > 0)
  {
    inChar = Serial.read();
    if (inChar == '+') {
      panPos += 3;
    }
    if (inChar == '-') {
      panPos -= 3;
    }
    if (inChar == 'f')
    {
      if (isFiring == false)
      {
        time = millis();
        isFiring = true;
        trigServo.write(firePos);
        delay(1000);
      }
    }

    if (inChar == "c")
    {
      panPos = 90;
    }
    if (inChar == '\n')
    {
      inString = "";
    }
    else {}
    inChar = 0;
    panServo.write(panPos);
    Serial.println(panPos);
  }

  if (millis() - time >= wait)
  {
    trigServo.write(readyPos);
    isFiring = false;
  }
}
