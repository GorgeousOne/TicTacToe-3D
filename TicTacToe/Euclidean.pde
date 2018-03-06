
//repräsentiert eine Gerade im R3
class Line {

  private PVector origin, direction;
  
  public Line(PVector origin, PVector direction) {
    this.origin = origin;
    this.direction = direction;
    
    if(direction.equals(new PVector(0, 0, 0)))
      throw new IllegalArgumentException("direction cannot be 0");
  }

  //gibt Stützvektor zurück
  public PVector getOrigin() {
    return origin.copy();
  }
  //gibt Richtungsvektor zurück
  public PVector getDirection() {
    return direction.copy();
  }
  //berechnet den Punkt von Stützvektor + r * Richtungsvektor auf der Geraden
  public PVector getPoint(float r) {
    return getOrigin().add(getDirection().mult(r));
  }
}

//repräsentiert eine Ebene im R3
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
  
  //gibt Stützvektor zurück
  public PVector getOrigin() {
    return origin.copy();
  }
  //gibt Normalenvektor zurück
  public PVector getNormal() {
    return normal.copy();
  }
  //gibt an, ob ein Punkt in der Ebene liegt (plus minus einem kleinem Schwellwert)
  public boolean contains(PVector point) {
    PVector sub = getOrigin().sub(point);
    return abs(getNormal().dot(sub)) < 0.1;    //TODO define a good precision value?
  }
  
  //gibt an, ob eine Gerade die Gerade schneidet
  public boolean intersects(Line l) {
    return getIntersection(l) != null;
  }
  //gibt den Schnittpunkt von Gerade und Ebene zurück
  public PVector getIntersection(Line l) {
    float r = getOrigin().sub(l.getOrigin()).dot(getNormal()) / l.getDirection().dot(getNormal());
    PVector intersection = l.getPoint(r);
    
    return contains(intersection) ? intersection : null;
  }
}