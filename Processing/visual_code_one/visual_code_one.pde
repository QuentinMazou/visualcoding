color WHITE, BLACK, YELLOW;

float xDelta, yDelta;

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
  if(frameCount<60)
  {
    background(WHITE);
    xDelta = width / 60.;
    rect(width/2,height/2, xDelta * frameCount,height);
    fill(BLACK)
  }
}
