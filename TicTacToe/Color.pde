
public class Color {
  
  protected int h, s, b, alpha;
  
  public Color(int grey) {
    setH(0);
    setS(0);
    setB(grey);
    setAlpha(255);
  }
  
  public Color(int grey, int alpha) {
    setH(0);
    setS(0);
    setB(grey);
    setAlpha(alpha);
  }
  
  public Color(int hue, int saturation, int brightness) {
    setH(hue);
    setS(saturation);
    setB(brightness);
    setAlpha(255);
  }
  
  public Color(int hue, int saturation, int brightness, int alpha) {
    setH(hue);
    setS(saturation);
    setB(brightness);
    setAlpha(alpha);
  }
  
  public Color(Color c) {
    this.h = c.h;
    this.s = c.s;
    this.b = c.b;
    this.alpha = c.alpha;
  }
  
  public int h() {
    return h;
  }
  public int s() {
    return s;
  }
  public int b() {
    return b;
  }
  public int alpha() {
    return alpha;
  }
  
  public int integer() {
    return color(h, s, b, alpha);
  }
  
  public void setH(int value) {
    h = max(1, min(255, value));
  }
  public void setS(int value) {
    s = max(1, min(255, value));
  }
  public void setB(int value) {
    b = max(1, min(255, value));
  }
  public void setAlpha(int value) {
    alpha = max(1, min(255, value));
  }
  
  public Color clone() {
    return new Color(this);
  }
}