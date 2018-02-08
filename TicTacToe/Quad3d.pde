
public class Quad3d extends Plane implements Displayable, Transformable, Textureable{
  
  private PVector pos;
  private float yaw, pitch;
  
  private PVector[] vertices;
  private PVector[] transVertices;
  
  private Color fill, stroke;
  private PImage texture;
  
  private boolean isVisible, needsUpdate;
  
  public Quad3d(PVector origin, PVector edgeA, PVector edgeB) {
    super(origin, edgeA, edgeB);
    
    yaw = pitch = 0;
    pos = new PVector(0, 0, 0);
    
    vertices = new PVector[] {getOrigin(),
                 getOrigin().add(edgeA),
                 getOrigin().add(edgeA).add(edgeB),
                 getOrigin().add(edgeB)};

    transVertices = vertices.clone();
    needsUpdate = false;
    isVisible = true;
    
    fill = new Color(0);
    stroke = new Color(0);
  }

  public PVector[] getUntransformedVertices() {
    return vertices.clone();
  }
 
  public PVector[] getVertices() {
    return transVertices.clone();
  }
  
  //getter
  public PVector getPos() {
    return pos.copy();
  }
  public PVector getMid() {
    if(needsUpdate)
      calcTransform();
    return transVertices[0].copy().add(getEdgeA().mult(0.5)).add(getEdgeB().mult(0.5));
  }
 
  public float getYaw() {
    return yaw;
  }
  
  public float getPitch() {
    return pitch;
  }
  
  public PVector getEdgeA() {
    if(needsUpdate)
      calcTransform();
    return transVertices[1].copy().sub(transVertices[0]);
  }
  
  public PVector getEdgeB() {
    if(needsUpdate)
      calcTransform();
    return transVertices[3].copy().sub(transVertices[0]);
  }
  
  public Color getFill() {
    return fill;
  }
  public Color getStroke() {
    return stroke;
  }
  
  @Override
  public PImage getTexture() {
    return texture;
  }
  

  //setter
  public void setShape(PVector origin, PVector edgeA, PVector edgeB) {
    vertices = new PVector[] {origin.copy(),
                 origin.copy().add(edgeA),
                 origin.copy().add(edgeA).add(edgeB),
                 origin.copy().add(edgeB)};
    needsUpdate = true;
  }
  
  public void setPos(PVector point) {
    pos.set(point.x, point.y, point.z);
    needsUpdate = true;
  }  
  
  public void setYaw(float angle) {
    if(Math.abs(angle) > Math.PI)
      angle -= Math.signum(yaw) * 2*Math.PI;
    yaw = angle;
    needsUpdate = true;
  }
  
  public void setPitch(float angle) {
    if(Math.abs(angle) > Math.PI)
      angle -= Math.signum(yaw) * 2*Math.PI;
    pitch = angle;
    needsUpdate = true;
  }
 
  public void setFill(Color c) {
    fill = c;
  }
  public void setStroke(Color c) {
    stroke = c;
  }
  
  @Override
  public void setTexture(PImage img) {
    texture = img;
  }
  
  @Override
  public void setVisible(boolean state) {
    isVisible = state;
  }
  
  public boolean needsUpdate() {
    return needsUpdate;
  }
  
  public boolean contains(PVector p) {
    if(needsUpdate)
      calcTransform();
    if(!super.contains(p))
      return false;
    
    PVector edgeA = getEdgeA(), edgeB = getEdgeB();
    PVector point = p.copy().sub(transVertices[0]);
  
    float p1, p2, a1, a2, b1, b2;
    
    if(edgeA.x != 0 && edgeB.y != 0 ||
       edgeA.y != 0 && edgeB.x != 0) {
        a1 = edgeA.x;
        a2 = edgeA.y;
        b1 = edgeB.x;
        b2 = edgeB.y;
        p1 = point.x;
        p2 = point.y;
        //println("x");
    }else if(edgeA.x != 0 && edgeB.z != 0 ||
             edgeA.z != 0 && edgeB.x != 0) {
        a1 = edgeA.x;
        a2 = edgeA.z;
        b1 = edgeB.x;
        b2 = edgeB.z;
        p1 = point.x;
        p2 = point.z;        
        //println("y");       
    }else {
        a1 = edgeA.y;
        a2 = edgeA.z;
        b1 = edgeB.y;
        b2 = edgeB.z;
        p1 = point.y;
        p2 = point.z;
        //println("z");
    }
      
    float r, s;
    r = (p1*b2 - p2*b1) / (a1*b2 - a2*b1);
    s = (p2*a1 - p1*a2) / (a1*b2 - a2*b1);
    
    return r > 0 && r < 1 && s > 0 && s < 1;
  }
  
  public boolean intersects(Line l) {
    if(needsUpdate)
      calcTransform();
    if(!super.intersects(l))
      return false;

    PVector point = super.getIntersection(l);//.sub(transVertices[0]);   
    return contains(point);
  }
  
  public PVector getIntersection(Line l) {
    if(needsUpdate)
      calcTransform();
    
    //get the poit of intersection between the line and the plane
    float r = getOrigin().sub(l.getOrigin()).dot(getNormal()) / l.getDirection().dot(getNormal());
    PVector intersection = l.getPoint(r);
    
    return contains(intersection) ? intersection : null;
  }
  
  @Override
  public void display() {
    if(!isVisible)
      return;
      
    if(needsUpdate)
      calcTransform();
    
    if(texture != null) {
      beginShape();
      texture(texture);
      vertex(transVertices[0].x, transVertices[0].y, transVertices[0].z, 0, 0);
      vertex(transVertices[1].x, transVertices[1].y, transVertices[1].z, texture.width, 0);
      vertex(transVertices[2].x, transVertices[2].y, transVertices[2].z, texture.width, texture.height);
      vertex(transVertices[3].x, transVertices[3].y, transVertices[3].z, 0, texture.height);
      endShape(PConstants.CLOSE);
    
    }else {
      fill(fill.integer());
      stroke(stroke.integer());
      
      beginShape();
      vertex(transVertices[0].x, transVertices[0].y, transVertices[0].z);
      vertex(transVertices[1].x, transVertices[1].y, transVertices[1].z);
      vertex(transVertices[2].x, transVertices[2].y, transVertices[2].z);
      vertex(transVertices[3].x, transVertices[3].y, transVertices[3].z);
      endShape(PConstants.CLOSE);
    }
    
    //PVector mid = getMid();
    //PVector end = mid.copy().add(getNormal().normalize().mult(50));
    //stroke(100, 255, 255);
    //line(mid.x, mid.y, mid.z, end.x, end.y, end.z);
  }
  
  public void calcTransform() {
    float x, y, z;
    
    //translate all points referring to their position
    for(int i = 0; i < vertices.length; i++)
      transVertices[i] = vertices[i].copy().add(pos);
    
    //yaw rotation
    pushMatrix();
    rotateX(pitch);
    rotateY(yaw);

    for(int i = 0; i < transVertices.length; i++) {
      PVector vertex = transVertices[i];
      x = modelX(vertex.x, vertex.y, vertex.z);
      y = modelY(vertex.x, vertex.y, vertex.z);
      z = modelZ(vertex.x, vertex.y, vertex.z);
      vertex.set(x, y, z);
    }
    popMatrix();
    
    needsUpdate = false;
    setOrigin(transVertices[0]);
    setNormal(getEdgeA().cross(getEdgeB()));
  }
}