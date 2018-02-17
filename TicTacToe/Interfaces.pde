//Interface für alle Objekte, die auf die Leinwand gemalt werden sollen
public interface Displayable {  
  void display();
  void setVisible(boolean state);
}

//Interface für alle Objekte, die drehbar sein sollen und eine Position haben sollen
public interface Transformable {
  PVector getPos();
  float getYaw();
  float getPitch();
  
  void setPos(PVector p);
  void setYaw(float angle);
  void setPitch(float angle);
}