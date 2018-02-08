
class Line {

  private PVector origin, direction;
  
  public Line(PVector origin, PVector direction) {
    this.origin = origin;
    this.direction = direction;
    
    if(direction.equals(new PVector(0, 0, 0)))
      throw new IllegalArgumentException("direction cannot be 0");
  }

  public PVector getOrigin() {
    return origin.copy();
  }

  public PVector getDirection() {
    return direction.copy();
  }
  
  public PVector getPoint(float r) {
    return getOrigin().add(getDirection().mult(r));
  }
}

class Plane {

  private PVector origin, normal;
  
  public Plane(PVector origin, PVector u, PVector v) {
    this.origin = origin.copy();
    this.normal = u.cross(v).normalize();
    
    if(normal.equals(new PVector(0, 0, 0)))
      throw new IllegalArgumentException("u or v cannot be 0");
  }
  
  public Plane(PVector origin, PVector normal) {
    this.origin = origin.copy();
    this.normal = normal.copy().normalize();
    
    if(normal.equals(new PVector(0, 0, 0)))
      throw new IllegalArgumentException("normal cannot be 0");
  }
  
  public PVector getOrigin() {
    return origin.copy();
  }

  public PVector getNormal() {
    return normal.copy();
  }
  
  protected PVector setOrigin(PVector vector) {
    return origin = vector.copy();
  }
  
  public void setNormal(PVector vector) {
    if(normal.equals(new PVector(0, 0, 0)))
      throw new IllegalArgumentException("u or v cannot be 0");
    normal = vector.copy().normalize();
  }
  
  public boolean contains(PVector point) {
    PVector sub = getOrigin().sub(point);
    return abs(getNormal().dot(sub)) < 0.1;    //TODO define a good precision value?
  }
  
  public boolean intersects(Line l) {
    if(getNormal().dot(l.getDirection()) == 0)
      return contains(l.getOrigin());
    return true;
  }
  
  public PVector getIntersection(Line l) {
    float r = getOrigin().sub(l.getOrigin()).dot(getNormal()) / l.getDirection().dot(getNormal());
    return l.getPoint(r);
  }
}