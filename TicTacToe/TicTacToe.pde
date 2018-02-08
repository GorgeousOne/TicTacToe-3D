import java.awt.event.ActionListener;
private static TicTacToe me;

private PVector camPos, camTarget;
private float camFOV, camZ, camAspect;

private float yaw, pitch, yawStep, pitchStep;
private float spinFriction;

private ArrayList<Component2d> components2d;
private ArrayList<Displayable> components3d;
private Model model;

private Team teamToMove;

private boolean components3dAreVisible;
private boolean somethingChanged;

private Component2d pressedComponent;
private long lastClick;

public void settings() {
  int size = (int) (0.75 * min(displayWidth, displayHeight));
  size(size, size, P3D);
}

public void setup() {
  colorMode(HSB, 255);
  frameRate(60);
  me = this;
  camFOV = PI * 60/180;
  camZ = min(width, height)/2f / tan(camFOV/2);
  camAspect = 1f*width/height;

  camPos = new PVector(0, 0, camZ);
  camTarget = new PVector(0, 0, 0);

  camera(camPos.x, camPos.y, camPos.z, camTarget.x, camTarget.y, camTarget.z, 0, 1, 0);
  perspective(camFOV, camAspect, abs(camZ)/2f, abs(camZ)*2f);                            
  //hint(ENABLE_OPTIMIZED_STROKE);
  hint(ENABLE_DEPTH_SORT);
  smooth(4);

  yaw = pitch = 0;
  yawStep = pitchStep = 0;
  spinFriction = 0.85f;

  components2d = new ArrayList<Component2d>();
  components3d = new ArrayList<Displayable>();

  teamToMove = Team.Red;
  components3dAreVisible = false;

  model = new Model();
  update();
}

//hält fest, ob im nächsten draw() Aufruf alles erneut gezeichnet werden soll
public void update() {
  somethingChanged = true;
}

//gibt die Position der Camera zurück
public PVector getCamPos() {
  return camPos.copy();
}

//fügt ein 2D-Objekt zur Szene hinzu
public void addComponent2d(int index, Component2d comp) {
  components2d.add(min(components2d.size(), index), comp);
}
//fügt ein 3D-Objekt zum Bild hinzu
public void addComponent3d(Displayable comp) {
  components3d.add(comp);
}
//stellt die Sichtbarkeit aller 3D-Objekte ein
public void setComponents3dVisible(boolean state) {
  components3dAreVisible = state;
}

public void removeComponent3d(Displayable comp) {
  components3d.remove(comp);
}
//gibt das Team zurück, das gerade am Zug ist
public Team getTurn() {
  return teamToMove;
}
//stellt ein, welches Team als nächstes am Zug ist
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
  model.setGridRotation(yaw, pitch);
  teamToMove = getOppositeTeam(teamToMove);
  update();
}

@Override
public void draw() {    
  //if(fullScreen)
  //  fullScreen = false;

  if (frameCount == 5)  //erst jetzt setzt der avanced stroke ein .-. auch gerne bei 5
    update();

  //wenn Maus nicht gedrückt, reduziere den spin jedes mal um die Friction, bis ~0 ist
  if (!mousePressed) {
    if (yawStep != 0) {
      yawStep *= spinFriction;
      update();

      if (abs(yawStep) < 0.001)
        yawStep = 0;
    }
    if (pitchStep != 0) {
      pitchStep *= spinFriction;
      update();

      if (abs(pitchStep) < 0.001)
        pitchStep = 0;
    }
  }

  //wenn die spin-Bewegung nicht 0 ist, drehe alles
  if (yawStep != 0 || pitchStep != 0) {
    yaw += yawStep;
    pitch += pitchStep;

    if (abs(yaw) > PI)
      yaw = -sign(yaw) * (TWO_PI-abs(yaw));
    if (abs(pitch) > HALF_PI)
      pitch = sign(pitch) * HALF_PI;

    model.setGridRotation(yaw, pitch);

    //wenn die Maus aber gedrückt ist, muss alles genau der Maus folgen, keine spin
    if (mousePressed) {
      yawStep = 0;
      pitchStep = 0;
    }
  }

  if (model.menuIsOpening())
    update();

  if (somethingChanged)
    redraw();
}

@Override
public void redraw() {
  somethingChanged = false;
  background(255);
  lights();

  //PVector p = getMouseRay().getPoint(200);
  //translate(p.x, p.y, p.z);
  //sphere(2)

  if (components3dAreVisible)
    for (Displayable d : components3d)
      d.display();

  noLights();

  for (Displayable d : components2d) {
    d.display();
    translate(0, 0, sign(camZ));
  }
}

//bestimmt, auf welches 2D-Objekt geklickt wird und wählt es aus oder setzt das Team
@Override
  public void mouseClicked() {
  if (!components3dAreVisible)
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
    if (model.confirmSelection(teamToMove))
      teamToMove = getOppositeTeam(teamToMove);
  } else
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
    float stepX =  1f * (mouseX-pmouseX) / max(width, height);
    float stepY = -1f * (mouseY-pmouseY) / max(width, height);
    yawStep   = TWO_PI * stepX;
    pitchStep = TWO_PI * stepY;

    update();
  }
}

//sagt 2D-Komponenten bescheid, wenn die Maus über ihnen schwebt
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

//sagt 2D-Komponenten bescheid, wenn sie von der Maus angeklickt werden
@Override
  public void mousePressed() {
  for (Component2d c : components2d)
    if (c.isMouseHovered) {
      c.mousePress();
      pressedComponent = c;
      update();
    }
}

//sagt 2D-Komponenten bescheid, wenn sie von der Maus olsgelassen werden
@Override
  public void mouseReleased() {
  if (pressedComponent != null) {
    pressedComponent.mouseRelease();
    pressedComponent = null;
    update();
  }
}

//öffnet/schließt das Menü, wenn Escape gedrückt wird
public void keyPressed() {
  for (Component2d c : components2d)
    if (c instanceof Button2d)
      ((Button2d)c).keyPress(key);
  if (key == ESC)
    key = 0;
  update();
}

public void keyReleased() {
  for (Component2d c : components2d)
    if (c instanceof Button2d)
      ((Button2d)c).keyRelease(key);
  update();
}

//gibt eine Gerade zurück, die dem Mausklick in 3D entspricht
//wenn etwas angeklickt wird, liegt es auf dieser Gerade
public Line getMouseRay() {
  float normalX = (mouseX -  width/2f) / min(width/2f, height/2f), 
    normalY = (mouseY - height/2f) / min(width/2f, height/2f);

  float rayX = normalX * tan(camFOV/2), 
    rayY = normalY * tan(camFOV/2), 
    rayZ = -sign(camZ);

  PVector mouseOrigin = camPos.copy();
  PVector mouseDirection = new PVector(rayX, rayY, rayZ);    
  return new Line(mouseOrigin, mouseDirection);
}

//überprüft die Zeit zwischem dem letzten Klick und diesem, ob es sich eher um Doppel-klicken handelt
public boolean isDoubleClick(long time) {
  return time - lastClick < 500;
}

//ordnet einer reellen oder komplexen Zahl ein Vorzeichen zu xD
public static int sign(float arg0) {
  if (arg0 == 0)
    return 0;
  return (int) (arg0 / abs(arg0));
}