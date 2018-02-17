
public class Grid implements Displayable {
  
  private Cube[][][] grid;
  private int size;
 
  private boolean isVisible;
 
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
  
  public Cube getCube(int x, int y, int z) {
    if(x<0 || x > size-1 || 
       y<0 || y > size-1 ||
       z<0 || z > size-1)
      return null;
    return grid[x][y][z];
  }
 
  public PVector getPos(Cube c) {
    for(int x = 0; x < size; x++)
      for(int y = 0; y < size; y++)
        for(int z = 0; z < size; z++)
          if(grid[x][y][z].equals(c))
            return new PVector(x, y, z);
    return null;
  }
  
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