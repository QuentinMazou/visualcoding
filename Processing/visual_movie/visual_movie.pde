// Fusion des scènes avec transitions variées et arbre interactif

Universe universe;
FractalTree tree;

int scene = 0;
int sceneDuration = 5000; // Durée réduite pour la première scène
int transitionDuration = 2000; // Durée de transition
int lastSwitch;

boolean transitioning = false;
float transitionProgress = 0;
PGraphics currentScene, nextScene;

void setup() {
  fullScreen();
  colorMode(HSB, 1.);

  currentScene = createGraphics(width, height);
  nextScene = createGraphics(width, height);

  universe = new Universe(200);
  tree = new FractalTree();

  lastSwitch = millis();
}

void draw() {
  int now = millis();

  if (!transitioning && now - lastSwitch > sceneDuration) {
    transitioning = true;
    transitionProgress = 0;
    lastSwitch = now;
  }

  if (transitioning) {
    transitionProgress = float(now - lastSwitch) / float(transitionDuration);
    if (transitionProgress >= 1.0) {
      transitioning = false;
      scene = (scene + 1) % 5;
      transitionProgress = 0;
    } else {
      renderScene(scene, currentScene);
      renderScene((scene + 1) % 5, nextScene);
      drawCustomTransition(currentScene, nextScene, transitionProgress);
      return;
    }
  }

  renderScene(scene, currentScene);
  image(currentScene, 0, 0);
}

// === Transitions variées ===
void drawCustomTransition(PGraphics from, PGraphics to, float progress) {
  PImage img1 = from.get();
  PImage img2 = to.get();
  PImage result = createImage(width, height, RGB);
  img1.loadPixels();
  img2.loadPixels();
  result.loadPixels();

  for (int i = 0; i < result.pixels.length; i++) {
    float factor = (sin(progress * PI) + 1) / 2.0; // transition ondulée
    color c1 = img1.pixels[i];
    color c2 = img2.pixels[i];
    float r = lerp(red(c1), red(c2), factor);
    float g = lerp(green(c1), green(c2), factor);
    float b = lerp(blue(c1), blue(c2), factor);
    result.pixels[i] = color(r, g, b);
  }
  result.updatePixels();
  image(result, 0, 0);
}

void renderScene(int sceneIndex, PGraphics pg) {
  pg.beginDraw();
  pg.colorMode(HSB, 1.);
  pg.background(0);
  switch (sceneIndex) {
    case 0:
      drawGrowingRect(pg);
      break;
    case 1:
      drawPerlinTexture(pg);
      break;
    case 2:
      drawStarburst(pg);
      break;
    case 3:
      universe.display(pg);
      break;
    case 4:
      tree.display(pg);
      break;
  }
  pg.endDraw();
}

// === SCENE 0 : RECTANGLE ===
void drawGrowingRect(PGraphics pg) {
  float elapsed = millis() % 2000;
  pg.rectMode(CENTER);
  pg.colorMode(RGB, 1.);
  pg.background(0);
  pg.fill(1);
  float xDelta = width / 60.0;
  pg.rect(width/2, height/2, xDelta * (elapsed / 50.0), height);
}

// === SCENE 1 : PERLIN TEXTURE ===
void drawPerlinTexture(PGraphics pg) {
  float scale = .003;
  float h;
  float t = millis() * 0.0001;
  int sizer = 5;
  pg.noStroke();
  for (int i = 0; i < width; i += sizer) {
    for (int j = 0; j < height; j += sizer) {
      h = noise(t + i * scale, t + j * scale);
      pg.fill(h, .7, .8);
      pg.rect(i, j, sizer, sizer);
    }
  }
}

// === SCENE 2 : STARBURST ===
void drawStarburst(PGraphics pg) {
  pg.background(1.);
  pg.stroke(0.);
  pg.strokeWeight(2);
  pg.translate(width/2, height/2);
  float limit = height * 0.4;
  for (int i = 0; i < 360; i++) {
    int d = constrain(abs(int(randomGaussian() * limit)), 0, int(limit));
    pg.rotate(TWO_PI / 360.);
    pg.line(0, 0, d, 0);
  }
}

// === SCENE 3 : ATOMES CONNECTÉS ===
class Atom {
  float x, y, d;
  color c;
  float xper, yper;
  float speed = 0.001;

  Atom() {
    initialise();
  }

  void initialise() {
    xper = random(width);
    yper = random(height);
    d = 6.;
    c = color(.8);
  }

  void update() {
    x = map(noise(xper), 0, 1, -200, width + 200);
    y = map(noise(yper), 0, 1, -200, height + 200);
    xper += speed;
    yper += speed;
  }

  void display(PGraphics pg) {
    pg.fill(c);
    pg.noStroke();
    pg.circle(x, y, d);
  }
}

class Universe {
  Atom[] cluster;
  float proximity = 100;
  color c = color(.5, 1., .8);

  Universe(int count) {
    cluster = new Atom[count];
    for (int i = 0; i < count; i++) {
      cluster[i] = new Atom();
    }
  }

  void display(PGraphics pg) {
    for (Atom a : cluster) {
      a.update();
      a.display(pg);
      for (Atom b : cluster) {
        if (a != b && dist(a.x, a.y, b.x, b.y) < proximity) {
          pg.stroke(c);
          pg.strokeWeight(0.3);
          pg.line(a.x, a.y, b.x, b.y);
        }
      }
    }
  }
}

// === SCENE 4 : FRACTAL TREE INTERACTIF ===
class FractalTree {
  float ratio = 0.7;
  int maxIterations = 10;

  void display(PGraphics pg) {
    pg.background(1.);
    float stepAngle = (mouseX / (float)width) * (PI / 2.0);
    maxIterations = (int)(mouseY / (float)(height / 11)) + 1;
    pg.stroke(0);
    drawTree(pg, width / 2, height, height / 4.0, 0, 0, stepAngle);
  }

  void drawTree(PGraphics pg, float x, float y, float len, float angle, int iteration, float stepAngle) {
    if (iteration == 0) {
      float y1 = y - len;
      pg.line(x, y, x, y1);
      drawTree(pg, x, y1, len * ratio, 0, 1, stepAngle);
    } else if (iteration <= maxIterations) {
      float x1 = x - len * sin(angle + stepAngle);
      float y1 = y - len * cos(angle + stepAngle);
      pg.line(x, y, x1, y1);
      drawTree(pg, x1, y1, len * ratio, angle + stepAngle, iteration + 1, stepAngle);

      float x2 = x - len * sin(angle - stepAngle);
      float y2 = y - len * cos(angle - stepAngle);
      pg.line(x, y, x2, y2);
      drawTree(pg, x2, y2, len * ratio, angle - stepAngle, iteration + 1, stepAngle);
    }
  }
}
