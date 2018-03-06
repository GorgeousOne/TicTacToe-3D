
//fast einzige Möglickeit, mit der das Enums Team Objekte der nicht statischen Klasse Color erzeugen kann
private static TicTacToe singelton;

private int pheight, pwidth;
private int originalSize;

private float camFOV, camDist, camAspect;
private float yaw, pitch, yawStep, pitchStep;
private float spinFriction;

private ArrayList<Component2d> components2d;
private ArrayList<Displayable> components3d;
private boolean components3dAreVisible;

private Model model;
private Team teamToMove;

private boolean somethingChanged;

private Component2d pressedComponent;
private long lastClick;

//setzt Fenstergröße auf 75% der kleineren Seitenlänge des Bildschrim
public void settings() {
  originalSize = (int) (0.75 * min(displayWidth, displayHeight));
  size(originalSize, originalSize, P3D);
}

public void setup() {
  singelton = this;
  colorMode(HSB, 255);
  
  pwidth = width;
  pheight = height;
  
  camFOV = PI * 60/180;
  camAspect = 1f*width/height;
  camDist = min(width, height)/2f / tan(camFOV/2);

  camera(0, 0, camDist, 0, 0, 0, 0, 1, 0);
  perspective(camFOV, camAspect, abs(camDist)/10, abs(camDist)*2);                          

  yaw = pitch = 0;
  yawStep = pitchStep = 0;
  spinFriction = 0.95f;

  components2d = new ArrayList<Component2d>();
  components3d = new ArrayList<Displayable>();

  teamToMove = Team.Blue;
  components3dAreVisible = false;

  model = new Model();
  update();
}

//hält fest, ob beim nächsten draw() Aufruf alles erneut redraw()ed werden soll
public void update() {
  somethingChanged = true;
}

//fügt ein 2D-Objekt zur Szene hinzu
public void addComponent2d(int index, Component2d comp) {
  components2d.add(min(components2d.size(), index), comp);
}
//fügt ein 3D-Objekt zum Bild hinzu
public void addComponent3d(Displayable comp) {
  components3d.add(comp);
}
//entfernt 3D-Objekt von der Leinwand
public void removeComponent3d(Displayable comp) {
  components3d.remove(comp);
}
//stellt die Sichtbarkeit aller 3D-Objekte ein
public void setComponents3dVisible(boolean state) {
  components3dAreVisible = state;
}


//gibt das Team zurück, das gerade am Zug ist
public Team getTurn() {
  return teamToMove;
}
//legt fest welches Team als nächstes am Zug ist
public void setTurn(Team t) {
  teamToMove = t;
}
//gibt das gegnerische Team zurück, es gibt ja nur Rot und Blau
private Team getOppositeTeam(Team t) {
  return t == Team.Red ? Team.Blue : Team.Red;
}

//setzt die Werte für Drehung und Drehbewegung zurück
public void resetController() {
  yaw = yawStep = pitch = pitchStep = 0;
  setTurn(getOppositeTeam(teamToMove));
  update();
  }

/*reguliert Perspektive in Abhängigkeit des Fensters wenn nötig
  stoppt Drehbewgungen des Gitters bzw. ja der Szene ab
  startet Leinwand-Update wenn angefordert
*/
@Override
public void draw() {
  if(pheight != height || pwidth != width) {
    camAspect = 1f * width / height;
    camDist = min(width, height)/2f / tan(camFOV/2);

    camera(0, 0, camDist, 0, 0, 0, 0, 1, 0);
    perspective(camFOV, camAspect, abs(camDist)/10, abs(camDist)*2);      
    
    pheight = height;
    pwidth = width;
    update();
  }
  
  if(yawStep != 0 || pitchStep != 0) {
    update();
    yaw += yawStep;
    pitch += pitchStep;

    if(abs(yaw) > PI)
      yaw = -sign(yaw) * (TWO_PI-abs(yaw));
    if(abs(pitch) > HALF_PI)
      pitch = sign(pitch) * HALF_PI;
    
    //wenn die Maus gedrückt ist, darf sich die Szene in nachfolgenden frames nicht weiterdrehen
    if(mousePressed) {
      yawStep = 0;
      pitchStep = 0;
    
    //wenn Maus nicht gedrückt, reduziere den spin nur jedes mal um die friction, bis er ~0 ist
    }else {
      yawStep *= spinFriction;
      pitchStep *= spinFriction;

      if (abs(yawStep) < 0.001)
        yawStep = 0;
      if (abs(pitchStep) < 0.001)
        pitchStep = 0;
    }
  }

  if (model.menuIsOpening())
    update();

  if(somethingChanged)
    redraw();
}

//malt zuerst alle Sichtbaren 2d-Komponenten, bevor das Koordinatensystem gedreht wird
//malt danach alle 3D-Sachen
@Override
public void redraw() {
  somethingChanged = false;
  background(255);
  
  pushMatrix();
  for (Displayable d : components2d) {
    d.display();
    translate(0, 0, 0.1);
  }
  popMatrix();
  
  if (components3dAreVisible) {
    lights();
    rotateX(pitch);
    rotateY(yaw);  
    
    for (Displayable d : components3d)
      d.display();

    //PVector shift = getMouseRay().getPoint(camDist);
    //pushMatrix();
    //translate(shift.x, shift.y, shift.z);
    //sphere(5);
    //popMatrix();
  }
}

//setzt das Team des angeklickten Würfels oder wählt eine angeklickte 2D-Komponente aus
@Override
public void mouseClicked() {
  if(!components3dAreVisible)
    return;

  update();

  if (model.isGameOver())
    return;

  Cube pointingAt = model.getPointingAt(getMouseRay());
  if (pointingAt == null) {
    model.unselect();
    return;
  }

  if (isDoubleClick(millis()) && pointingAt.equals(model.getSelection())) {
    if(model.confirmSelection(teamToMove) && !model.isGameOver())
      setTurn(getOppositeTeam(teamToMove));
  }else
    model.setSelection(pointingAt);

  lastClick = millis();
}

//bestimmt die Drehbewegung wenn die Maus gedrückt und bewegt wird
@Override
  public void mouseDragged(MouseEvent e) {
  for (Component2d c : components2d)
    if (c.contains(mouseX-width/2, mouseY-height/2)) {
      if (!c.isHovered()) {
        c.mouseEnter();
        update();
      }
    } else {
      if (c.isHovered()) {
        c.mouseExit();
        update();
      }
    }

  if (!components3dAreVisible)
    return;

  if (e.getButton() == LEFT) {
    float stepX = 1f * (mouseX-pmouseX) / originalSize;
    float stepY = 1f * (mouseY-pmouseY) / originalSize;
    yawStep   =  PI * stepX;
    pitchStep = -PI * stepY;

    update();
  }
}

//gibt 2D-Komponenten Bescheid, wenn die Maus über ihnen schwebt
@Override
  public void mouseMoved() {
  for (Component2d c : components2d)
    if (c.contains(mouseX-width/2, mouseY-height/2)) {
      if (!c.isMouseHovered) {
        c.mouseEnter();
        update();
      }
    } else {
      if (c.isMouseHovered) {
        c.mouseExit();
        update();
      }
    }
}

//gibt 2D-Komponenten Bescheid, wenn sie von der Maus angeklickt werden
@Override
  public void mousePressed() {
  for (Component2d c : components2d)
    if (c.isMouseHovered) {
      c.mousePress();
      pressedComponent = c;
      update();
    }
}

//gibt 2D-Komponenten Bescheid, wenn sie von der Maus olsgelassen werden
@Override
  public void mouseReleased() {
  if (pressedComponent != null) {
    pressedComponent.mouseRelease();
    pressedComponent = null;
    update();
  }
}

//gibt Knöpfen Bescheid, wenn ihr Shortcut gedrückt wird; verhindert, dass ESC die Anwendung schließt
public void keyPressed() {
  for (Component2d c : components2d)
    if (c instanceof Button2d)
      ((Button2d)c).keyPress(key);
  if (key == ESC)
    key = 0;
  update();
}

//gibt Knöpfen Bescheid, wenn ihr ShortCut losgelassen wird
public void keyReleased() {
  for (Component2d c : components2d)
    if (c instanceof Button2d)
      ((Button2d)c).keyRelease(key);
  update();
}

//gibt die theoretische Position der Kamera zurück, praktisch wird nur die Szene gedreht
public PVector getCamPos() {
  return new PVector(camDist * sin(-yaw) * cos(pitch),
                     camDist * sin(pitch),
                     camDist * cos(-yaw) * cos(pitch));
}

//gibt eine Gerade zurück, die dem Mausklick in 3D entspricht
//wird Etwas auf dem Bildschirm angeklickt, liegt es auf dieser Gerade
public Line getMouseRay() {
  float normalX = (mouseX -  width/2f) / min(width/2f, height/2f), 
        normalY = (mouseY - height/2f) / min(width/2f, height/2f);

  float rayX = normalX * tan(camFOV/2), 
        rayY = normalY * tan(camFOV/2), 
        rayZ = -1;

  PVector rayOrigin = getCamPos();
  PVector rayDir = new PVector(rayX, rayY, rayZ);
  
  //pitch rotation
  float x = rayDir.x,
        y = rayDir.y,
        z = rayDir.z;
  rayDir.set(x,
             z * sin(pitch) + y * cos(pitch),
             z * cos(pitch) - y * sin(pitch));
  
  //yaw rotation
  x = rayDir.x;
  y = rayDir.y;
  z = rayDir.z;
  rayDir.set(x * cos(yaw) - z * sin(yaw),
             y,
             x * sin(yaw) + z * cos(yaw));
  
  return new Line(rayOrigin, rayDir);
}

//überprüft die Zeit zwischem dem letzten Klick und diesem, ob es sich um Doppel-klicken handelt
public boolean isDoubleClick(long time) {
  return time - lastClick < 500;
}

//bestimmt das Vorzeichen einer Zahl
public static int sign(float arg0) {
  if (arg0 == 0)
    return 0;
  return (int) (arg0 / abs(arg0));
}