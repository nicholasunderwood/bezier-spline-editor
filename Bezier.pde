public class Bezier extends PApplet {
  
  class Vector2{
    double x,y;
    double deltaX = 0;
    double deltaY = 0;
    public Vector2(double x, double y){
      this.x = x;
      this.y = y;
    }
    public Vector2 add(Vector2 other){
      return new Vector2(this.x + other.x, this.y + other.y);
    }
    public Vector2 mult(double other){
      return new Vector2(this.x * other, this.y * other);
    }
    @Override
    public String toString(){
      return String.format("<{0}, {1}>", this.x, this.y);
    }
  }
  

  
  int dragIndex;
  boolean isDraggingHandleWithOppHandle;
  boolean isDraggingAnchor;
  
  Vector2 drag;
  Vector2 anchor;
  Vector2 dragOppHandle;
  Vector2 dragAnchor;
  Vector2 dragHandle1;
  Vector2 dragHandle2;
  
  boolean drawConnections = true;
  boolean drawHandles = true;
  boolean drawAnchors = true;
  
  final float hoverDistance = 10.0;
  final int splineSize = 30;
  ArrayList<Vector2> points = new ArrayList();

  void setup()
  {
    surface.setSize(1000, 700);
  }
  
  void draw()
  {
    background(100);
    for(int i = 0; i < points.size(); i++){
      Vector2 point = points.get(i);
      stroke(60);
      if(i>0 && drawConnections){
        line((float) points.get(i).x, (float) points.get(i).y, (float) points.get(i-1).x, (float) points.get(i-1).y);
      }
      stroke(225);
      if(drawHandles || (drawAnchors && isAnchor(i))){
        circle((float) point.x, (float) point.y, 5.0);
      }
    }
    noFill();
    drawSpline();
    fill(255);
  }
  
  void drawSpline(){
    for(int i = 3; i < points.size(); i += 3){
      bezier(
        (float) points.get(i-3).x,
        (float) points.get(i-3).y,
        (float) points.get(i-2).x,
        (float) points.get(i-2).y,
        (float) points.get(i-1).x,
        (float) points.get(i-1).y,
        (float) points.get(i).x,
        (float) points.get(i).y
      );
    }
  }
    
  boolean hasOppHandle(int index){ return index % 3 != 0 && index != 1 && (index % 3 != 2 || index + 2 < points.size()); }
  boolean isAnchor(int index){ return index % 3 == 0; }
  int getOppHandleIndex(int index) { return index % 3 == 1 ? index - 2 : index + 2; }
  int getAnchorIndex(int index) { return index % 3 == 1 ? index - 1 : index + 1; }
  
  void addPoint(int x, int y){
    if(anchor == null){
        anchor = new Vector2(x, y);
        points.add(anchor);
      }
      else{
        if(points.size() > 1){
          points.add(
            points.size()-1, 
            new Vector2( anchor.x*2 - x, anchor.y*2 - y)
          );
        }
        //points.add(anchor);
        points.add(new Vector2(x, y));
        anchor = null;
      }
  }
  
  void movePoint(){
    for(int i = 0;i < points.size();i++){
          Vector2 point = points.get(i);
          if(Math.sqrt(Math.pow(point.x - mouseX, 2) + Math.pow(point.y - mouseY, 2)) < hoverDistance){
            drag = point;
            if(hasOppHandle(i)) {
              dragOppHandle = points.get(getOppHandleIndex(i));
              dragAnchor = points.get(getAnchorIndex(i));    
            }
            else if(isAnchor(i)){
              if(i > 0){
                  dragHandle1 = points.get(i-1);
              }
              if(i < points.size()){
                  dragHandle2 = points.get(i+1);
              }
            }
            if(keyCode == 16 && keyPressed){
              if(drag == anchor){
                anchor = null;
              }
              points.remove(drag);
              points.remove(dragOppHandle);
              points.remove(dragAnchor);
              points.remove(dragHandle1);
              points.remove(dragHandle2);
            }
            break;
          }
      }
  }
  
  void randomPoints(int numPoints){
     for(int i = 0;i<numPoints;i++){
       int x = (int) (Math.random()*width);
       int y = (int) (Math.random()*height);
       addPoint(x,y);
       addPoint(
         (int) (Math.random()*300) + x - 150,
         (int) (Math.random()*300) + y - 150
       );
     }
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
    if(!(drag == null)){
      double deltaX = mouseX - drag.x;
      double deltaY = mouseY - drag.y;
      drag.x = mouseX;
      drag.y = mouseY;
      if(dragOppHandle != null){
        dragOppHandle.x = dragAnchor.x*2 - mouseX;
        dragOppHandle.y = dragAnchor.y*2 - mouseY;
      }
      else if(dragHandle2 != null){
        dragHandle2.x += deltaX;
        dragHandle2.y += deltaY;
        if(dragHandle1 != null){
          dragHandle1.x += deltaX;
          dragHandle1.y += deltaY;
        }
      }
    }
  }
  
  void mouseReleased(){
    drag = null;
    dragOppHandle = null;
    dragAnchor = null;
    dragHandle1 = null;
    dragHandle2 = null;
  }
  
  void keyPressed(){ 
    if(key == ' '){
      if (drawConnections) drawConnections = false;
      else if (drawHandles) drawHandles = false;
      else if (drawAnchors) drawAnchors = false;
      else {
        drawConnections = true;
        drawHandles = true;
        drawAnchors = true;
      }
    } else if(key == 'r'){
      randomPoints(1);
    }
  }
  
  Vector2 csit(Vector2 a, Vector2 b, Vector2 c, Vector2 d, double t){
    //t^3*a + 3*t^2*(1-t)*b + 3*t*(1-t)^2*c + (1-t)^3*d
    return d.mult(Math.pow(t,3))
      .add(c.mult(3*Math.pow(t,2)*(1-t)))
      .add(b.mult(3*t*Math.pow(1-t,2)))
      .add(a.mult(Math.pow(1-t,3)));
  }
}
