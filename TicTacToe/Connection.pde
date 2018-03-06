
//repräsentiert eine Liste mit Würfeln die (vom Model analysiert) in einer Reihe liegen und demselben Team angehören
public class Connection implements Displayable {
  
  private ArrayList<Cube> cubes;
  private PVector direction;
  
  private Team team;
  private Color fill;
  
  private boolean isVisible;
  
  public Connection(Cube c1, Cube c2, PVector direction) {
    cubes = new ArrayList<Cube>();
    cubes.add(c1);
    cubes.add(c2);
    c1.addConnection(this);
    c2.addConnection(this);
    
    team = c1.getTeam();
    this.direction = direction;

    fill = team.getColor();
    isVisible = false;
  }
  
  //gibt die Steigung (zwischen den ersten beiden Würfeln) der Verbindung im Gitter zurück 
  //z.B. (0, 1, 0) oder (-1, -1, -1)
  public PVector getDirection() {
    return direction.copy();
  }
  
  //gibt das Team zurück, aus dem die Würfel der Verbindung stammen
  public Team getTeam() {
    return team;
  }
  
  //gibt alle Würfel in der Verbindung nthalten zurück
  public ArrayList<Cube> getCubes() {
    return cubes;
  }
  
  //git zurück, ob ein bestimmter Würfel teil der Verbindung ist
  public boolean contains(Cube c) {
    return cubes.contains(c);
  }
  
  //gibt die Länge der Verbindung zurück
  public int size() {
    return cubes.size();
  }
  
  //fügt einen weiteren Würfel zur Verbindung hinzu
  //(das Model allein garantiert dafür, dass der Würfel auch wirklich in der Reihe liegt)
  public void addCube(Cube c) {
    cubes.add(c);
    c.addConnection(this);
  }
  
  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  @Override
  public void display() {
    if(!isVisible)
      return;
    
    pushStyle();
    stroke(fill.h(), fill.s(), fill.b());
    strokeWeight(10);
    
    for(int i = 0; i < cubes.size()-1; i++) {
      PVector c = cubes.get(i).getMid();
      PVector c2 = cubes.get(i+1).getMid();
      line(c.x, c.y, c.z, c2.x, c2.y, c2.z);
    }
    
    popStyle();
  }
}