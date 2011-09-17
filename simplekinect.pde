import peasy.*;
import shiffman.kinect.*;
import superCAD.*;

boolean record = false;

/*
 Simple Kinect point-cloud demo v. 0.2
 
 Henry Palonen <h@yty.net>
  
 Using Daniel Shiffman's great processing-library for Kinect:
 http://www.google.com/url?sa=D&q=http://www.shiffman.net/2010/11/14/kinect-and-processing/&usg=AFQjCNH8kZWDMhFueeNBn5x97XoDR3v9oQ
 
 Based on Kyle McDonalds Structure Light scanner:
 http://www.openprocessing.org/visuals/?visualID=1014

 Using also SuperCAD for outputting the .obj - files: http://labelle.spacekit.ca/supercad/
 
 History
 -------
 17.11.2010 - 0.1 - First version, simple point-cloud working
 18.11.2010 - 0.2 - Output to .obj for importing to Blender, gray-color for distance and small lines as output

*/
float zscale = 3;
float zskew = 10;

int inputWidth = 640;
int inputHeight = 480;

PeasyCam cam;

float[][] gray = new float[inputHeight][inputWidth];

PImage depth;

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);  
} 

void setup() {
  size(inputWidth, inputHeight, P3D);
  cam = new PeasyCam(this, width);
  NativeKinect.init();
  depth = createImage(640,480,RGB);
  stroke(255);
}

void draw () {
  background(0);
  
  if (record == true) {
    beginRaw("superCAD.ObjFile", "kinec_out.obj"); // Start recording to the file
  }
  
  depth.pixels = NativeKinect.getDepthMap();
  depth.updatePixels();

  NativeKinect.update();
  
  for (int y = 0; y < inputHeight; y++) {
    for (int x = 0; x < inputWidth; x++) {
       // FIXME: this loses Z-resolution about tenfold ...
       //       -> should grab the real distance instead...
       color argb = depth.pixels[y*width+x];
       gray[y][x] = gray(argb);
    }
  }
  
  // Kyle McDonald's original source used here
  translate(-inputWidth / 2, -inputHeight / 2);  
  int step = 2;
  for (int y = step; y < inputHeight; y += step) {
    float planephase = 0.5 - (y - (inputHeight / 2)) / zskew;
    for (int x = step; x < inputWidth; x += step)
    {
        stroke(gray[y][x]);
        //point(x, y, (gray[y][x] - planephase) * zscale);
        line(x, y, (gray[y][x] - planephase) * zscale, x+1, y, (gray[y][x] - planephase) * zscale);

    }
  }
  
  if (record == true) {
    endRaw();
    record = false; // Stop recording to the file
  }
  
}

void keyPressed() {
  if (key == 'R' || key == 'r') { // Press R to save the file
    record = true;
  }
}

