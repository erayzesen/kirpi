#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE


import std/strutils
import algorithm
import std/unicode

import tables,os,hashes,options

import math
import triangulator



#backend
import backends/naylib/graphics_end


proc Color*(r,g,b,a:int):tuple[r,g,b,a:uint8] =
  result=(r:r.uint8,g:g.uint8,b:b.uint8,a:a.uint8)


#For easy hex colors
proc Color*(hex: string): tuple[r,g,b,a:uint8] =
  ## Converts a hexadecimal color string (e.g., "#d5e3ea" or "d5e3eaff") 
  let cleanedHex = hex.strip(leading = true, trailing = true).replace("#", "").toUpper()
  var hexValue: int = 0
  case cleanedHex.len:
  of 6:
    let hexWithAlpha = cleanedHex & "FF"
    hexValue = parseHexInt(hexWithAlpha)
  of 8:
    hexValue = parseHexInt(cleanedHex)

  else:
    return (r: 0, g: 0, b: 0, a: 0)

  result = (
    r: uint8(hexValue.uint32 shr 24 and 0xff),
    g: uint8(hexValue.uint32 shr 16 and 0xff),
    b: uint8(hexValue.uint32 shr 8 and 0xff),
    a: uint8(hexValue.uint32 and 0xff)
  )
  
  



const
  LightGray* = (r: 200.uint8, g: 200.uint8, b: 200.uint8, a: 255.uint8)
  Gray* = (r: 130.uint8, g: 130.uint8, b: 130.uint8, a: 255.uint8)
  DarkGray* = (r: 80.uint8, g: 80.uint8, b: 80.uint8, a: 255.uint8)
  Yellow* = (r: 253.uint8, g: 249.uint8, b: 0.uint8, a: 255.uint8)
  Gold* = (r: 255.uint8, g: 203.uint8, b: 0.uint8, a: 255.uint8)
  Orange* = (r: 255.uint8, g: 161.uint8, b: 0.uint8, a: 255.uint8)
  Pink* = (r: 255.uint8, g: 109.uint8, b: 194.uint8, a: 255.uint8)
  Red* = (r: 230.uint8, g: 41.uint8, b: 55.uint8, a: 255.uint8)
  Maroon* = (r: 190.uint8, g: 33.uint8, b: 55.uint8, a: 255.uint8)
  Green* = (r: 0.uint8, g: 228.uint8, b: 48.uint8, a: 255.uint8)
  Lime* = (r: 0.uint8, g: 158.uint8, b: 47.uint8, a: 255.uint8)
  DarkGreen* = (r: 0.uint8, g: 117.uint8, b: 44.uint8, a: 255.uint8)
  SkyBlue* = (r: 102.uint8, g: 191.uint8, b: 255.uint8, a: 255.uint8)
  Blue* = (r: 0.uint8, g: 121.uint8, b: 241.uint8, a: 255.uint8)
  DarkBlue* = (r: 0.uint8, g: 82.uint8, b: 172.uint8, a: 255.uint8)
  Purple* = (r: 200.uint8, g: 122.uint8, b: 255.uint8, a: 255.uint8)
  Violet* = (r: 135.uint8, g: 60.uint8, b: 190.uint8, a: 255.uint8)
  DarkPurple* = (r: 112.uint8, g: 31.uint8, b: 126.uint8, a: 255.uint8)
  Beige* = (r: 211.uint8, g: 176.uint8, b: 131.uint8, a: 255.uint8)
  Brown* = (r: 127.uint8, g: 106.uint8, b: 79.uint8, a: 255.uint8)
  DarkBrown* = (r: 76.uint8, g: 63.uint8, b: 47.uint8, a: 255.uint8)
  White* = (r: 255.uint8, g: 255.uint8, b: 255.uint8, a: 255.uint8)
  Black* = (r: 0.uint8, g: 0.uint8, b: 0.uint8, a: 255.uint8)
  Blank* = (r: 0.uint8, g: 0.uint8, b: 0.uint8, a: 0.uint8)
  Magenta* = (r: 255.uint8, g: 0.uint8, b: 255.uint8, a: 255.uint8)
  


### Transform Logic ###
# 2x3 affine matrix: [a, b, c, d, tx, ty] 
# [ a  c  tx ]
# [ b  d  ty ]
# [ 0  0  1  ]
type Transform* = object
  a,b,c,d,tx,ty: float

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

func matTranslate*(dx, dy: float): Transform =
  result=Transform(a:1, b:0, c:0, d:1, tx:dx, ty:dy)

func matRotate*(angle: float): Transform =
  let c = cos(angle)
  let s = sin(angle)
  result=Transform(a:c, b:s, c:(-s), d:c, tx:0, ty:0)

func matScale*(sx, sy: float): Transform =
  result=Transform(a:sx, b:0, c:0, d:sy, tx:0, ty:0)

func matShear*(shx, shy: float): Transform =
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


proc newTransform*(x, y, r, sx, sy, ox, oy, kx, ky: float): Transform =
  let 
    cr = cos(r)
    sr = sin(r)

  # Standard Affine 2D Matrix (Rotation -> Scale -> Skew)
  result.a  =  cr * sx - ky * sr * sy
  result.b  =  sr * sx + ky * cr * sy
  result.c  =  kx * cr * sx - sr * sy
  result.d  =  kx * sr * sx + cr * sy

  # Translation (According to the origin)
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
  globalTransform = matMul( globalTransform,matTranslate(dx, dy))

proc rotate*(angle: float) =
  globalTransform = matMul(globalTransform,matRotate(angle))

proc scale*(sx, sy: float) =
  globalTransform = matMul(globalTransform,matScale(sx, sy))

proc shear*(shx, shy: float) =
  globalTransform = matMul(globalTransform,matShear(shx, shy))

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

proc getAverageScale(t: Transform): float =
  let sx = sqrt(t.a*t.a + t.b*t.b)
  let sy = sqrt(t.c*t.c + t.d*t.d)
  result=(sx + sy) * 0.5

proc isOrientationFlipped(t: Transform): bool =
  (t.a * t.d - t.b * t.c) < 0  
### End of 2D Transform Logic ###


### Graphic Objects ###

type 
  
  JoinTypes* = enum
    Miter,
    Round,
    Bevel

  CapTypes* = enum 
    Square,
    Round,
    None

  TextureFilters* = enum 
    Default,
    Nearest,
    Linear

  FontBase = object
    id*:Hash
  
  Font* = ref FontBase
  
  Text* = object 
    str:string=""
    font:Font

  TextureBase = object 
    id: Hash
    width*:float=0.0
    height*:float=0.0
    filter:TextureFilters=TextureFilters.Default

  Texture *  = ref TextureBase
    

  Quad * = object
    x*:int
    y*:int
    w*:int
    h*:int
    sw*:int
    sh*:int

  SpriteBatch* = object
    textureID: Hash = 0
    maxSpriteCount: int=1000
    data:seq[ (Quad,Transform) ]=newSeq[ (Quad,Transform) ]()
    defWidth:int=1
    defHeight:int=1

  ShaderBase = object 
    id:Hash

  Shader* = ref ShaderBase


proc `=destroy`(x:TextureBase) =
  graphics_end.unloadTexture(x.id)

proc `=destroy`(x:FontBase) =
  graphics_end.unloadFont(x.id)

proc `=destroy`(x:ShaderBase) =
  graphics_end.unloadShader(x.id)
  

### End of Graphic Objects ###




### End of Resource Collections ###

### Draw State Logic ### 



var defaultFont*:Font
proc getDefaultFont*():var Font =
  result=defaultFont

type 
  DrawState = object 
    drawerColor:tuple[r,g,b,a:uint8]=White
    drawerLineWidth:float=1.0
    drawerLineJoin:JoinTypes=JoinTypes.Miter
    drawerLineBeginCap:CapTypes=CapTypes.None
    drawerLineEndCap:CapTypes=CapTypes.None
    currentFont:Font
    
    
var globalDrawState:DrawState=DrawState()
var stateStack*: seq[DrawState] = @[]


proc pushState*() =
  stateStack.add(globalDrawState)

proc popState*() =
  if stateStack.len > 0:
    globalDrawState = stateStack[^1]
    stateStack.setLen(stateStack.len-1)

proc resetState*() =
  globalDrawState=DrawState()
  globalDrawState.currentFont=getDefaultFont()


proc setFont*(font:Font) =
  globalDrawState.currentFont=font

proc getFont*():Font =
  result=globalDrawState.currentFont


proc setColor* (r:int, g:int,b:int, a:int) =
    globalDrawState.drawerColor=(r:r.uint8,g:g.uint8,b:b.uint8,a:a.uint8)

proc setColor* (color:tuple[r,g,b,a:uint8]) =
    globalDrawState.drawerColor=color

proc setColor* (hexColor:string) =
    globalDrawState.drawerColor=Color(hexColor)

proc getColor * () : tuple[r,g,b,a:uint8] =
  result=globalDrawState.drawerColor

proc setLine*(width:float,joinType:JoinTypes=JoinTypes.Miter,beginCap:CapTypes=CapTypes.None,endCap:CapTypes=beginCap) =
    globalDrawState.drawerLineWidth=width
    globalDrawState.drawerLineJoin=joinType
    globalDrawState.drawerLineBeginCap=beginCap
    globalDrawState.drawerLineEndCap=endCap

proc setLineWidth*(width:float) =
  globalDrawState.drawerLineWidth=width

proc setLineJoin*(joinType:JoinTypes) =
  globalDrawState.drawerLineJoin=joinType

proc setLineCaps*(beginCap:CapTypes,endCap:CapTypes=beginCap) =
  globalDrawState.drawerLineBeginCap=beginCap
  globalDrawState.drawerLineEndCap=endCap

proc getLineWidth*():float =
  result=globalDrawState.drawerLineWidth

proc getLineJoin*():JoinTypes =
  result=globalDrawState.drawerLineJoin

proc getLineBeginCap*():CapTypes =
  result=globalDrawState.drawerLineBeginCap

proc getLineEndCap*():CapTypes =
  result=globalDrawState.drawerLineEndCap

proc setShader*(shader:var Shader) =
  graphics_end.beginShader(shader.id)

proc setShader*() =
  graphics_end.endShader()


### End of Draw State Logic ###

type 
  DrawModes* = enum Fill,Line
  ArcType* = enum Pie,Open,Closed






var defaultFilter*:TextureFilters=TextureFilters.Linear

### Graphic Object Creators ###

proc newTexture*(filename:string, filter:TextureFilters=Default):Texture =
  
  
  var antialias_enabled=false
  if filter==TextureFilters.Default :
    if defaultFilter==TextureFilters.Linear :
      antialias_enabled=true
    else :
      antialias_enabled=false
  else :
    if filter==TextureFilters.Linear :
      antialias_enabled=true
    else :
      antialias_enabled=false

  var textureID=graphics_end.loadTextureFile(filename,antialias_enabled)
  result=Texture(id:textureID )
  result.filter=filter
  result.width=graphics_end.getTextureWidth(textureID).float
  result.height=graphics_end.getTextureHeight(textureID).float


  

proc newFont*(filename:string, antialias:bool=true, rasterSize:int=32): Font =
  var fontID=graphics_end.loadFontFile(filename,antialias,rasterSize)
  result=Font(id:fontID)




proc newShader*(shaderFolderPath:string,shaderName:string): Shader =
  var shaderID=graphics_end.loadShaderFile(shaderFolderPath,shaderName) 
  result=Shader(id:shaderID)
  


#Text
proc newText*(text:string, font:var Font):Text =
  result=Text(str:text,font:font)




#Quad
proc newQuad*(x,y,width,height,sw,sh:int):Quad =
  result=Quad(x:x,y:y,w:width,h:height,sw:sw,sh:sh)

proc newQuad*(x,y,width,height:int, texture:var Texture):Quad =
  result=Quad(x:x,y:y,w:width,h:height,sw:texture.width.int,sh:texture.height.int)

  

#Sprite Batch
proc newSpriteBatch*(texture:var Texture, maxSprites:int=1000): SpriteBatch =
  
  result=SpriteBatch(textureID:texture.id, maxSpriteCount:maxSprites )
  result.defWidth=texture.width.int
  result.defHeight=texture.height.int
  result.data=newSeq[(Quad,Transform)](maxSprites)


### End of Graphic Object Creators ###

### Text Methods ###

proc getSizeWith*(text:Text,fontSize:float,spacing:float=1.0) :tuple[x:float,y:float] =
  result=graphics_end.getTextSizeWithFont(text.font.id,text.str,fontSize,spacing)
  



### End of Text Methods ###

### Sprite Batcher Methods ###
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
  var q=quad
  let id=spriteBatch.data.len
  spriteBatch.data.add( (q,t) )
  
  result=id

proc clear*(spriteBatch: var SpriteBatch) =
  spriteBatch.data.setLen(0)
  
### End of Sprite Batcher Methods ###

### Shader Methods ###
proc setValue*(shader:var Shader, uniformName: string, value: float) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: int) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var  Shader, uniformName: string, value: (float,float)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: (float,float,float)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: (float,float,float,float)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: (int,int)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: (int,int,int)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, value: (int,int,int,int)) =
  graphics_end.setShaderUniform(shader.id,uniformName,value)

proc setValue*(shader:var Shader, uniformName: string, texture:var Texture) =
  graphics_end.setShaderTextureValue(shader.id,uniformName,texture.id)






### End of Shader Methods ###


### Drawing Operations ###

#[ proc pixel*(x:float,y:float) =
  var (tx,ty)=transformPoint(x,y)
  drawPixel(int32(tx), int32(ty),globalDrawState.drawerColor ) ]#


        

proc getSmoothSegmentCount(angleDiff: float, radius: float, scaleFactor: float): int =
  let segStep=5.0
  let circumference = 2 * PI * (radius * scaleFactor)
  let fullCount=circumference/segStep
  var seg = ceil(fullCount * (abs(angleDiff)/TAU) )
  if seg < 6: seg = 6       # minimum 
  if seg > 200: seg = 200   # maksimum 
  result=int(seg)


proc getArcPoints(x:float,y:float,radiusX:float,radiusY:float,angle1:float,angle2:float,segments:int=16):seq[float] =
  var angleBegin=angle1
  var angleDiff=angle2-angle1
  var angleStep=angleDiff/float(segments)

  var allPoints:seq[float]
  for i in 0..segments :
    var ang=angleBegin+float(i)*angleStep
    allPoints.add(x+cos(ang)*radiusX)
    allPoints.add(y+sin(ang)*radiusY)

  return allPoints


proc isCCW(ax,ay,bx,by,cx,cy:float) :bool =
  let v:float= (bx - ax)*(cy - ay) - (by - ay)*(cx - ax);
  result=v>0


proc lineIntersection*(A, B, C, D: tuple[x,y:float]): Option[tuple[x,y:float]] =
  let
    s1x = B.x - A.x
    s1y = B.y - A.y
    s2x = D.x - C.x
    s2y = D.y - C.y
    denom = -s2x * s1y + s1x * s2y

  if abs(denom) < 1e-6:  # parallel
    return none(tuple[x,y:float])

  let
    s = (-s1y * (A.x - C.x) + s1x * (A.y - C.y)) / denom
    t = ( s2x * (A.y - C.y) - s2y * (A.x - C.x)) / denom

  if t >= 0.0 and t <= 1.0 and s >= 0.0 and s <= 1.0:
    let ix = A.x + t * s1x
    let iy = A.y + t * s1y
    return some((x: ix, y: iy))
  else:
    return none(tuple[x,y:float])

proc line*(points:varargs[float]) =
  if points.len mod 2 != 0:
    raise newException(ValueError, "Invalid points definition! Must be even number of coordinates.")

  if points.len<4:
    raise newException(ValueError, "Invalid points definition! Needs a minimum of two points to draw a line.")

  var allPoints: seq[tuple[x,y:float]] = @[]
  for i in countup(0, points.len - 1, 2):
    #Filtering same points
    if i>0 :
      if (points[i]==points[i-2] and points[i+1]==points[i-1])  :
        continue
    allPoints.add((x:points[i], y:points[i+1]))

  var tris: seq[tuple[x,y,uvx,uvy:float]] = @[]

  let halfLineWidth=globalDrawState.drawerLineWidth*0.5

  #PreCalculate Full Smooth Segment Count for Rounded Cap,Join
  
  var maxScale=getAverageScale(globalTransform)
  var fullSmoothSegCount:int=getSmoothSegmentCount(TAU,halfLineWidth,maxScale)
  var divTAU:float=1/TAU
  var roundedCapSegCount:int=6
  if globalDrawState.drawerLineBeginCap==CapTypes.Round or globalDrawState.drawerLineEndCap==CapTypes.Round :
    roundedCapSegCount=max( int(float(fullSmoothSegCount)*0.5) , roundedCapSegCount )

  
  if globalDrawState.drawerLineWidth>0.0 :
    if allPoints.len>2 :
      
      var isClosedPoly=false
      var pointsLen=allPoints.len
      if allPoints[0]==allPoints[allPoints.len-1] :
        #Closed Poly Lines Exception
        pointsLen=allPoints.len+1
        isClosedPoly=true
      
      var prevIntersectionTestTop:Option[tuple[x,y:float]]=none(tuple[x,y:float])
      var prevIntersectionTestDown:Option[tuple[x,y:float]]=none(tuple[x,y:float])
      var p1,p2,p3:tuple[x,y:float]
      for i in 0..<pointsLen-2:
        if i==allPoints.len-2 :
          #Closed Poly Lines Exception
          p1=allPoints[allPoints.len-2]
          p2=allPoints[allPoints.len-1]
          p3=allPoints[1]
        else :
          #Default 
          p1=allPoints[i]
          p2=allPoints[i+1]
          p3=allPoints[i+2]

        let seg1=(x:p2.x-p1.x,y:p2.y-p1.y)
        let seg1Len=sqrt(seg1.x*seg1.x+seg1.y*seg1.y)
        let seg1Unit=(x:seg1.x/seg1Len,y:seg1.y/seg1Len)
        let seg1Normal=(x: seg1Unit.y,y: -seg1Unit.x)
        

        let seg2=(x:p3.x-p2.x,y:p3.y-p2.y)
        let seg2Len=sqrt(seg2.x*seg2.x+seg2.y*seg2.y)
        let seg2Unit=(x:seg2.x/seg2Len,y:seg2.y/seg2Len)
        let seg2Normal=(x: seg2Unit.y,y: -seg2Unit.x)

        

        let segBetween=(x:p3.x-p1.x,y:p3.y-p1.y)
        let segBetweenPerp=(x: segBetween.y,y: -segBetween.x)

        var normalSide:float
        var projectToBetween=seg1.x*segBetweenPerp.x+seg1.y*segBetweenPerp.y

        if projectToBetween>0 :
          normalSide= 1.0
        elif projectToBetween<0 :
          normalSide= -1.0

        #Drawing Line with Triangles
        
        var s1a=(x:p1.x+seg1Normal.x*halfLineWidth,y:p1.y+seg1Normal.y*halfLineWidth)
        var s1b=(x:p2.x+seg1Normal.x*halfLineWidth,y:p2.y+seg1Normal.y*halfLineWidth)
        var s1c=(x:p2.x-seg1Normal.x*halfLineWidth,y:p2.y-seg1Normal.y*halfLineWidth)
        var s1d=(x:p1.x-seg1Normal.x*halfLineWidth,y:p1.y-seg1Normal.y*halfLineWidth)

        var s2a=(x:p2.x+seg2Normal.x*halfLineWidth,y:p2.y+seg2Normal.y*halfLineWidth)
        var s2b=(x:p3.x+seg2Normal.x*halfLineWidth,y:p3.y+seg2Normal.y*halfLineWidth)
        var s2c=(x:p3.x-seg2Normal.x*halfLineWidth,y:p3.y-seg2Normal.y*halfLineWidth)
        var s2d=(x:p2.x-seg2Normal.x*halfLineWidth,y:p2.y-seg2Normal.y*halfLineWidth)

        

        var intersectionTestTop=lineIntersection(s1a,s1b,s2a,s2b)
        if intersectionTestTop.isSome :
          s1b=intersectionTestTop.get()
          s2a=s1b
          

        var intersectionTestDown=lineIntersection(s1d,s1c,s2d,s2c)
        if intersectionTestDown.isSome :
          s1c=intersectionTestDown.get()
          s2d=intersectionTestDown.get()
          

        if prevIntersectionTestTop.isSome :
          s1a=prevIntersectionTestTop.get()
          
        if prevIntersectionTestDown.isSome :
          s1d=prevIntersectionTestDown.get()

        #Implementing Caps
        #Begin Caps
        if isClosedPoly==false :
          if i==0 :
            
            if globalDrawState.drawerLineBeginCap==CapTypes.Round :
              let radius=halfLineWidth
              let beginAngle=arctan2(-seg1Normal.y,-seg1Normal.x)
              let endAngle=beginAngle+PI
              
              var arcPoints=getArcPoints( p1.x,p1.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
              for n in countup(0, arcPoints.len - 3, 2) :
                var ax,ay,bx,by:float
                #Fill Arc
                ax=arcPoints[n]
                ay=arcPoints[n+1]
                bx=arcPoints[n+2]
                by=arcPoints[n+3]

                tris.add( (x:p1.x, y: p1.y, uvx: 0.0 , uvy: 0.0) )
                tris.add( (x: bx, y: by, uvx: 0.0 , uvy: 0.0) )
                tris.add( (x: ax, y: ay, uvx: 0.0 , uvy: 0.0) )
            elif globalDrawState.drawerLineBeginCap==CapTypes.Square :
              s1a=(x:s1a.x-seg1Unit.x*halfLineWidth,y:s1a.y-seg1Unit.y*halfLineWidth)
              s1d=(x:s1d.x-seg1Unit.x*halfLineWidth,y:s1d.y-seg1Unit.y*halfLineWidth)
              
          #End Caps
          if i==allPoints.len-3 :
            if globalDrawState.drawerLineEndCap==CapTypes.Round :
              let radius=halfLineWidth
              let beginAngle=arctan2(seg2Normal.y,seg2Normal.x)
              let endAngle=beginAngle+PI
              var arcPoints=getArcPoints( p3.x,p3.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
              for n in countup(0, arcPoints.len - 3, 2) :
                var ax,ay,bx,by:float
                #Fill Arc
                ax=arcPoints[n]
                ay=arcPoints[n+1]
                bx=arcPoints[n+2]
                by=arcPoints[n+3]

                tris.add( (x: p3.x, y: p3.y, uvx: 0.0 , uvy: 0.0) )
                tris.add( (x: bx, y: by, uvx: 0.0 , uvy: 0.0)  )
                tris.add( (x: ax, y: ay, uvx: 0.0 , uvy: 0.0) )
            elif globalDrawState.drawerLineEndCap==CapTypes.Square :
              s2b=(x:s2b.x+seg2Unit.x*halfLineWidth,y:s2b.y+seg2Unit.y*halfLineWidth)
              s2c=(x:s2c.x+seg2Unit.x*halfLineWidth,y:s2c.y+seg2Unit.y*halfLineWidth)
              
          
        #Drawing Line Segment-1 Quad
        tris.add( (x: s1c.x, y: s1c.y, uvx: 0.0 , uvy: 0.0))
        tris.add( (x: s1b.x, y: s1b.y, uvx: 0.0 , uvy: 0.0))
        tris.add( (x: s1a.x, y: s1a.y, uvx: 0.0 , uvy: 0.0))

        
        tris.add( (x: s1d.x, y: s1d.y, uvx: 0.0 , uvy: 0.0) )
        tris.add( (x: s1c.x, y: s1c.y, uvx: 0.0 , uvy: 0.0))
        tris.add( (x: s1a.x, y: s1a.y, uvx: 0.0 , uvy: 0.0))

        #Drawing Line Last Segment Quad
        if i==allPoints.len-3 :
          tris.add( (x: s2c.x, y: s2c.y, uvx: 0.0 , uvy: 0.0))
          tris.add( (x: s2b.x, y: s2b.y, uvx: 0.0 , uvy: 0.0))
          tris.add( (x: s2a.x, y: s2a.y, uvx: 0.0 , uvy: 0.0))

          
          tris.add( (x: s2d.x, y: s2d.y, uvx: 0.0 , uvy: 0.0) )
          tris.add( (x: s2c.x, y: s2c.y, uvx: 0.0 , uvy: 0.0))
          tris.add( (x: s2a.x, y: s2a.y, uvx: 0.0 , uvy: 0.0))

        
        #Implementing Join Types
        let np1=if normalSide == -1 : s1c else : s1b
    
        let np2=if normalSide == -1 : s2d else : s2a

        var npc= if normalSide == -1.0 : s1b else :s1c

        

        if globalDrawState.drawerLineJoin==JoinTypes.Miter :
          var npcTop2=(x:npc.x-p2.x,y:npc.y-p2.y)
          var np3 = (x:p2.x-npcTop2.x,y:p2.y-npcTop2.y)
          var np3Top2=(x:np3.x-p2.x,y:np3.y-p2.y)
          if (np3Top2.x*np3Top2.x+np3Top2.y*np3Top2.y)>globalDrawState.drawerLineWidth*globalDrawState.drawerLineWidth:
            np3=(x:(np1.x+np2.x)*0.5,y:(np1.y+np2.y)*0.5 )
            
          if normalSide == -1.0 :
            tris.add( (x: np3.x, y: np3.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np1.x, y: np1.y, uvx: 0.0 , uvy: 0.0) )
            
            tris.add( (x: np3.x, y: np3.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np2.x, y: np2.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
          else :
            
            tris.add( (x: np1.x, y: np1.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np3.x, y: np3.y, uvx: 0.0 , uvy: 0.0) )
            
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np2.x, y: np2.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np3.x, y: np3.y, uvx: 0.0 , uvy: 0.0) )

          
        elif globalDrawState.drawerLineJoin==JoinTypes.Bevel :
          if normalSide == -1.0 :
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np1.x, y: np1.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np2.x, y: np2.y, uvx: 0.0 , uvy: 0.0) )
          else :
            tris.add( (x: np2.x, y: np2.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: np1.x, y: np1.y, uvx: 0.0 , uvy: 0.0) )
            tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
        
        elif globalDrawState.drawerLineJoin==JoinTypes.Round :
          
          var radius=halfLineWidth
          var p2Tonp1=(x:np1.x-p2.x,y:np1.y-p2.y)
          var p2Tonp2=(x:np2.x-p2.x,y:np2.y-p2.y)
          var beginAngle=arctan2(p2Tonp1.y,p2Tonp1.x)

          

          let dot = p2Tonp1.x*p2Tonp2.x + p2Tonp1.y*p2Tonp2.y;
          let det = p2Tonp1.x*p2Tonp2.y - p2Tonp1.y*p2Tonp2.x;
          var angDiff:float=arctan2(det,dot)

          let angRate=abs(angDiff)*divTAU
          let segCount=max( int( float(fullSmoothSegCount)*angRate),6 )
          var arcPoints=getArcPoints( p2.x,p2.y,radius,radius,beginAngle,(beginAngle+angDiff),segCount )
          for n in countup(0, arcPoints.len - 3, 2) :
            var ax,ay,bx,by:float

          
            #Fill Arc
            
            ax=arcPoints[n]
            ay=arcPoints[n+1]

            
            bx=arcPoints[n+2]
            by=arcPoints[n+3]

            if n==0 :
              ax=np1.x
              ay=np1.y
            else:
              ax=arcPoints[n]
              ay=arcPoints[n+1]

            if n==arcPoints.len-4 :
              bx=np2.x
              by=np2.y
            else :
              bx=arcPoints[n+2]
              by=arcPoints[n+3]
            
                
            if normalSide == -1.0 :
              tris.add( (x: bx, y: by, uvx: 0.0 , uvy: 0.0) )
              tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
              tris.add( (x: ax, y: ay, uvx: 0.0 , uvy: 0.0) )
              discard
              
            else :
              tris.add( (x: ax, y: ay, uvx: 0.0 , uvy: 0.0) )
              tris.add( (x: npc.x, y: npc.y, uvx: 0.0 , uvy: 0.0) )
              tris.add( (x: bx, y: by, uvx: 0.0 , uvy: 0.0) )
              discard
              
          

        prevIntersectionTestDown=intersectionTestDown
        prevIntersectionTestTop=intersectionTestTop
      
      
    elif allPoints.len==2 : # One line 
      let p1=allPoints[0]
      let p2=allPoints[1]
      let seg=(x:p2.x-p1.x,y:p2.y-p1.y)
      let segLen=sqrt(seg.x*seg.x+seg.y*seg.y)
      let segUnit=(x:seg.x/segLen,y:seg.y/segLen)
      let segNormal= (x: segUnit.y, y: -segUnit.x)

      var sa=(x:p1.x+segNormal.x*halfLineWidth,y:p1.y+segNormal.y*halfLineWidth)
      var sb=(x:p2.x+segNormal.x*halfLineWidth,y:p2.y+segNormal.y*halfLineWidth)
      var sc=(x:p2.x-segNormal.x*halfLineWidth,y:p2.y-segNormal.y*halfLineWidth)
      var sd=(x:p1.x-segNormal.x*halfLineWidth,y:p1.y-segNormal.y*halfLineWidth)

      
      if globalDrawState.drawerLineBeginCap==CapTypes.Round :
        let radius=halfLineWidth
        let beginAngle=arctan2(-segNormal.y,-segNormal.x)
        let endAngle=beginAngle+PI
        var arcPoints=getArcPoints( p1.x,p1.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
        for n in countup(0, arcPoints.len - 3, 2) :
          var ax,ay,bx,by:float
          #Fill Arc
          ax=arcPoints[n]
          ay=arcPoints[n+1]
          bx=arcPoints[n+2]
          by=arcPoints[n+3]

          tris.add( (x:p1.x, y: p1.y, uvx: 0.0 , uvy: 0.0))
          tris.add( (x:bx, y: by, uvx: 0.0 , uvy: 0.0) )
          tris.add( (x:ax, y: ay, uvx: 0.0 , uvy: 0.0))
      elif globalDrawState.drawerLineBeginCap==CapTypes.Square :
        sa=(x:sa.x-segUnit.x*halfLineWidth,y:sa.x-segUnit.y*halfLineWidth)
        sd=(x:sd.x-segUnit.x*halfLineWidth,y:sd.y-segUnit.y*halfLineWidth)
    
      if globalDrawState.drawerLineEndCap==CapTypes.Round :
        let radius=halfLineWidth
        let beginAngle=arctan2(segNormal.y,segNormal.x)
        let endAngle=beginAngle+PI
        var arcPoints=getArcPoints( p2.x,p2.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
        for n in countup(0, arcPoints.len - 3, 2) :
          var ax,ay,bx,by:float
          #Fill Arc
          ax=arcPoints[n]
          ay=arcPoints[n+1]
          bx=arcPoints[n+2]
          by=arcPoints[n+3]

          tris.add( (x:p2.x, y: p2.y, uvx: 0.0 , uvy: 0.0))
          tris.add( (x:bx, y: by, uvx: 0.0 , uvy: 0.0) )
          tris.add( (x:ax, y: ay, uvx: 0.0 , uvy: 0.0))
      elif globalDrawState.drawerLineEndCap==CapTypes.Square :
        sb=(x:sb.x+segUnit.x*halfLineWidth,y:sb.y+segUnit.y*halfLineWidth)
        sc=(x:sc.x+segUnit.x*halfLineWidth,y:sc.y+segUnit.y*halfLineWidth)

      #Drawing Segment-1 Quad
      tris.add( (x:sc.x, y: sc.y, uvx: 0.0 , uvy: 0.0))
      tris.add( (x:sb.x, y: sb.y, uvx: 0.0 , uvy: 0.0))
      tris.add( (x:sa.x, y: sa.y, uvx: 0.0 , uvy: 0.0))

      
      tris.add( (x:sd.x, y: sd.y, uvx: 0.0 , uvy: 0.0) )
      tris.add( (x:sc.x, y: sc.y, uvx: 0.0 , uvy: 0.0))
      tris.add( (x:sa.x, y: sa.y, uvx: 0.0 , uvy: 0.0))
    

    #Drawing All Triangles
    for i in 0..<tris.len: 
      var tp=transformPoint(tris[i].x,tris[i].y)
      tris[i]=(x:tp[0],y: tp[1], uvx: 0.0 , uvy: 0.0) 
    var isTransformMirrored:bool=globalTransform.isOrientationFlipped()
    if isTransformMirrored :
      for n in countup(0, tris.len - 3, 3) :
        let 
          tmpTri1=tris[n]
          tmpTri2=tris[n+1]
          tmpTri3=tris[n+2]
        tris[n]=tmpTri3
        tris[n+1]=tmpTri2
        tris[n+2]=tmpTri1
        
    
    graphics_end.renderGeometry(tris,globalDrawState.drawerColor)
    
    
    


proc polygon*(mode:DrawModes,points:varargs[float]) =
    var allPoints:seq[tuple[x,y:float]]
    for i in countup(0, points.len - 1, 2):
        var pTransformed=transformPoint(points[i],points[i+1])
        allPoints.add( ( x:pTransformed[0],y:pTransformed[1]) )
        
    
    if mode==Fill :
      var isTransformMirrored:bool=globalTransform.isOrientationFlipped()
      if isTransformMirrored :
        allPoints.reverse()
      
      var tris=triangulate(allPoints)
      var trianglePoints : seq[tuple[x,y,uvx,uvy:float] ] = @[]
      for t in countup(0,tris.len-3,3):
        
        trianglePoints.add( (x:tris[t+2].x.float, y:tris[t+2].y.float, uvx:0.0.float , uvy:0.0.float) )
        trianglePoints.add( (x:tris[t+1].x.float, y:tris[t+1].y.float, uvx:0.0.float , uvy:0.0.float) )
        trianglePoints.add( (x:tris[t].x.float, y:tris[t].y.float, uvx:0.0.float , uvy:0.0.float) )
        
      graphics_end.renderGeometry(trianglePoints,globalDrawState.drawerColor)
        
        
    else :
      var lines:seq[float]
      for i in 0..<allPoints.len :
        lines.add(allPoints[i].x)
        lines.add(allPoints[i].y)
        if i<allPoints.len-1 :
          lines.add(allPoints[0].x)
          lines.add(allPoints[0].y)
        
        line(lines)
    





proc arc*(mode:DrawModes,arcType:ArcType, x:float,y:float,radius:float,angle1:float,angle2:float,segments:int=16) =
  
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
  
  var maxScale=getAverageScale(globalTransform)
  var segments:int=getSmoothSegmentCount(TAU,radius,maxScale)

  var allPoints:seq[float]=getArcPoints(x,y,radius,radius,0,TAU,segments)

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    line(allPoints)

    

proc clear*() =
    graphics_end.clearCanvas(globalDrawState.drawerColor)

proc clear*(color:tuple[r,g,b,a:uint8]) =
    graphics_end.clearCanvas(color)

proc clear*(hexColor:string) =
    graphics_end.clearCanvas(Color(hexColor))


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
  var maxScale=getAverageScale(globalTransform)
  var maxRadius=max(radiusX,radiusY)
  var segments:int=getSmoothSegmentCount(TAU,maxRadius,maxScale)

  var allPoints:seq[float]
  let angleStep=TAU/float(segments)
  for i in 0..segments :
    var ang=float(i)*angleStep
    allPoints.add(x+cos(ang)*radiusX)
    allPoints.add(y+sin(ang)*radiusY)

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    line(allPoints)
  






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

  
  #Quad normalized mapping
  let tcx1:float=quad.x/quad.sw
  let tcy1:float=quad.y/quad.sh
  let tcx2:float=tcx1+quad.w/quad.sw
  let tcy2:float=tcy1+quad.h/quad.sh
  
  var isTransformMirrored:bool=globalTransform.isOrientationFlipped()

  var trianglePoints : seq[tuple[x,y,uvx,uvy:float] ] = @[]

  if isTransformMirrored :
    # Triangle 1: v1, v2, v3

    trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )
    trianglePoints.add( (x:v2x,y:v2y,uvx:tcx2,uvy:tcy1) )
    trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )

    trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )
    trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
    trianglePoints.add( (x:v4x,y:v4y,uvx:tcx1,uvy:tcy2) )
    
    
  else :

    
    # Triangle 1: v3, v2, v1
    trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
    trianglePoints.add( (x:v2x,y:v2y,uvx:tcx2,uvy:tcy1) )
    trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )

    # Triangle 2: v1, v3, v4
    trianglePoints.add( (x:v4x,y:v4y,uvx:tcx1,uvy:tcy2) )
    trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
    trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )
  
  var textureRawID=graphics_end.getTextureDataID(texture.id)
  graphics_end.renderGeometry(trianglePoints,globalDrawState.drawerColor,textureRawID)
    

  

proc draw*( texture:Texture,x:float=0.0,y:float=0.0) =
  var quad=newQuad(0,0,texture.width.int,texture.height.int,texture.width.int,texture.height.int)
  draw(texture,quad,x,y)

proc draw * ( spriteBatch:SpriteBatch, x:float=0,y:float=0) =

  

  var trianglePoints : seq[tuple[x,y,uvx,uvy:float] ] = @[]

  for (q,t) in spriteBatch.data :
    push()
    
    translate(x,y)
    applyTransform(t)

    let p1x = 0.0
    let p1y = 0.0
    let p2x = q.w.float
    let p2y = 0.0
    let p3x = q.w.float
    let p3y = q.h.float
    let p4x = 0.0
    let p4y = q.h.float

    let (v1x, v1y) = transformPoint(p1x, p1y)
    let (v2x, v2y) = transformPoint(p2x, p2y)
    let (v3x, v3y) = transformPoint(p3x, p3y)
    let (v4x, v4y) = transformPoint(p4x, p4y)

    #Quad normalizd mapping
    let tcx1:float=q.x/q.sw
    let tcy1:float=q.y/q.sh
    let tcx2:float=tcx1+q.w/q.sw
    let tcy2:float=tcy1+q.h/q.sh

    var isTransformMirrored:bool=globalTransform.isOrientationFlipped()

    
    if isTransformMirrored==false :

      # Triangle 1: v3, v2, v1
      trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
      trianglePoints.add( (x:v2x,y:v2y,uvx:tcx2,uvy:tcy1) )
      trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )

      # Triangle 2: v1, v3, v4
      trianglePoints.add( (x:v4x,y:v4y,uvx:tcx1,uvy:tcy2) )
      trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
      trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )

    else :
      # Negative scale values exception  (inverse faces)

      # Triangle 1: v1, v2, v3
      trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )
      trianglePoints.add( (x:v2x,y:v2y,uvx:tcx2,uvy:tcy1) )
      trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )

      # Triangle 2: v1, v3, v4
      trianglePoints.add( (x:v1x,y:v1y,uvx:tcx1,uvy:tcy1) )
      trianglePoints.add( (x:v3x,y:v3y,uvx:tcx2,uvy:tcy2) )
      trianglePoints.add( (x:v4x,y:v4y,uvx:tcx1,uvy:tcy2) )

    pop()

  graphics_end.renderGeometry(trianglePoints,globalDrawState.drawerColor,spriteBatch.textureID)
    
  

  

proc draw*( text:Text ,x:float=0.0,y:float=0.0, size:float=16, spacing:float=1.0 ) =
  
  if not graphics_end.isFontIDValid(text.font.id):
    echo "Warning: font is nil, cannot draw text."
    return

  let scale = size / graphics_end.getFontBaseSize(text.font.id)

  var penX = 0.0 
  var penY = 0.0

  let sw = graphics_end.getFontTextureWidth(text.font.id)
  let sh = graphics_end.getFontTextureHeight(text.font.id)

  var isTransformMirrored:bool=globalTransform.isOrientationFlipped()


  var trianglePoints : seq[tuple[x,y,uvx,uvy:float] ] = @[]

  for ch in text.str:
    if ch == '\n':
      penX = 0
      penY += graphics_end.getFontBaseSize(text.font.id) * scale
      continue

    let glyphQuad=graphics_end.getGlyphTextureQuad(text.font.id,toRunes($ch)[0])
    if glyphQuad.w == -1 and glyphQuad.h == -1: continue

    let glyphOffset=graphics_end.getGlyphOffset(text.font.id,toRunes($ch)[0])

    # Local quad (text space)
    let lx0 = x + (penX + glyphOffset.x) 
    let ly0 = y + (penY + glyphOffset.y*scale) 
    let lx1 = lx0 + glyphQuad.w * scale
    let ly1 = ly0 + glyphQuad.h * scale

    # World space 
    let (x0,y0) = transformPoint(lx0, ly0)
    let (x1,y1) = transformPoint(lx1, ly0)
    let (x2,y2) = transformPoint(lx1, ly1)
    let (x3,y3) = transformPoint(lx0, ly1)

    let u0 = glyphQuad.x / sw
    let v0 = glyphQuad.y / sh
    let u1 = (glyphQuad.x + glyphQuad.w) / sw
    let v1 = (glyphQuad.y + glyphQuad.h) / sh
    
    if isTransformMirrored :

      # Triangle 1
      trianglePoints.add( (x:x0,y:y0,uvx:u0,uvy:v0) )
      trianglePoints.add( (x:x1,y:y1,uvx:u1,uvy:v0) )
      trianglePoints.add( (x:x2,y:y2,uvx:u1,uvy:v1) )

      # Triangle 2

      trianglePoints.add( (x:x0,y:y0,uvx:u0,uvy:v0) )
      trianglePoints.add( (x:x2,y:y2,uvx:u1,uvy:v1) )
      trianglePoints.add( (x:x3,y:y3,uvx:u0,uvy:v1) )
      
    else :
      # Triangle 1
    
      trianglePoints.add( (x:x2,y:y2,uvx:u1,uvy:v1) )
      trianglePoints.add( (x:x1,y:y1,uvx:u1,uvy:v0) )
      trianglePoints.add( (x:x0,y:y0,uvx:u0,uvy:v0) )

      # Triangle 2
      
      trianglePoints.add( (x:x3,y:y3,uvx:u0,uvy:v1) )
      trianglePoints.add( (x:x2,y:y2,uvx:u1,uvy:v1) )
      trianglePoints.add( (x:x0,y:y0,uvx:u0,uvy:v0) )

    let advanceX=graphics_end.getGlyphAdvancePositionX(text.font.id,toRunes($ch)[0]).float
    penX += advanceX * scale + spacing

  let fontTextureRawID=graphics_end.getFontTextureDataID(text.font.id)
  graphics_end.renderGeometry(trianglePoints,globalDrawState.drawerColor,fontTextureRawID)
  
proc triangles*( vertices:seq[tuple[x,y,uvx,uvy:float]],indices:seq[int],color:tuple[r,g,b,a:uint8],textureID:int=0 ) =
  graphics_end.render_geometry(vertices,indices,color,textureID)

proc triangles*( trianglePoints:seq[tuple[x,y,uvx,uvy:float]],color:tuple[r,g,b,a:uint8],textureID:int=0 ) =
  graphics_end.render_geometry(trianglePoints,color,textureID)

### End of Drawing Operations



