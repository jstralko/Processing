/*  Ambi2: AmbientNeoPixel Processing Sketch
 **  Created by: Cory Malantonio
 **  ambiArray is based on a design by Rajarshi Roy
 */
import cc.arduino.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.Dimension;
import processing.serial.*;


//-------Set Resolution Here-----//
int resX = 1920;
int resY = 1080;
//-------------------------------//

int sectW = resX / 11;  //Section Width for the 10 sections
int SectRx = sectW / 4; //Section resolution for x
int SectRy = resY / 4;  //Section resolution for y

Serial port;
Robot GrabRGBval;

void setup()
{
  port = new Serial(this, Serial.list()[2], 9600);
  //Serial.list()[#], # = usb device number

  try
  {
    GrabRGBval = new Robot();
  }
  catch (AWTException e)
  {
    println("Robot class not supported by your system!");
    exit();
  }

  size(200, 200);
  background(0);
  noFill();
}

void draw()
{
  int pixel;

  float[] rA = new float[11];
  float[] gA = new float[11];
  float[] bA = new float[11];
  int[] reso = new int[11];

  for (int Ar = 1; Ar < 11; Ar++) {  //load the resolutions into the array
    reso[Ar] = sectW * Ar;              //192 is 1/10th of the 1920 resolution
  }

  float r=0;
  float g=0;
  float b=0;
  reso[0]=0;

  BufferedImage screenshot = GrabRGBval.createScreenCapture(new Rectangle(new Dimension(resX, resY)));

  for (int LED = 1; LED < 11; LED++) {
    int x=0;
    int y=0;

    //reso array increments in 10ths of the 1920 resolution, starting at 0
    for ( x = reso[LED-1]; x < reso[LED]; x = x + 4) {  //"x + 4" is skipping pixels
      for (y = 0; y < resY; y = y + 4) {                 // to help it run faster
        pixel = screenshot.getRGB(x, y);
        r = r+(int)(255&(pixel>>16));
        g = g+(int)(255&(pixel>>8));
        b = b+(int)(255&(pixel));
      }
    }

    r=r/(SectRx*SectRy); //48 is 1/4th each 10th of the screen. Above we are skipping pixels
    g=g/(SectRx*SectRy); //we are left with 1/4th the pixels.
    b=b/(SectRx*SectRy); //270 is 1/4th of the 1080 resolution
    rA[LED] = r;
    gA[LED] = g;
    bA[LED] = b;
  }

  port.write(0xff); //write marker, arduino is looking for this
  for (int Br = 1; Br < 11; Br++) {
    port.write((byte)(rA[Br]));
    port.write((byte)(gA[Br]));
    port.write((byte)(bA[Br]));
  }

  delay(10); //delay for safety

  for (int cOne = 1; cOne < 11; cOne++) {  
    fill(0);
    stroke(rA[cOne], gA[cOne], bA[cOne]);
    rect((cOne - 1)*20, 0, cOne*20, 200);
    fill(rA[cOne], gA[cOne], bA[cOne]);
    rect((cOne - 1)*20, 0, cOne*20, 200);
  }
}

