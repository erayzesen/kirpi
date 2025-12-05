import raylib as rl
import raymath as rm
import rlgl as rlgl

import math
import triangulator


### Transform Logic ###
# 2x3 affine matrix: [a, b, c, d, tx, ty] 
# [ a  c  tx ]
# [ b  d  ty ]
# [ 0  0  1  ]
type Transform* = object
  a,b,c,d,tx,ty: float32

func matIdentity*(): Transform =
  result = Transform(a:1, b:0, c:0, d:1, tx:0, ty:0)

func matMul*(t1, t2: Transform): Transform =
  # t = t1 * t2
  result.a = t1.a*t2.a + t1.c*t2.b
  result.b = t1.b*t2.a + t1.d*t2.b
  result.c = t1.a*t2.c + t1.c*t2.d
  result.d = t1.b*t2.c + t1.d*t2.d
  result.tx = t1.a*t2.tx + t1.c*t2.ty + t1.tx
  result.ty = t1.b*t2.tx + t1.d*t2.ty + t1.ty

func matTranslate*(dx, dy: float32): Transform =
  result=Transform(a:1, b:0, c:0, d:1, tx:dx, ty:dy)

func matRotate*(angle: float32): Transform =
  let c = cos(angle)
  let s = sin(angle)
  result=Transform(a:c, b:s, c:(-s), d:c, tx:0, ty:0)

func matScale*(sx, sy: float32): Transform =
  result=Transform(a:sx, b:0, c:0, d:sy, tx:0, ty:0)

func matShear*(shx, shy: float32): Transform =
  result=Transform(a:1, b:shy, c:shx, d:1, tx:0, ty:0)

func matInverse*(t: Transform): Transform =
  let det = t.a * t.d - t.b * t.c
  if abs(det) < 1e-6:
    return matIdentity()
  let invDet = 1.0 / det
  result.a =  t.d * invDet
  result.b = -t.b * invDet
  result.c = -t.c * invDet
  result.d =  t.a * invDet
  result.tx = (t.c*t.ty - t.d*t.tx) * invDet
  result.ty = (t.b*t.tx - t.a*t.ty) * invDet

proc newTransform*(x,y,r,sx,sy,ox,oy,kx,ky: float32): Transform =
  let cr = cos(r)
  let sr = sin(r)

  result.a  =  cr * sx + ky * sr * sy
  result.b  =  sr * sx + ky * cr * sy
  result.c  = -sr * sx + kx * cr * sy
  result.d  =  cr * sy + kx * sr * sy

  # translation (origin’e göre düzeltilmiş)
  result.tx = x - (result.a * ox + result.c * oy)
  result.ty = y - (result.b * ox + result.d * oy)

var globalTransform*: Transform = matIdentity()
var transformStack*: seq[Transform] = @[]

proc origin*() =
  globalTransform = matIdentity()

proc push*() =
  transformStack.add(globalTransform)

proc pop*() =
  if transformStack.len > 0:
    globalTransform = transformStack[^1]
    transformStack.setLen(transformStack.len-1)

proc translate*(dx, dy: float) =
  globalTransform = matMul(matTranslate(dx, dy), globalTransform)

proc rotate*(angle: float) =
  globalTransform = matMul(matRotate(angle), globalTransform)

proc scale*(sx, sy: float) =
  globalTransform = matMul(matScale(sx, sy), globalTransform)

proc shear*(shx, shy: float) =
  globalTransform = matMul(matShear(shx, shy), globalTransform)

proc transformPoint*(x, y: float): (float, float) =
  let t = globalTransform
  (t.a*x + t.c*y + t.tx, t.b*x + t.d*y + t.ty)

proc inverseTransformPoint*(x, y: float): (float, float) =
  let t = matInverse(globalTransform)
  result=(t.a*x + t.c*y + t.tx, t.b*x + t.d*y + t.ty)

proc replaceTransform*(t: Transform) =
  globalTransform = t

proc applyTransform*(t: Transform) =
  globalTransform = matMul(t, globalTransform)
### End of Fast 2D Transform Logic ###

type 
  Text* = object 
    str:string=""
    font:ptr rl.Font

  Font * = object
    rFont: rl.Font

  Texture *  = object
    rTexture*: rl.Texture2D
    width*:float=0.0
    height*:float=0.0

  Quad * = object
    x*:int
    y*:int
    w*:int
    h*:int
    sw*:int
    sh*:int

  SpriteBatch* = object
    textureID: uint32 = 0
    maxSpriteCount: int=1000
    data:seq[ (Quad,Transform) ]=newSeq[ (Quad,Transform) ]()
    defWidth:int=1
    defHeight:int=1



type 
  DrawModes* = enum Fill,Line
  ArcType* = enum Pie,Open,Closed

#Properties
var drawerColor:Color=Color()
var drawerLineWidth:float=1.0f
var currentFont:rl.Font = getFontDefault()


proc setFont*(font:rl.Font) =
  currentFont=font

proc getFont*():ptr rl.Font =
  result=addr currentFont



#Creators
proc newTexture*(filename:string):Texture =
  result=Texture(rTexture:loadTexture(filename))
  result.width=float(result.rTexture.width)
  result.height=float(result.rTexture.height)
  

proc newImage*(filename:string):rl.Image =
  var img=loadImage(filename)
  result=img
  



proc newText*(text:string, font:ptr rl.Font):Text =
  result=Text(str:text,font:font)


#Quad
proc newQuad*(x,y,width,height,sw,sh:int):Quad =
  result=Quad(x:x,y:y,w:width,h:height,sw:sw,sh:sh)

proc newQuad*(x,y,width,height:int, texture:var Texture):Quad =
  result=Quad(x:x,y:y,w:width,h:height,sw:texture.rTexture.width,sh:texture.rTexture.height)


  

#Sprite Batch
proc newSpriteBatch*(texture:var Texture, maxSprites:int=1000): SpriteBatch =
  
  result=SpriteBatch(textureID:texture.rTexture.id, maxSpriteCount:maxSprites )
  result.defWidth=texture.rTexture.width
  result.defHeight=texture.rTexture.height
  result.data=newSeq[(Quad,Transform)](maxSprites)


proc add*(spriteBatch: var SpriteBatch,x,y:float,r:float=0,sx:float=1,sy:float=1,ox:float=0,oy:float=0,kx:float=0,ky:float=0):int =
  var t:Transform=newTransform(x,y,r,sx,sy,ox,oy,kx,ky)
  let defWidth=spriteBatch.defWidth
  let defHeight=spriteBatch.defHeight
  var q=Quad(x:0,y:0,w:defWidth,h:defHeight,sw:defWidth,sh:defHeight)
  let id=spriteBatch.data.len
  spriteBatch.data.add( (q,t) )
  
  result=id

proc add*(spriteBatch: var SpriteBatch, quad:Quad, x,y:float,r:float=0,sx:float=1,sy:float=1,ox:float=0,oy:float=0,kx:float=0,ky:float=0):int =
  var t:Transform=newTransform(x,y,r,sx,sy,ox,oy,kx,ky)
  let defWidth=spriteBatch.defWidth
  let defHeight=spriteBatch.defHeight
  var q=quad
  let id=spriteBatch.data.len
  spriteBatch.data.add( (q,t) )
  
  result=id

proc clear*(spriteBatch: var SpriteBatch) =
  spriteBatch.data.setLen(0)
  





proc setColor* (r:uint8, g:uint8,b:uint8, a:uint8) =
    drawerColor=Color(r:r,g:g,b:b,a:a)

proc setColor* (color:Color) =
    drawerColor=color

proc getColor * () :Color =
  result=drawerColor

proc setLine*(width:float) =
    drawerLineWidth=width

proc getLine*():float =
  result=drawerLineWidth


proc polygon*(mode:DrawModes,points:varargs[float]) =
    var allPoints:seq[Vec2]
    for i in countup(0, points.len - 1, 2):
        var pTransformed=transformPoint(points[i],points[i+1])
        allPoints.add( Vec2( x:pTransformed[0],y:pTransformed[1]) )
    
    if mode==Fill :
      
      var tris=triangulate(allPoints)
      var counter:int=0
      for t in tris:
        drawTriangle(Vector2(x:t.c.x,y:t.c.y),Vector2(x:t.b.x,y:t.b.y),Vector2(x:t.a.x,y:t.a.y),drawerColor)
        
    else :
      for i in 0..<allPoints.len :
        var a,b:Vector2
        a=Vector2(x:allPoints[i].x,y:allPoints[i].y)
        if i<allPoints.len-1 :
          b=Vector2(x:allPoints[i+1].x,y:allPoints[i+1].y)
        else :
          b=Vector2(x:allPoints[0].x,y:allPoints[0].y)
        
        drawLine(a,b,drawerColor)

proc line*(points:varargs[float]) =
  if points.len mod 2 != 0:
    raise newException(ValueError, "Invalid points definition! Must be even number of coordinates.")

  var allPoints: seq[Vector2] = @[]
  for i in countup(0, points.len - 1, 2):
    let (px, py) = transformPoint(points[i], points[i+1])
    allPoints.add(Vector2(x:px, y:py))
  
  for i in countup(0, allPoints.len - 2, 1):
    let p1 = allPoints[i]
    let p2 = allPoints[i+1]
    drawLine(p1, p2, drawerLineWidth, drawerColor)

proc getArcPoints(x:float,y:float,radiusX:float,radiusY:float,angle1:float,angle2:float,segments:int=16):seq[float] =
  var angleBegin=angle1
  var angleDiff=angle2-angle1
  var angleStep=angleDiff/float(segments)

  var allPoints:seq[float]
  for i in 0..<segments :
    var ang=angleBegin+float(i)*angleStep
    allPoints.add(x+cos(ang)*radiusX)
    allPoints.add(y+sin(ang)*radiusY)

  return allPoints

proc arc*(mode:DrawModes,arcType:ArcType, x:float,y:float,radius:float,angle1:float,angle2:float,segments:int=16) =
  var pi:float=3.1415926
  var angleBegin=angle1
  var angleDiff=angle2-angle1
  var angleStep=angleDiff/float(segments)

  var allPoints:seq[float]=getArcPoints(x,y,radius,radius,angle1,angle2,segments)

  if arcType==Pie :
    allPoints.add(x)
    allPoints.add(y)
    allPoints.add(allPoints[0])
    allPoints.add(allPoints[1])
  elif arcType==Closed :
    allPoints.add(allPoints[0])
    allPoints.add(allPoints[1])

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    line(allPoints)

proc arc*(mode:DrawModes, x:float,y:float,radius:float,angle1:float,angle2:float,segments:int=16) =
  arc(mode,ArcType.Pie,x,y,radius,angle1,angle2,segments)

proc circle*(mode:DrawModes,x:float,y:float,radius:float) =
  let pi2=2*PI
  let min_segment=16
  let max_segment=128
  let circumference=pi2*radius
  var segments=int(circumference/4)
  segments=clamp(segments,min_segment,max_segment)

  var allPoints:seq[float]=getArcPoints(x,y,radius,radius,0,pi2,segments)

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    allPoints.add(allPoints[0])
    allPoints.add(allPoints[1])
    line(allPoints)

    

proc clear*() =
    clearBackground(drawerColor)


proc rectangle*(mode:DrawModes,x:float,y:float,width:float,height:float,rx:float=0,ry:float=rx,segments:int=12)=
    var allPoints:seq[float]
    if(rx==0 or ry==0) :    
      allPoints.add(x)
      allPoints.add(y)
      allPoints.add(x+width)
      allPoints.add(y)
      allPoints.add(x+width)
      allPoints.add(y+height)
      allPoints.add(x)
      allPoints.add(y+height)
    else :
      allPoints= getArcPoints(x+rx,y+ry,rx,ry,PI,3*PI/2,segments)
      allPoints.add( getArcPoints(x+width-rx,y+ry,rx,ry,3*PI/2,PI*2,segments) )
      allPoints.add( getArcPoints(x+width-rx,y+height-ry,rx,ry,0,PI/2,segments) )
      allPoints.add( getArcPoints(x+rx,y+height-ry,rx,ry,PI/2,PI,segments) )

    if allPoints.len>6 :
      if mode==Fill :
          polygon(Fill,allPoints)
      else :
          allPoints.add(allPoints[0])
          allPoints.add(allPoints[1])
          line(allPoints)

proc quad*(mode:DrawModes,x1:float,y1:float,x2:float,y2:float,x3:float,y3:float,x4:float,y4:float) =
    var allPoints:seq[float]
    allPoints.add(x1)
    allPoints.add(y1)
    allPoints.add(x2)
    allPoints.add(y2)
    allPoints.add(x3)
    allPoints.add(y3)
    allPoints.add(x4)
    allPoints.add(y4)

    if mode==Fill :
        polygon(Fill,allPoints)
    else :
        allPoints.add(allPoints[0])
        allPoints.add(allPoints[1])
        line(allPoints)

            
proc ellipse*(mode:DrawModes,x:float,y:float,radiusX:float,radiusY:float) =
  let pi2=2*PI
  let min_segment=16
  let max_segment=128
  let circumference1=pi2*radiusX
  let circumference2=pi2*radiusY
  var segments=int( max(circumference1/4,circumference2/4) )
  segments=clamp(segments,min_segment,max_segment)

  var allPoints:seq[float]
  let angleStep=pi2/float(segments)
  for i in 0..<segments :
    var ang=float(i)*angleStep
    allPoints.add(x+cos(ang)*radiusX)
    allPoints.add(y+sin(ang)*radiusY)

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    allPoints.add(allPoints[0])
    allPoints.add(allPoints[1])
    line(allPoints)
  

proc pixel*(x:float,y:float) =
  var (tx,ty)=transformPoint(x,y)
  drawPixel(int32(tx), int32(ty),drawerColor )




#Draw Textures 


proc draw*( texture:Texture, quad:Quad, x:float=0.0,y:float=0.0) =
  let p1x = x
  let p1y = y
  let p2x = x+float(quad.w)
  let p2y = y
  let p3x = x+float(quad.w)
  let p3y = y+float(quad.h)
  let p4x = x
  let p4y = y+float(quad.h)

  let (v1x, v1y) = transformPoint(p1x, p1y)
  let (v2x, v2y) = transformPoint(p2x, p2y)
  let (v3x, v3y) = transformPoint(p3x, p3y)
  let (v4x, v4y) = transformPoint(p4x, p4y)

  setTexture(texture.rTexture.id) # Bind texture
  rlBegin(Triangles)
  color4ub(drawerColor.r, drawerColor.g, drawerColor.b, drawerColor.a)

  #Quad normalized mapping
  let tcx1:float=quad.x/quad.sw
  let tcy1:float=quad.y/quad.sh
  let tcx2:float=tcx1+quad.w/quad.sw
  let tcy2:float=tcy1+quad.h/quad.sh

  

  

  # Triangle 1: v1, v2, v3
  texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
  texCoord2f(tcx2, tcy1); vertex2f(v2x, v2y)
  texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)

  # Triangle 2: v1, v3, v4
  texCoord2f(tcx1, tcy2); vertex2f(v4x, v4y)
  texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
  texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
  
  

  rlEnd()

  setTexture(0) # Unbind texture

proc draw*( texture:Texture,x:float=0.0,y:float=0.0) =
  var quad=newQuad(0,0,texture.rTexture.width,texture.rTexture.height,texture.rTexture.width,texture.rTexture.height)
  draw(texture,quad,x,y)

proc draw * ( spriteBatch:SpriteBatch, x:float=0,y:float=0) =

  setTexture(spriteBatch.textureID) # Bind texture
  color4ub(drawerColor.r, drawerColor.g, drawerColor.b, drawerColor.a)
  rlBegin(Triangles)

  
  for (q,t) in spriteBatch.data :
    push()
    
    translate(x,y)
    applyTransform(t)


    let p1x = float(q.x)
    let p1y = float(q.y)
    let p2x = float(q.x + q.w)
    let p2y = float(q.y)
    let p3x = float(q.x + q.w)
    let p3y = float(q.y + q.h)
    let p4x = float(q.x)
    let p4y = float(q.y + q.h)

    let (v1x, v1y) = transformPoint(p1x, p1y)
    let (v2x, v2y) = transformPoint(p2x, p2y)
    let (v3x, v3y) = transformPoint(p3x, p3y)
    let (v4x, v4y) = transformPoint(p4x, p4y)

    #Quad normalizd mapping
    let tcx1:float=q.x/q.sw
    let tcy1:float=q.y/q.sh
    let tcx2:float=tcx1+q.w/q.sw
    let tcy2:float=tcy1+q.h/q.sh

    

    # Triangle 1: v1, v2, v3
    texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
    texCoord2f(tcx2, tcy1); vertex2f(v2x, v2y)
    texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)

    # Triangle 2: v1, v3, v4
    texCoord2f(tcx1, tcy2); vertex2f(v4x, v4y)
    texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
    texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)

    pop()
    
  

  rlEnd()
  setTexture(0) # Unbind texture
  

proc draw*( text:Text ,x:float=0.0,y:float=0.0, size:float=16, spacing:float=1.0 ) =

  if text.font==nil :
    echo "Warning: font is nil, cannot draw text."
    return

  let t = globalTransform

  var matrixArray: array[16, float32]
  matrixArray[0] = t.a;   matrixArray[4] = t.c;   matrixArray[8] = 0.0;   matrixArray[12] = t.tx
  matrixArray[1] = t.b;   matrixArray[5] = t.d;   matrixArray[9] = 0.0;   matrixArray[13] = t.ty
  matrixArray[2] = 0.0;   matrixArray[6] = 0.0;   matrixArray[10] = 1.0;  matrixArray[14] = 0.0
  matrixArray[3] = 0.0;   matrixArray[7] = 0.0;   matrixArray[11] = 0.0;  matrixArray[15] = 1.0

  pushMatrix()
  multMatrixf(matrixArray)
  translatef(x,y,0.0)
  drawText(text.font[],text.str, Vector2(x:0, y:0),Vector2(x:0,y:0),0, size, spacing, drawerColor)
  
  popMatrix()
  discard


#Export raylib colors
export  rl.Color,LightGray,Gray,DarkGray,Yellow,Gold,Orange,Pink,Red,Maroon,Green,Lime,DarkGreen,SkyBlue,Blue,DarkBlue,Purple,Violet,DarkPurple,Beige,Brown,DarkBrown,White, Black,Blank,Magenta
export  rl.Font