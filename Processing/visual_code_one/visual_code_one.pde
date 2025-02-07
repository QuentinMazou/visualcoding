color WHITE, BLACK, YELLOW;

float xDelta, yDelta;

float ratio = 0.7;
float stepAngle = PI / 4; 
int maxIterations = 10; 


void setup()
{
  //size screen
  size(900,720);
  
  //fps
  frameRate(24);
  rectMode(CENTER);
  colorMode(RGB,1.);
  
  WHITE = color(1.);
  BLACK = color(0.);
  YELLOW = color(255, 204, 0);
  
}


void draw()
{
  if(frameCount<=60)
  {
    background(BLACK);
    xDelta = width / 60.;
    rect(width/2,height/2, xDelta * frameCount,height);
    fill(WHITE);
  }
  else if(frameCount <= 90)
  {
    background(BLACK);
    xDelta = width / 30.;
    rect(width/2,height/2, xDelta * (frameCount-60),height);
    fill(WHITE);
  }
  else
  {
    background(WHITE);


    stroke(0);
    drawTree(width / 2, height, height / 4, 0, 0);
  }
}              


void drawTree(float x, float y, float len, float angle, int iteration) {
  if (iteration == 0) {
    float y1 = y - len;
    line(x, y, x, y1);
    drawTree(x, y1, len * ratio, 0, 1);
  } else if (iteration <= maxIterations) {
    float x1 = x - len * sin(angle + stepAngle);
    float y1 = y - len * cos(angle + stepAngle);
    line(x, y, x1, y1);
    drawTree(x1, y1, len * ratio, angle + stepAngle, iteration + 1);

    float x2 = x - len * sin(angle - stepAngle);
    float y2 = y - len * cos(angle - stepAngle);
    line(x, y, x2, y2);
    drawTree(x2, y2, len * ratio, angle - stepAngle, iteration + 1);
  }
}
