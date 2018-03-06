import java.awt.event.ActionListener;

public class Button2d extends Component2d {
  
  private boolean isEnabled;
  private boolean isKeyPressed;
  private ActionListener action;
  private char shortCut;
  
  public Button2d(float x, float y, float w, float h) {
    super(x, y, w, h);
    setBorderWeight(height/150f);
    setHorizontalAlignment(Alignment.CENTER);
    setVerticalAlignment(Alignment.CENTER);
    isKeyPressed = false;
    isEnabled = true;
    shortCut = 0;
  }
  
  public Button2d() {
    super();
    setBorderWeight(height/150f);
    setHorizontalAlignment(Alignment.CENTER);
    setVerticalAlignment(Alignment.CENTER);
    isKeyPressed = false;
    isEnabled = true;
    shortCut = 0;
  }
  
  //lege fest, ob der Knopf pressbar ist
  public void setEnabled(boolean flag) {
    if(!flag) {
      if(isMouseHovered)
        mouseExit();
      if(isMousePressed)
        mouseRelease();
    }
    isEnabled = flag;
  }
  
  //setzt die auszuführende Aktion, wenn der Knopf als bestätigt gezählt wird
  public void setAction(ActionListener a) {
    action = a;
  }
  
  //legt eine Taste fest, mit der man den Knopf pressen kann
  public void setShortCut(char key) {
    this.shortCut = key;
  }
  
  @Override
  public void mouseEnter() {
    if(!isVisible || !isEnabled || isKeyPressed)
      return;
    super.mouseEnter();
    
    if(isMousePressed)
      switchColors();
    setBorderPainted(true);
  }
  
  @Override
  public void mouseExit() {
    if(!isVisible || !isEnabled || isKeyPressed)
      return;
    super.mouseExit();

    if(isMousePressed)
      switchColors();
    else
      setBorderPainted(false);
  }
  
  @Override
  public void mousePress() {
    if(!isVisible || !isEnabled || isKeyPressed)
      return;
    super.mousePress();
    switchColors();
  }
  
  @Override
  public void mouseRelease() {
    if(!isVisible || !isEnabled || !isMousePressed || isKeyPressed)
      return;
    super.mouseRelease();
    
    if(isMouseHovered) {
      switchColors();

      if(action != null)
        action.actionPerformed(null);
          
    }else
      setBorderPainted(false);
  }
  
  public void keyPress(char key) {
    if(!isVisible || !isEnabled || shortCut == 0 || isMousePressed)
      return;
    if(key == shortCut) {
      isKeyPressed = true;
      setBorderPainted(true);
      switchColors();
    }
  }
  
  public void keyRelease(char key) {
    if(!isVisible || !isEnabled || !isKeyPressed || shortCut == 0)
      return;
    if(key == shortCut) {
      isKeyPressed = false;
      setBorderPainted(false);
      switchColors();
      
      if(action != null)
        action.actionPerformed(null);
    }
  }
  
  @Override
  public void slideIn(float dx, float dy, long delay, long duration) {
    super.slideIn(dx, dy, delay, duration);
    setEnabled(false);
  }
  
  @Override
  public void setVisible(boolean state) {
    
    if(isMouseHovered)
      mouseExit();
    if(isMousePressed)
      isMouseHovered = false;
    if(isKeyPressed)
      isKeyPressed = false;

    super.setVisible(state);
  }
  
  //wechselt die Farben von Schrift und Hintergrund
  private void switchColors() {
    Color holder = foreground;
    foreground = background;
    background = holder;
  }
  
  @Override
  public void display() {
    float slideTimeLeft = (slideStart+slideDuration) - millis();
      
    if(isSlidingIn && slideTimeLeft <= 0)
      setEnabled(true);
      
    super.display();
  }
}