import java.awt.event.ActionEvent;

//verwaltet das Gitter, die Auswahl von Würfeln im Gitte und das öffnen/schließen des Menüs
//überprüft nach Auswählen, ob dsa jeweilige Team gewonnen hat 
public class Model {
 
  private int gridSize;
  private Grid grid;
  
  private Cube selection;
  private PVector selectionPos;
  private int moves;
  
  private Component2d turnDisplay, menuBack, menu;
  private Button2d continueButton, resetButton, exitButton, menuButton;
  private PGraphics blurredScreen;
  
  private boolean menuIsOpen;
  private long menuOpenTime;
  
  private boolean isGameOver;
  private Team winner;

  //deklariert alle Elemente wie Gitter, Menü, Menühintergrund und Menübuttons
  public Model() {
    gridSize = 4;
    grid = new Grid(gridSize, height * 2/3f);
    moves = 0;
    
    isGameOver = false;
    menuIsOpen = true;
    menuOpenTime = 750;
    
    turnDisplay = new Component2d(-width/2f + height/20f, -height/2f + height/40, 0, height/16f);
    turnDisplay.setVerticalAlignment(Alignment.CENTER);
    turnDisplay.setForeground(new Color(0));
    turnDisplay.setBackground(new Color(255));
    turnDisplay.setTextSize(height/20f);
    turnDisplay.setText("Turn: " + getTurn());
    turnDisplay.setVisible(false);
    
    menuButton = new Button2d(width/2f - height/6f - height/20f, -height/2 + height/40, height/6f, height/16f);
    menuButton.setForeground(new Color(0));
    menuButton.setBackground(new Color(255));
    menuButton.setBorder(new Color(0));
    menuButton.setTextSize(height/20f);
    menuButton.setShortCut(ESC);
    menuButton.setText("Menu");
    menuButton.setVisible(false);
    
    menuBack = new Component2d(-width/2, -height/2, width, height);
    menuBack.setVisible(false);
    
    menu = new Component2d(-height/4f, -height*3/8f, height/2f, height*11/16f);
    menu.setHorizontalAlignment(Alignment.CENTER);
    menu.setTextSize(height/15f);
    menu.setSpacing(height/40f);
    menu.setText("Tic Tac Toe");

    continueButton = new Button2d(-height*3/16f, -height*7/32f, height*3/8f, height/8f);
    continueButton.setTextSize(height/20);
    continueButton.setShortCut(ESC);
    continueButton.setEnabled(false);
    continueButton.setText("-");
    
    resetButton = new Button2d(-height*3/16f, -height*1/16f, height*3/8f, height/8f);
    resetButton.setTextSize(height/20);
    resetButton.setText("New Game");
    
    exitButton = new Button2d(-height*3/16f, height*3/32f, height*3/8f, height/8f);
    exitButton.setTextSize(height/20);
    exitButton.setShortCut(ENTER);
    exitButton.setText("Exit Game :(");
    
    menuButton.setAction(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        openMenu();
      }
    });
    
    continueButton.setAction(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        closeMenu();
      }
    });
    
    resetButton.setAction(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        closeMenu();
        restart();
      }
    });
    
     exitButton.setAction(new ActionListener() {
      @Override
      public void actionPerformed(ActionEvent e) {
        exit();
      }
    });
    
    addComponent2d(1, turnDisplay);
    addComponent2d(1, menuButton);
    addComponent2d(0, menuBack);
    addComponent2d(2, menu);
    addComponent2d(3, continueButton);
    addComponent2d(3, resetButton);
    addComponent2d(3, exitButton);
  }
  
  //gibt zurück, ob das Menü offen ist / die Menü-Komponenten gerade sichtbar sind
  public boolean menuIsOpen() {
    return menuIsOpen;
  }
  
  //gibt zurück, ob die Menüöffnungs-Animation gerade läuft
  public boolean menuIsOpening() {
    return menu.isSlidingIn();
  }
  
  //gibt zurück, ob das derzeitige Spiel bereits beendet ist
  public boolean isGameOver() {
    return isGameOver;
  }
  
  //öffnet das Menü / setzt die Menü-Komponenten sichtbar und alle 3D-Objekte unsichtbar
  public void openMenu() {
    if(menuIsOpening() || menuIsOpen)
      return;
    menuIsOpen = true;
    
    if(isGameOver) {
      menu.setText(winner == null ? "It's a Draw!" : winner + " won!");
      continueButton.setText(winner == null ? "Really?" : "But how?");
      turnDisplay.setText(winner == null ? "Yes, really." : "Like this:");
      resetButton.setText("New Game");

    }else {
      menu.setText("Pause");
      continueButton.setText("Continue");
      resetButton.setText("Restart");
    }
    
    setComponents3dVisible(false);
    turnDisplay.setVisible(false);
    
    menuButton.setVisible(false);  
    
    menuBack.setSize(width, height);
    menuBack.setPos(-width/2, -height/2);
    menuBack.setTexture(get());
    menuBack.fadeIn(getBlurred(get()), 0, menuOpenTime);
    
    float outOfScreen = menu.getY() - menu.getHeight();
    menu.slideIn(0, outOfScreen, 0, menuOpenTime);
    continueButton.slideIn(0, outOfScreen, 0, menuOpenTime);
    resetButton.slideIn(0, outOfScreen, 0, menuOpenTime);
    exitButton.slideIn(0, outOfScreen, 0, menuOpenTime);
  }
  
  //schließt das Menü / setzt die Menü-Komponenten unsichtbar und alle 3D-Objekte wieder sichtbar
  public void closeMenu() {
    if(menuIsOpening() || !menuIsOpen)
      return;
    menuIsOpen = false;

    menuBack.setVisible(false);
    menu.setVisible(false);
    continueButton.setVisible(false);
    resetButton.setVisible(false);
    exitButton.setVisible(false);    
      
    setComponents3dVisible(true);
    turnDisplay.setVisible(true);
    menuButton.setVisible(true);
  }
  
  //setzt vor allem das Cube-Gitter zurück und entscheidet, wer am Zug ist
  public void restart() {
    isGameOver = false;
    unselect();
    moves = 0;
    grid.reset();
    resetController();
    turnDisplay.setText("Turn: " + getTurn());
    closeMenu();
  }
  
  //gibt den Würfel zurück, der gerade von der Maus ausgewählt ist
  public Cube getSelection() {
    return selection;
  }
  //gibt die Position des ausgewählten Würfels im Gitter zurück
  public PVector getSelectionPos() {
    return selectionPos.copy();
  }
  
  //hält fest, welcher Würfel mit der Maus markiert wurde
  public void setSelection(Cube c) {
    if(c.equals(selection))
      return;
    if(selection != null)
      selection.getFill().setB(255);
    
    selection = c;
    selectionPos = grid.getPos(c);
    selection.getFill().setB(127);
  }
  
  //hebt die Auswahl der Maus auf 
  public void unselect() {
    if(selection != null) {
      selection.getFill().setB(255);
      selection = null;
      selectionPos = null;
    }
  }
  
  //schließt die Auswahl eines Würfels für das jeweilige Team ab
  //erweitert vorhandene Verbindungen zwischen Würflen oder erstellt neue
  //überprüft, ob ein Sieg vorliegt
  public boolean confirmSelection(Team team) {
    
    if(selection.getTeam() != Team.Unoccupied)
      return false;
    
    selection.setTeam(team);
    turnDisplay.setText("Turn: " + getOppositeTeam(team));
    moves++;
    
    //stelle List aus allen umliegenden Cubes (mit gleichem Team) um den ausgewählten durch
    HashMap<Cube, PVector> teamCubes = grid.getNearbyTeamCubes(selectionPos, team);
    HashMap<Cube, PVector> stillFreeCubes = new HashMap<Cube, PVector>();
    
    for(Cube c : teamCubes.keySet()) {
      boolean skip = false;
      //gehe die Connections der umliegenden Cubes durch
      
      for(Connection connection : c.getConnections())
        //wenn eine passende vorhanden ist, füge den asugewählten Cube hinzu
        if(areColinear(connection.getDirection(), teamCubes.get(c))) {
          connection.addCube(selection);
          //println("existing connection used " + connection.size());
          skip = true;
          break;
        }

      //sonst setzt den Cube auf die Liste der noch nicht verbundenen Cubes
      if(!skip)
        stillFreeCubes.put(c, teamCubes.get(c));
    }

    if(!stillFreeCubes.isEmpty())
      connectCubes(stillFreeCubes);
    if(moves > 6)
      checkForVictory(selection);
      
    if(moves >= pow(gridSize, 3)) {
      isGameOver = true;
      winner = null;
      openMenu();
    }
      
    unselect();
    return true;
  }
  
  //erstellt neue Verbindungen zwischen Würfeln eines Teams, die unmitelbar nebeneinander liegen und keine Verbindung haben
  public void connectCubes(HashMap<Cube, PVector> freeCubes) {
    
    ArrayList<Connection> connections = selection.getConnections();
    ArrayList<Cube> cubeSet = new ArrayList<Cube> (freeCubes.keySet());    
    Cube c = cubeSet.get(0);
    
    //falls der ausgewählte Cube noch keine Verbindung hat, mache eine neue
    if(connections.isEmpty()) {
      new Connection(selection, c, freeCubes.get(c));
    
    //ansonsten gehe all Connections durch
    }else
      for(Connection connection : connections) {
        //wenn eine Connection passende vorhanden, adde den umliegenden Cube dort hinzu
        if(areColinear(connection.getDirection(), freeCubes.get(c))) {
          connection.addCube(c);
          break;
          
        //ansonsten mache eine neue Connection
        }else if(connections.indexOf(connection) == connections.size()-1) {
          new Connection(selection, c, freeCubes.get(c));
          break;
        }
      }
    
    freeCubes.remove(c);
      
    if(!freeCubes.isEmpty())
      connectCubes(freeCubes);
  }

  //überprüft alle Verbindungen eines Würfels, ob sie 4 Würfel lang ist und somit ein Sieg vorliegt
  private void checkForVictory(Cube c) {
    for(Connection connection : c.getConnections())
      if(connection.size() >= 4) {
        addComponent3d(connection);
        connection.setVisible(true);
        isGameOver = true;
        winner = c.getTeam();
        openMenu();
      }
  }
  
  //gibt zurück, auf welchen Würfel im Gitter eine Gerade zeigt (für das Mausklicken benutzt)
  public Cube getPointingAt(Line ray) {
    return grid.getIntersection(ray);
  }
  
  //gibt ein verschwommenes Bild des Ausgansbildes zurück (für das Hintergrundbild des Menüs)
  private PImage getBlurred(PImage input) {
    blurredScreen = createGraphics(input.width, input.height);
    blurredScreen.beginDraw();
    blurredScreen.image(input, 0, 0);
    blurredScreen.filter(BLUR, 4);
    blurredScreen.endDraw();
    return blurredScreen.get();
  }
  
  //überprüft speziell ob Vektor v0 dem Vektor v1 oder -v1 entspricht 
  public boolean areColinear(PVector v0, PVector v1) {
    return v0.equals(v1) || v0.equals(v1.copy().mult(-1));
  }
}