
//erstellt ein 3D-Array mit Würfeln, die das TicTacToe Gitter darstellen
public class Grid implements Displayable {
  
  private Cube[][][] grid;
  private int size;
 
  private boolean isVisible;
 
  /*Konstruktor
    @param Anzahl der Würfel auf einer Kante
    @param Länge der Diagonalen des gesamten Gitterkonstrukts auf xz-Ebene
  */
  public Grid(int size, float diagonalSize) {
    this.size = size;
    grid = new Cube[size][size][size];
    float cubeSize = diagonalSize / (2*size-1) / sqrt(2f);

    isVisible = true;

    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++) {
        
          PVector pos = new PVector(x*2*cubeSize - (size-1) * cubeSize,
                                    y*2*cubeSize - (size-1) * cubeSize,
                                    z*2*cubeSize - (size-1) * cubeSize);
                
          Cube c = new Cube(cubeSize);
          grid[x][y][z] = c;
          c.setPos(pos);
          addComponent3d(c);
        }
  }
  
  //gibt Würfel nach Angabe seiner Nummerierung zurück
  public Cube getCube(int x, int y, int z) {
    if(x<0 || x >= size || 
       y<0 || y >= size ||
       z<0 || z >= size)
      return null;
    return grid[x][y][z];
  }
 
  //gibt die Position als Nummerierung eines Würfels zurück
  public PVector getPos(Cube c) {
    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++)
          if(grid[x][y][z].equals(c))
            return new PVector(x, y, z);
    return null;
  }
  
  //gibt ersten Würfel zurück, der die Gerade schneidet
  public Cube getIntersection(Line ray) {
    Cube intersection = null;
    float minDistance = 0;
    float distance;
    
    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++) {
          
          Cube c = grid[x][y][z];
          
          if(!c.intersects(ray))
            continue;
          
          distance = ray.getOrigin().dist(c.getIntersection(ray));
          if(intersection == null || distance < minDistance) {
            intersection = c;
            minDistance = distance;
          }
        }
    return intersection;
  }
  
  //gibt die max. 26 benachbarten Würfel eines Würfels zurück
  public HashMap<Cube, PVector> getNearbyTeamCubes(PVector pos, Team team) {
    
    HashMap<Cube, PVector> nearbyCubes = new HashMap<Cube, PVector>();
    HashMap<Cube, PVector> teamCubes = new HashMap<Cube, PVector>();

    for(int x = (int) pos.x-1; x <= pos.x+1; x++)
      for(int y = (int) pos.y-1; y <= pos.y+1; y++)
        for(int z = (int) pos.z-1; z <= pos.z+1; z++) {

          Cube c = getCube(x, y, z);
          if(c == null || pos.equals(new PVector(x, y, z)))
            continue;
            
          //Richtung, in die sich der umliegende CUbe mit dem ausgewählten verbindet
          PVector direction = new PVector((int) (x-pos.x),
                                          (int) (y-pos.y),
                                          (int) (z-pos.z));
          nearbyCubes.put(c, direction);
        }
            
     for(Cube c : nearbyCubes.keySet())
      if(c.getTeam() == team)
        teamCubes.put(c, nearbyCubes.get(c));
    
     return teamCubes;
  }
  
  //setzt die Teams der Würfel zurück und löscht ihre Verbindungen
  public void reset() {    
    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++) {
          grid[x][y][z].setTeam(Team.Unoccupied);
          grid[x][y][z].removeAllConnections();
        }
  }
  
  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  @Override
  public void display() {
    if(!isVisible)
      return;
    
    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++)
          grid[x][y][z].display();
  }
}