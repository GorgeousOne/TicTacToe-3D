import java.util.Arrays;

//Enum mit allen Teams, zu denen ein Würfel gehören kann
public enum Team {
  
  Red(singelton.new Color(26, 255, 255)),
  Blue(singelton.new Color(127, 255, 255)),
  Unoccupied(singelton.new Color(255));

  private Color fill;
  
  private Team(Color c) {
    this.fill = c;
  }
  
  //gibt die Farbe zurück, die das Team hat
  public Color getColor() {
    return fill.clone();
  }
}

//Würfel aus 6 Einzelflächen(Quad3d)
public class Cube implements Displayable {
  
  private PVector pos;
  private ArrayList<Quad3d> faces;
  private ArrayList<Connection> connections;
  
  private Team team;
  private Color fill, stroke;
  
  private boolean isVisible;
  
  public Cube (float size) {
    this(size, size, size); 
  }
  
  public Cube(float length, float height, float depth) {
    pos = new PVector(0, 0, 0);
    
    PVector lowerLeftVertice  = new PVector(-length/2, -height/2, -depth/2);
    PVector upperRightVertice = new PVector( length/2,  height/2,  depth/2);
    PVector edgeA = new PVector(length, 0, 0),
            edgeB = new PVector(0, height, 0),
            edgeC = new PVector(0, 0, depth);
    
    Quad3d bottom = new Quad3d(lowerLeftVertice, edgeA, edgeC);
    Quad3d front  = new Quad3d(lowerLeftVertice, edgeB, edgeA);
    Quad3d left   = new Quad3d(lowerLeftVertice, edgeC, edgeB);

    Quad3d top   = new Quad3d(upperRightVertice, edgeC.copy().mult(-1), edgeA.copy().mult(-1));
    Quad3d back  = new Quad3d(upperRightVertice, edgeA.copy().mult(-1), edgeB.copy().mult(-1));
    Quad3d right = new Quad3d(upperRightVertice, edgeB.copy().mult(-1), edgeC.copy().mult(-1));
   
    faces = new ArrayList<Quad3d>(Arrays.asList(bottom, front, left, top, back, right));
    setTeam(Team.Unoccupied);
    setStroke(new Color(0));
    connections = new ArrayList<Connection>();
    
    isVisible = true;
  }

  //Aufbau entspricht größtenteils der des Quad3d
  //getter
  public PVector getPos() {
    return pos.copy();
  }
  public PVector getMid() {
    return faces.get(3).getOrigin().add(faces.get(0).getOrigin()).mult(0.5f);
  }
  
  public Team getTeam() {
    return team;
  }
  public Color getFill() {
    return fill;
  }
  public Color getStroke() {
    return stroke;
  }
  
  //gibt alle Verbindungen zurück, in denen sich der Würfel befindet
  public ArrayList<Connection> getConnections() {
    return connections;  
  }
  
  public void setPos(PVector point) {
    pos.set(point.x, point.y, point.z);
    for(Quad3d face : faces)
      face.setPos(point);
  }
  
  public void setTeam(Team t) {
    team = t;
    setFill(team.getColor());
  }
  
  //setzt die Farbe, in der der Würfel dagestellt werden soll
  public void setFill(Color c) {
    fill = c;
    for(Quad3d face : faces)
      face.setFill(c);
  }
  public void setStroke(Color c) {
    stroke = c;
    for(Quad3d face : faces)
      face.setStroke(c);
  }
  
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  //informiert den Würfel über eine weitere Verbindung, in der der Würfel liegt
  public void addConnection(Connection c) {
    connections.add(c);  
  }
  //entfernt alle Informationen über Verbindungen des Würfels (zum Neustart)
  public void removeAllConnections() {
    for(Connection c : connections)
      removeComponent3d(c);
    connections.clear();
  }
  
  public boolean intersects(Line l) {
    return getIntersection(l) == null? false : true;
  }
  
  public PVector getIntersection(Line l) {
    for(Quad3d face : faces)
      if(face.intersects(l))
        return face.getIntersection(l);
    return null;
  }
  
  @Override
  public void display() {
    if(!isVisible)
      return;

    checkFaceVisiblity();
    
    for(Quad3d face : faces)
      face.display();
  }
  
  //reguliert die Sichtbarkeit der Seitenflächen, je nachdem, ob sie für die Kamera sichtbar sind
  //nennt man das depth-sort?
  private void checkFaceVisiblity() {
    PVector camPos = getCamPos();
    
    for(Quad3d face : faces) {
      
      PVector facing = face.getNormal();
      PVector dir = face.getMid().sub(camPos);   
      float angle = acos(dir.dot(facing) / (dir.mag() * facing.mag()));
      
      face.setVisible(abs(angle) > HALF_PI);  //mit dieser Methode wird min 50% Zeit/Berechnungen gespart
    }
  }
}