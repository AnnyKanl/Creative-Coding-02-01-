//global variables, feel free to tweak
float size = 100;
float defaultStrokeWeight = 4;
float friction = 0.02;
int initBallCount = 50;
float elascity = 0.98;

//ajustables
float mass = 0.5;
float re = 50;
int tool = 0;


ArrayList<Ball> balls;

void setup()
{
  size(1200,900);
  background(255);
  balls = new ArrayList<Ball>();
  
  
  for (int i = 0; i < initBallCount; i++)
  {
    balls.add(new Ball(new PVector(random(0,width),random(0,height))));
  }
}

void draw()
{
  //display
  background(255);

  color c = color(255,0,0);
  stroke(c,180);
  strokeWeight(1.5*defaultStrokeWeight);
  for (int i = 0; i < balls.size(); i++)
  {
    balls.get(i).next();
  }
  //update force and draw lines
  for (int i = 0; i < balls.size(); i++)
  {
    PVector a = new PVector(0,0);  //initialize accleration
    Ball pi = balls.get(i);
    for (int j = 0; j < balls.size(); j++)
    {
       if (i == j) continue;
       Ball pj = balls.get(j);
       PVector r = pj.center.copy().sub(pi.center);
       float d = r.mag();
       //draw lines if balls are close enough
       if (d < 2.4*size)
       {
         c = mapScalarToRGB(0.5*size,2.4*size,d);
         //stroke(c,255*(1.2*startSize/d-0.5));
         stroke(c,255-map(d,0,2.4*size,0,253));
         line(balls.get(i).center.x,balls.get(i).center.y,balls.get(j).center.x,balls.get(j).center.y);
       }
       if (d < 2*size)    //balls are close enough to repel
       {
         d = 2*size;                    //ensure the gforce is not too large
         balls.get(i).vel.mult(elascity);    //reduce velocity to create 'sticking' effect
         //repel force between particles to create 'bouncing' effect
         float mult2 = -1*re/ ((mass+1)*d);    
         PVector aj2 = r.normalize().mult(mult2);
         a.add(aj2);
       }
       
       float mult = mass / (d);  //magnitude of gforce
       PVector aj = r.normalize().mult(mult);          //force vector
       a.add(aj);
    }
    balls.get(i).acc = a;
  } 
  
  String str1 = "mass: " + mass;
  String str2 = "size: " + size;
  String str3 = "repel: " + re;
  fill(0);
  if (tool == 0) {
    fill(255,0,0);
    text(str1,10,10);
    fill(0);
    text(str2,10,22);
    text(str3,10,34);
  }
  if (tool == 1) {  
    text(str1,10,10);
    fill(255,0,0);
    text(str2,10,22);
    fill(0);
    text(str3,10,34);
  }
  if (tool == 2) {   
    text(str1,10,10);
    text(str2,10,22);
    fill(255,0,0);
    text(str3,10,34);
    fill(0);
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT) {
    PVector cen = new PVector(mouseX,mouseY);
    balls.add(new Ball(cen));
  }
  if (mouseButton == RIGHT) {
    for (int i = balls.size()-1; i >= 0; i--) {
      float d = dist(balls.get(i).center.x,balls.get(i).center.y,mouseX,mouseY);
      if (d < 20) balls.remove(i);
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    tool = (tool+1)%3;
  }
  if (key == 'c') {
    balls.clear();
  }
}

void mouseWheel(MouseEvent event) {
  if (tool == 0) {
    float e = event.getCount();
    mass -= e*0.1;
    if (mass < 0.1) mass = 0.1;
  }
  if (tool == 1) {
    float e = event.getCount();
    size -= e;
    if (size < 2) size = 2;
  }
  if (tool == 2) {
    float e = event.getCount();
    re -= e;
    if (re < -5) re = -5;
  }
}

class Ball
{
  PVector center;
  PVector vel = new PVector(0,0);
  PVector acc = new PVector(0,0);
  
  Ball(PVector cen)
  {
    center = cen;
  }
  Ball setVel(float x, float y) { vel = new PVector(x,y); return this; }
  Ball setAcc(float x,float y) { acc = new PVector(x,y); return this; }
  void next()
  {
    display();
    if(center.x<=0 && vel.x<0) vel.x*=-1;
    if(center.x>=width && vel.x>0) vel.x*=-1;
    if(center.y<=0 && vel.y<0) vel.y*=-1;
    if(center.y>=height && vel.y>0) vel.y*=-1;
    
    vel.add(acc);       
    vel.mult(1-friction); 
    center.add(vel);
  }
  void display()
  {  
    point(center.x,center.y);
  }
}

//utility functions
color mapScalarToRGB(float min, float max, float scalar)
{
  //map size to rgb
    float r = 255,g = 0,b = 0;
    float a = 4*(scalar-min)/(max-min);
    int X = floor(a);
    float Y = 255*(a-X);
    switch (X)
    {
      case 0: r=255;g=Y;b=0;break;
      case 1: r=255-Y;g=255;b=0;break;
      case 2: r=0;g=255;b=Y;break;
      case 3: r=0;g=255-Y;b=255;break;
      case 4: r=0;g=0;b=255;break;
    }
    return color(r,g,b);
}
