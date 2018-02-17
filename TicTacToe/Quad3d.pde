
public class Quad3d extends Plane implements Displayable{
  
  private float pitch, yaw;
  private PVector pos;
  
  private PVector[] vertices;
  
  private Color fill, stroke;
  private PImage texture;
  
  private boolean isVisible;
  
  public Quad3d(PVector origin, PVector edgeA, PVector edgeB) {
    super(origin, edgeA, edgeB);
    
    yaw = pitch = 0;
    pos = new PVector(0, 0, 0);
    
    vertices = new PVector[] {getOrigin(),
                 getOrigin().add(edgeA),
                 getOrigin().add(edgeA).add(edgeB),
                 getOrigin().add(edgeB)};

    isVisible = true;
    fill = new Color(0);
    stroke = new Color(0);
  }

  public PVector[] getUntransformedVertices() {
    return vertices.clone();
  }
 
  //public PVector[] getVertices() {
  //  return transVertices.clone();
  //}
  
  //getter
  public PVector getPos() {
    return pos.copy();
  }
  public PVector getMid() {
    return vertices[0].copy().add(getEdgeA().mult(0.5)).add(getEdgeB().mult(0.5));
  }
 
  public float getYaw() {
    return yaw;
  }
  
  public float getPitch() {
    return pitch;
  }
  
  public PVector getEdgeA() {
    return vertices[1].copy().sub(vertices[0]);
  }
  
  public PVector getEdgeB() {
    return vertices[3].copy().sub(vertices[0]);
  }
  
  public Color getFill() {
    return fill;
  }
  public Color getStroke() {
    return stroke;
  }
  
  public PImage getTexture() {
    return texture;
  }

  //setter
  public void setPos(PVector point) {
    for(PVector vertex : vertices)
      vertex.sub(pos).add(point);
    pos = point.copy();
    
    setOrigin(vertices[0]);
    setNormal(getEdgeA().cross(getEdgeB()));
  }  
 
  public void setFill(Color c) {
    fill = c;
  }
  public void setStroke(Color c) {
    stroke = c;
  }
  
  public void setTexture(PImage img) {
    texture = img;
  }
  
  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
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
  
  public boolean intersects(Line l) {
    if(!super.intersects(l))
      return false;

    PVector point = super.getIntersection(l);//.sub(transVertices[0]);   
    return contains(point);
  }
  
  public PVector getIntersection(Line l) {
    //get the poit of intersection between the line and the plane
    float r = getOrigin().sub(l.getOrigin()).dot(getNormal()) / l.getDirection().dot(getNormal());
    PVector intersection = l.getPoint(r);
    
    return contains(intersection) ? intersection : null;
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
    //PVector end = mid.copy().add(getNormal().normalize().mult(50));
    //stroke(100, 255, 255);
    //line(mid.x, mid.y, mid.z, end.x, end.y, end.z);
  }
}