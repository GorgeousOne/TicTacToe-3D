  
public enum Alignment {
  LEFT, RIGHT, CENTER, TOP, BOTTOM;
}

public class Component2d implements Displayable, Textureable {
  
  protected float x, y, w, h;
  protected Color foreground, background, border;
  protected float borderWeight, textSize;
  
  protected String text;
  protected PImage texture;
  
  protected Alignment horizontalAlignment, verticalAlignment;
  protected float spacing;
  
  protected boolean  isVisible, borderIsPainted, isMouseHovered, isMousePressed;
  
  protected boolean isSliding;
  protected long slideStart, slideDuration;
  protected float dxSlide, dySlide;
  protected int animationSpeed;
  
  protected boolean isFading;
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
  
  public void mousePress() {
    isMousePressed = true;
  }
  public void mouseRelease() {
    isMousePressed = false;
  }
  public void mouseEnter() {
    isMouseHovered = true;
  }
  public void mouseExit() {
    isMouseHovered = false;
  } 
  
  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public float getWidth() {
    return w;
  }
  public float getHeight() {
    return h;
  }
  
  public boolean isHovered() {
    return isMouseHovered;
  }
  
  public boolean isSliding() {
    return isSliding;  
  }
  
  public boolean contains(int pX, int pY) {
    if(!isVisible)
      return false;
    return pX > x && pX < x+w &&
           pY > y && pY < y+h;
  }
  
  @Override
  public PImage getTexture() {
    return texture;
  }
  @Override
  public void setTexture(PImage img) {
    this.texture = img;
  }
  
  public void setText(String text) {
    this.text = text;
  }
  public void setPos(float x, float y) {
    this.x = x;
    this.y = y;
  }
  public void setSize(float w, float h) {
    this.w = w;
    this.h = h;
  }
  
  public void setForeground(Color c) {
    this.foreground = c;
  }
  public void setBackground(Color c) {
    this.background = c;
  }
  public void setBorder(Color c) {
    this.border = c;
  }
  
  public void setBorderPainted(boolean flag) {
    borderIsPainted = flag;
  }
  public void setBorderWeight(float weight) {
    this.borderWeight = weight;
  }
  public void setTextSize(float size) {
    this.textSize = size;  
  }
  
  public void setHorizontalAlignment(Alignment a) {
    horizontalAlignment = a;
  }
  public void setVerticalAlignment(Alignment a) {
    verticalAlignment = a;
  }
  public void setSpacing(float spacing) {
    this.spacing = spacing;
  }
  
  public void slideIn(float dx, float dy, long delay, long duration) {
    setVisible(true);
    slideStart = millis() + delay;
    slideDuration = duration;
    dxSlide = dx;
    dySlide = dy;
    isSliding = true;
  }
    
  public void fadeIn(PImage texture, long delay, long duration) {
    setVisible(true);
    fadeStart = millis() + delay;
    fadeDuration = duration;
    fadeTexture = texture;
    isFading = true;
  }

  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  @Override
  public void display() {
    if(!isVisible) {
      isSliding = false;
      isFading = false;
      return;
    }
    
    pushMatrix();
    pushStyle();
    
    if(isSliding && millis() >= slideStart) {
      long slideTimeLeft = (slideStart+slideDuration) - millis();
      
      //Verschiebung nur nach Überpüfung der Zeit, da die Komponente sonst weiter gleitet
      if(slideTimeLeft > 0) {
        //s: Strecke in Pixel, t: Zeit in ms
        //s(t) = sGesamt / tGesamt^n * t^n
        float dxCurrent = dxSlide/pow(slideDuration, animationSpeed) * pow(slideTimeLeft, animationSpeed),
              dyCurrent = dySlide/pow(slideDuration, animationSpeed) * pow(slideTimeLeft, animationSpeed);
        translate(dxCurrent, dyCurrent, 0);
      
      }else {
        isSliding = false;
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
    
    if(isFading && millis() >= fadeStart) {
      long fadeTimeLeft = (fadeStart+fadeDuration) - millis();      
      int alpha = 255 - (int) (255f / pow(fadeDuration, animationSpeed) * pow(fadeTimeLeft, animationSpeed));

      translate(0, 0, sign(getCamPos().z));
      tint(255, alpha);

      beginShape();
      texture(fadeTexture);
      vertex(x,   y,   0, 0);
      vertex(x+w, y,   fadeTexture.width, 0);
      vertex(x+w, y+h, fadeTexture.width, fadeTexture.height);
      vertex(x,   y+h, 0,                 fadeTexture.height);
      endShape();
      
      if(fadeTimeLeft <= 0) {
        isFading = false;
        setTexture(fadeTexture);
      }
    }
    
    if(text != null && !text.equals("")) {
      translate(0, 0, sign(getCamPos().z));
      paintText();
    }
    
    popStyle();
    popMatrix();
  }
  
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