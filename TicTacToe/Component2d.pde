  
//Enum mit möglichen relativen Positionierungen von Text in einer Komponente
public enum Alignment {
  LEFT, RIGHT, CENTER, TOP, BOTTOM;
}

//2D-Komponente, die so etwas wie Knöpfe oder Menüs oder Bilder darstellen kann
public class Component2d implements Displayable {
  
  protected float x, y, w, h;
  protected Color foreground, background, border;
  protected float borderWeight, textSize;
  
  protected String text;
  protected PImage texture;
  
  protected Alignment horizontalAlignment, verticalAlignment;
  protected float spacing;
  
  protected boolean  isVisible, borderIsPainted, isMouseHovered, isMousePressed;
  
  protected boolean isSlidingIn;
  protected long slideStart, slideDuration;
  protected float originX, originY, slideDX, slideDY;
  protected int animationSpeed;
  
  protected boolean isFadingIn;
  protected long fadeStart, fadeDuration;
  protected PImage fadeTexture;
  
  public Component2d(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    foreground = new Color(255);
    background = new Color(0);
    border = new Color(255);
    
    textSize = 12;
    borderWeight = 1;
    
    text = null;
    texture = null;
    
    isVisible = true;
    borderIsPainted = false;
    isMouseHovered = false;
    isMousePressed = false;
    
    horizontalAlignment = Alignment.LEFT;
    verticalAlignment = Alignment.TOP;
    spacing = 0;
    
    animationSpeed = 3;
  }
  
  public Component2d() {
    this(-width/2f, -height/2f, width/10f, height/10f); 
  }
  
  //führt mögliche Aktion bei Mausklick durch
  public void mousePress() {
    isMousePressed = true;
  }
  //führt mögliche Aktion bei Loslassen der Maus durch
  public void mouseRelease() {
    isMousePressed = false;
  }
  //führt mögliche Aktion bei Eintritt der Maus in Komponente durch
  public void mouseEnter() {
    isMouseHovered = true;
  }
  //führt mögliche Aktion bei Austritt der Maus in Komponente durch
  public void mouseExit() {
    isMouseHovered = false;
  } 
  
  //getter
  //gibt x-Position zurück
  public float getX() {
    return x;
  }
  //gibt y-Position zurück
  public float getY() {
    return y;
  }
  //gibt Breite zurück
  public float getWidth() {
    return w;
  }
  //gibt Höhe zurück
  public float getHeight() {
    return h;
  }
  //gibt zurück, ob Maus gerade über der Komponente schwebt
  public boolean isHovered() {
    return isMouseHovered;
  }
  
  //gibt zurück, ob die Komponente derzeit in einer Bewgungsanmation ist
  public boolean isSlidingIn() {
    return isSlidingIn;
  }
  
  //gibt zurück, ob sich eine 2D-Koordinate in der Komponente befindet
  public boolean contains(int pX, int pY) {
    return pX > x && pX < x+w &&
           pY > y && pY < y+h;
  }
  
  //setzt die Koordinaten der Komponente
  public void setPos(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  //setzt die Größe der Komponente
  public void setSize(float w, float h) {
    this.w = w;
    this.h = h;
  }
  
  //definiert die Textur, eine Bild, der Komponente
  public void setTexture(PImage img) {
    this.texture = img;
  }
  
  //definiert den Text, der in der Komponente geschrieben steht
  public void setText(String text) {
    this.text = text;
  }
  
  //legt die Textfarbe fest
  public void setForeground(Color c) {
    this.foreground = c;
  }
  //legt die Hintergrundfarbe der Komponente fest
  public void setBackground(Color c) {
    this.background = c;
  }
  //legt die Farbe der Umrandung fest
  public void setBorder(Color c) {
    this.border = c;
  }
  
  //bestimmt, ob die Umrandung der Komponente gezeichnet wird
  public void setBorderPainted(boolean flag) {
    borderIsPainted = flag;
  }
  //setzt die Strichstärke der Umrandung fest
  public void setBorderWeight(float weight) {
    this.borderWeight = weight;
  }
  //legt die Textgröße des Schriftzuges fest
  public void setTextSize(float size) {
    this.textSize = size;  
  }
  
  //legt die x-Ausrichtung des Textes fest
  public void setHorizontalAlignment(Alignment a) {
    horizontalAlignment = a;
  }
  //legt die y-Ausrichtung  des Textes fest
  public void setVerticalAlignment(Alignment a) {
    verticalAlignment = a;
  }
  //legt den Abstand des Textes zu Rand der Komponente fest
  public void setSpacing(float spacing) {
    this.spacing = spacing;
  }
  
  /*beginnt eine Bewgungsanimation von einer relativen Position zurück zu ursprünglichen Position
    @param relative x-Koordinate
    @param relative y-Koordinate
    @param Verzögerung bis zum Beginn der Animation
    @param Dauer der Animation
  */
  public void slideIn(float fromDX, float fromDY, long delay, long duration) {
    setVisible(true);
    slideStart = millis() + delay;
    slideDuration = duration;
    slideDX = fromDX;
    slideDY = fromDY;
    isSlidingIn = true;

    originX = getX();
    originY = getY();
  }
  
  /*beginnt eine neue Textur einzublenden
    @param neue Textur
    @param Verzögerung bis zum Beginn der Animation
    @param Dauer der Animation
  */
  public void fadeIn(PImage texture, long delay, long duration) {
    setVisible(true);
    fadeStart = millis() + delay;
    fadeDuration = duration;
    fadeTexture = texture;
    isFadingIn = true;
  }

  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  @Override
  public void display() {
    if(!isVisible) {
      //beendet jegliche Animation
      if(isSlidingIn)
        slideDuration = 0;
       if(isFadingIn)
         fadeDuration = 0;
      return;
    }
    
    pushMatrix();
    pushStyle();
    
    //setzt die momentane Position der Komponente während der Bewegungsanimation
    if(isSlidingIn && millis() >= slideStart) {
      long slideTimeLeft = (slideStart+slideDuration) - millis();
      
      if(slideTimeLeft > 0) {
        //s: relative verbleibende Strecke zum Ursprung
        //t: verbleibende Zeit bis zum Ende der Animation
        //s(t) = sGesamt / tGesamt^n * t^n
        float currentDX = slideDX/pow(slideDuration, animationSpeed) * pow(slideTimeLeft, animationSpeed),
              currentDY = slideDY/pow(slideDuration, animationSpeed) * pow(slideTimeLeft, animationSpeed);
        setPos(originX + currentDX, originY + currentDY);
      
      }else {
        //gehe zurück zur ursprünglichen Position, beende Animation
        setPos(originX, originY);
        isSlidingIn = false;
        update();
      }
    }
    
    if(borderIsPainted) {
      stroke(border.integer());
      strokeWeight(borderWeight);
    }else
      noStroke();
        
    if(texture != null) {
      beginShape();
      texture(texture);
      vertex(x,   y,   0, 0);
      vertex(x+w, y,   texture.width, 0);
      vertex(x+w, y+h, texture.width, texture.height);
      vertex(x,   y+h, 0,             texture.height);
      endShape();   
    }else {
      fill(background.integer());
      rect(x, y, w, h);
    }
    
    //blendet die neue Textur mit momentanem Alpha-Wert ein
    if(isFadingIn && millis() >= fadeStart) {
      long fadeTimeLeft = (fadeStart+fadeDuration) - millis();
      int alphaLeft = (int) (255f / pow(fadeDuration, animationSpeed) * pow(fadeTimeLeft, animationSpeed));

      translate(0, 0, 0.1);
      tint(255, 255 - alphaLeft);

      beginShape();
      texture(fadeTexture);
      vertex(x,   y,   0, 0);
      vertex(x+w, y,   fadeTexture.width, 0);
      vertex(x+w, y+h, fadeTexture.width, fadeTexture.height);
      vertex(x,   y+h, 0,                 fadeTexture.height);
      endShape();
      
      if(fadeTimeLeft <= 0) {
        //setzte neue Textur, beende Animation
        setTexture(fadeTexture);
        isFadingIn = false;
      }
    }
    
    if(text != null && !text.equals("")) {
      translate(0, 0, 0.1);
      paintText();
    }
    
    popStyle();
    popMatrix();
  }
  
  //zeichnet den Schriftzug der Komponente auf die Leinwand
  private void paintText() {
    fill(foreground.integer());
    textSize(textSize);
    
    float textX = x + spacing;
    if(horizontalAlignment == Alignment.RIGHT)
      textX += w - textWidth(text) - 2*spacing;
    else if(horizontalAlignment == Alignment.CENTER)
      textX += w/2 - textWidth(text)/2 - spacing;
    
    float textY = y + textAscent()+textDescent() + spacing;
    if(verticalAlignment == Alignment.BOTTOM)
      textY += h - (textAscent()+textDescent()) - 2*spacing;
    else if(verticalAlignment == Alignment.CENTER)
      textY += h/2 - (textAscent()+textDescent())/2 - spacing - textSize/5;    //textSize/5 ist eine kleine Korrektur zur Mitte hin
      
    text(text, textX, textY, 0);
  }
}