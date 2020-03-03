import java.text.DecimalFormat;

public class Bezier extends PApplet {
  
  class Vector2 {
    float x,y;
    public Vector2(float x, float y) { this.x = x; this.y = y; }
    public Vector2(float x) { this(x, x); } 
    public Vector2() { this(0.0, 0.0); }
    public Vector2 add(float other){ this.x += other; this.y += other; return this; }
    public Vector2 add(Vector2 other){ this.x += other.x; this.y += other.y; return this; }
    public Vector2 mult(float other){ this.x *= other; this.y *= other; return this; }
    public Vector2 mult(Vector2 other){ this.x *= other.x; this.y *= other.y; return this; }
    @Override public String toString(){ return "<" + this.x + "," + this.y + ">"; }
  }

  class BezierCurve {
    private ArrayList<Vector2> waypoints;
    public BezierCurve(ArrayList<Vector2> points) { waypoints = points; }
    public BezierCurve(Vector2 point1, Vector2 point2) {this(); waypoints.add(point1); waypoints.add(point2);}
    public BezierCurve() { waypoints = new ArrayList<Vector2>(); }

    private double frac(int x){
      if(x == 0) return 1.0;
      return x * frac(x-1);
    }
    
    public int size(){ return waypoints.size(); }
    
    public Vector2 getPoint(float u){
      int n = waypoints.size()-1;
      int x = 0; int y = 0;
      for(int i = 0; i <= n; i++){
        Vector2 point = waypoints.get(i);
        double coef = frac(n) / frac(i) / frac(n-i) * Math.pow(u,i) * Math.pow(1-u, n-i);
        x += coef * point.x; y += coef * point.y;
      }
      return new Vector2(x,y);
    }
    public Vector2 getWaypoint(int index){ return waypoints.get(index); }
    public Vector2 lastWaypoint() { return waypoints.get(size()-1); }
    public void addPoint(Vector2 point){ waypoints.add(point); }
    public void addPoint(Vector2 point, int index){ waypoints.add(index, point); }
    public void removePoint(Vector2 point) { waypoints.remove(point); }
    @Override public String toString() { return waypoints.toString(); }
  }
  
  boolean drawConnections = true;
  boolean drawHandles = true;
  boolean drawAnchors = true;
  
  final int hoverDistance = 10;
  final int splineSize = 30;
  final int pointsPerSpline = 30;
  final DecimalFormat df = new DecimalFormat("0.00");
  Vector2 drag;
  ArrayList<BezierCurve> splines = new ArrayList();
  
  void setup()
  {
    surface.setSize(1000, 700);
    BezierCurve spline = new BezierCurve();
    spline.addPoint(new Vector2(100.0, 100.0));
    spline.addPoint(new Vector2(300.0, 300.0));
    splines.add(spline);
    drawSplines();
  }
  
  void draw()
  {
    background(100);
    BezierCurve spline; Vector2 point; Vector2 lastPoint = null;
    for(int s = 0; s < splines.size(); s++){
      spline = splines.get(s);
      for(int i = 0; i < spline.size(); i++){
        point = spline.getWaypoint(i);
        stroke(60);
        if(lastPoint != null) {
          line(point.x, point.y, lastPoint.x, lastPoint.y);
        }
        lastPoint = point;
        stroke(225);
        circle(point.x, point.y, 6.0);
      }
    }

    stroke(255);
    drawSplines();
  }
  
  void drawSplines(){
    if(splines.size() == 0) return;
    Vector2 lastPoint;
    Vector2 point;
    for(BezierCurve spline : splines){
      if(splines.size() == 0) return;
      lastPoint = spline.getWaypoint(0);
      for(float i=0; i<=1; i+= 1.0/pointsPerSpline){
        point = spline.getPoint(i);
        circle(point.x, point.y, 3f);
        line(point.x, point.y, lastPoint.x, lastPoint.y);
        lastPoint = point;
      }
      point = spline.lastWaypoint();
      line(point.x, point.y, lastPoint.x, lastPoint.y);
    }
  }
  
  void addPoint(int x, int y){
    Vector2 point = new Vector2(x,y);
    for(BezierCurve spline: splines){
      for(int i=1;i<spline.size();i++){
        if(isInline(point, spline.getWaypoint(i-1), spline.getWaypoint(i))){
          spline.addPoint(new Vector2(x,y), i);
          return;
        }
      }
    }
    splines.add(new BezierCurve(splines.get(splines.size()-1).lastWaypoint(), point));
  }
  
  void movePoint(){
    for(BezierCurve spline : splines){
      
      for(int i = 0;i < spline.size();i++){
        Vector2 point = spline.getWaypoint(i);
        if(Math.sqrt(Math.pow(point.x - mouseX, 2) + Math.pow(point.y - mouseY, 2)) < hoverDistance){
          if(keyPressed && keyCode == SHIFT){
            spline.removePoint(point);
          } else {
            drag = point;
          }
          return;
        }
      }
    }
  }
  
  boolean isInline(Vector2 point, Vector2 point1, Vector2 point2){
    return Math.abs(
      (point.x-point1.x) / (point1.x-point2.x) -
      (point.y-point1.y) / (point1.y-point2.y)
    ) < 0.5; 
  }
  
  
  void mousePressed(){
    if(mouseButton == RIGHT){
      addPoint(mouseX, mouseY);
    }
     else if(mouseButton == LEFT){
       movePoint();
     }
  }
  
  void mouseDragged(){
    if(drag == null) return;
    drag.x = mouseX;
    drag.y = mouseY;
  }
  
  void mouseReleased(){
    drag = null;
  }
  
  //void keyPressed(){ 
  //  if(key == ' '){
  //    if (drawConnections) drawConnections = false;
  //    else if (drawHandles) drawHandles = false;
  //    else if (drawAnchors) drawAnchors = false;
  //    else {
  //      drawConnections = true;
  //      drawHandles = true;
  //      drawAnchors = true;
  //    }
  //  }
  //}
  
}
