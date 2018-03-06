
//repräsentiert ein Viereck in einer Ebene, mit gegenüberliegenden Seiten, die parallel sind
//eigentlich ist es ein Parallelogramm aber so lang sollte der Name nicht werden .-.
public class Quad3d extends Plane implements Displayable{
    
  private PVector[] vertices;
  private PVector pos;

  private Color fill, stroke;
  private PImage texture;
  
  private boolean isVisible;
  
  public Quad3d(PVector origin, PVector edgeA, PVector edgeB) {
    super(origin, edgeA, edgeB);
    
    pos = new PVector(0, 0, 0);
    
    vertices = new PVector[] {getOrigin(),
                 getOrigin().add(edgeA),
                 getOrigin().add(edgeA).add(edgeB),
                 getOrigin().add(edgeB)};

    isVisible = true;
    fill = new Color(0);
    stroke = new Color(0);
  }
  
  //getter
  //gibt nun Stützvektor in Kombination der Position zurück
  @Override
  public PVector getOrigin() {
    return super.getOrigin().add(getPos());
  }
  //gibt Position, also Verschiebing des Stützvektors, zurück
  public PVector getPos() {
    return pos.copy();
  }
  //gibt die Mitte des Vierecks zurück
  public PVector getMid() {
    return getOrigin().add(getEdgeA().mult(0.5)).add(getEdgeB().mult(0.5));
  }
  //gibt den Vektor einer Seite zurück
  public PVector getEdgeA() {
    return vertices[1].copy().sub(vertices[0]);
  }
  //gibt den Vektor der einen Seite zurück
  public PVector getEdgeB() {
    return vertices[3].copy().sub(vertices[0]);
  }
  
  //gibt Füllfarbe zurück
  public Color getFill() {
    return fill;
  }
  //gibt Umrandungsfarbe zurück
  public Color getStroke() {
    return stroke;
  }
  //gibt das Bild, die Textur, zurück
  public PImage getTexture() {
    return texture;
  }

  //setter
  //legt die Verschiebung des Stützvektors fest
  public void setPos(PVector point) {
    for(PVector vertex : vertices)
      vertex.sub(pos).add(point);
    pos = point.copy();    
  } 
 
  //legt die Füllfarbe fest
  public void setFill(Color c) {
    fill = c;
  }
  //legt die Umrandungsfarbe fest
  public void setStroke(Color c) {
    stroke = c;
  }
  //legt die Textur fest
  public void setTexture(PImage img) {
    texture = img;
  }
  
  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  @Override
  public boolean contains(PVector p) {
    if(!super.contains(p))
      return false;
    
    PVector edgeA = getEdgeA(), edgeB = getEdgeB();
    PVector point = p.copy().sub(vertices[0]);
  
    float p1, p2, a1, a2, b1, b2;
    
    if(edgeA.x != 0 && edgeB.y != 0 ||
       edgeA.y != 0 && edgeB.x != 0) {
        a1 = edgeA.x;
        a2 = edgeA.y;
        b1 = edgeB.x;
        b2 = edgeB.y;
        p1 = point.x;
        p2 = point.y;
    }else if(edgeA.x != 0 && edgeB.z != 0 ||
             edgeA.z != 0 && edgeB.x != 0) {
        a1 = edgeA.x;
        a2 = edgeA.z;
        b1 = edgeB.x;
        b2 = edgeB.z;
        p1 = point.x;
        p2 = point.z;        
    }else {
        a1 = edgeA.y;
        a2 = edgeA.z;
        b1 = edgeB.y;
        b2 = edgeB.z;
        p1 = point.y;
        p2 = point.z;
    }
    
    float r, s;
    r = (p1*b2 - p2*b1) / (a1*b2 - a2*b1);
    s = (p2*a1 - p1*a2) / (a1*b2 - a2*b1);
    
    return r > 0 && r < 1 && s > 0 && s < 1;
  }
  
  @Override
  public void display() {
    if(!isVisible)
      return;
    
    if(texture != null) {
      beginShape();
      texture(texture);
      vertex(vertices[0].x, vertices[0].y, vertices[0].z, 0, 0);
      vertex(vertices[1].x, vertices[1].y, vertices[1].z, texture.width, 0);
      vertex(vertices[2].x, vertices[2].y, vertices[2].z, texture.width, texture.height);
      vertex(vertices[3].x, vertices[3].y, vertices[3].z, 0, texture.height);
      endShape(PConstants.CLOSE);
    
    }else {
      fill(fill.integer());
      stroke(stroke.integer());
      
      beginShape();
      vertex(vertices[0].x, vertices[0].y, vertices[0].z);
      vertex(vertices[1].x, vertices[1].y, vertices[1].z);
      vertex(vertices[2].x, vertices[2].y, vertices[2].z);
      vertex(vertices[3].x, vertices[3].y, vertices[3].z);
      endShape(PConstants.CLOSE);
    }
    
    //PVector mid = getMid();
    //PVector end = mid.copy().add(getNormal().normalize().mult(10));
    //stroke(100, 255, 255);
    //line(mid.x, mid.y, mid.z, end.x, end.y, end.z);
  }
}