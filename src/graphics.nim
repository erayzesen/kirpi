import raylib as rl
import raymath as rm
import rlgl as rlgl
import std/strutils
import algorithm
import std/unicode

import tables,os,hashes,options

import math
import triangulator


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

proc newTransform*(x,y,r,sx,sy,ox,oy,kx,ky: float): Transform =
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
  
  Font* = object
    id*:Hash
  
  Text* = object 
    str:string=""
    font:Font

  Texture *  = object
    rTexture: rl.Texture2D
    width*:float=0.0
    height*:float=0.0
    filter:TextureFilters=TextureFilters.Default

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

  Shader * = object 
    rShader:rl.Shader

### End of Graphic Objects ###


### Resource Collections ###

var fonts*: Table[Hash, rl.Font] = initTable[Hash, rl.Font]()

### End of Resource Collections ###

### Draw State Logic ### 



var defaultFont*:Font
proc getDefaultFont*():Font =
  result=defaultFont

type 
  DrawState = object 
    drawerColor:Color=Color(White)
    drawerLineWidth:float=1.0
    drawerLineJoin:JoinTypes=JoinTypes.Miter
    drawerLineBeginCap:CapTypes=CapTypes.None
    drawerLineEndCap:CapTypes=CapTypes.None
    currentFont:Font
    
    
#For easy hex colors
proc Color*(hex: string): Color =
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
    return Color(r: 0, g: 0, b: 0, a: 0)
  result = getColor(uint32( hexValue) )

var globalDrawState:DrawState
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
    globalDrawState.drawerColor=Color(r:r.uint8,g:g.uint8,b:b.uint8,a:a.uint8)

proc setColor* (color:Color) =
    globalDrawState.drawerColor=color

proc setColor* (hexColor:string) =
    globalDrawState.drawerColor=Color(hexColor)

proc getColor * () :Color =
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
  beginShaderMode(shader.rShader)

proc setShader*() =
  endShaderMode()




### End of Draw State Logic ###

type 
  DrawModes* = enum Fill,Line
  ArcType* = enum Pie,Open,Closed



    


var defaultFilter*:TextureFilters=TextureFilters.Linear

### Graphic Object Creators ###

proc newTexture*(filename:string, filter:TextureFilters=Default):Texture =
  result=Texture(rTexture:loadTexture(filename))
  result.width=float(result.rTexture.width)
  result.height=float(result.rTexture.height)
  result.filter=filter
  if filter==TextureFilters.Default :
    if defaultFilter==TextureFilters.Linear :
      setTextureFilter(result.rTexture,TextureFilter.Bilinear)
    else :
      setTextureFilter(result.rTexture,TextureFilter.Point)
  else :
    if filter==TextureFilters.Linear :
      setTextureFilter(result.rTexture,TextureFilter.Bilinear)
    else :
      setTextureFilter(result.rTexture,TextureFilter.Point)
  

proc newFont*(filename:string, antialias:bool=true, rasterSize:int=32): Font =
  var normalizedPath=filename.normalizedPath()
  var hashID:Hash=normalizedPath.hash()
  result=Font(id:hashID)
  # Load the font if not already cached
  if fonts.hasKey(hashID)==false :
    fonts[hashID]=rl.loadFont(filename,rasterSize.int32,0)
    if antialias :
      setTextureFilter(fonts[hashID].texture,TextureFilter.Bilinear)




proc newShader*(vertexShaderFile: string, fragmentShaderFile: string): Shader =
  # Normalize file paths
  let vPath = vertexShaderFile.normalizedPath()
  let fPath = fragmentShaderFile.normalizedPath()

  # Build a unique key for hashing, separator reduces collision risk
  let keyString = vPath & "|" & fPath
  let hashID: Hash = keyString.hash()

  result=Shader(rShader:rl.loadShader(vertexShaderFile, fragmentShaderFile))
  


#Text
proc newText*(text:string, font:Font):Text =
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


### End of Graphic Object Creators ###

### Text Methods ###

proc getSizeWith*(text:Text,fontSize:float,spacing:float=1.0) :tuple[x:float,y:float] =
  var size=measureText(fonts[text.font.id],text.str,fontSize.float32,spacing.float32)
  result=(x:size.x,y:size.y)
  



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
  let defWidth=spriteBatch.defWidth
  let defHeight=spriteBatch.defHeight
  var q=quad
  let id=spriteBatch.data.len
  spriteBatch.data.add( (q,t) )
  
  result=id

proc clear*(spriteBatch: var SpriteBatch) =
  spriteBatch.data.setLen(0)
  
### End of Sprite Batcher Methods ###

### Shader Methods ###
proc setValue*(shader:var Shader, uniformName: string, value: float) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, float32(value) )

proc setValue*(shader:var Shader, uniformName: string, value: int) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, int32(value) )

proc setValue*(shader:var  Shader, uniformName: string, value: (float,float)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, Vector2(x:value[0],y:value[1]))

proc setValue*(shader:var Shader, uniformName: string, value: (float,float,float)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, Vector3(x:value[0],y:value[1],z:value[2]))

proc setValue*(shader:var Shader, uniformName: string, value: (float,float,float,float)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, Vector4(x:value[0],y:value[1],z:value[2],w:value[3]) )

proc setValue*(shader:var Shader, uniformName: string, value: (int,int)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, [int32(value[0]),int32(value[1]) ] )

proc setValue*(shader:var Shader, uniformName: string, value: (int,int,int)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, [int32(value[0]),int32(value[1]),int32(value[2]) ] )

proc setValue*(shader:var Shader, uniformName: string, value: (int,int,int,int)) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValue(shader.rShader, loc, [int32(value[0]),int32(value[1]),int32(value[2]),int32(value[3]) ] )

proc setValue*(shader:var Shader, uniformName: string, value:var Texture) =
  if isShaderValid(shader.rShader):
    let loc = getShaderLocation(shader.rShader, uniformName)
    rl.setShaderValueTexture(shader.rShader, loc, value.rTexture )






### End of Shader Methods ###


### Drawing Operations ###

proc pixel*(x:float,y:float) =
  var (tx,ty)=transformPoint(x,y)
  drawPixel(int32(tx), int32(ty),globalDrawState.drawerColor )


        

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


proc lineIntersection*(A, B, C, D: Vector2): Option[Vector2] =
  let
    s1x = B.x - A.x
    s1y = B.y - A.y
    s2x = D.x - C.x
    s2y = D.y - C.y
    denom = -s2x * s1y + s1x * s2y

  if abs(denom) < 1e-6:  # parallel
    return none(Vector2)

  let
    s = (-s1y * (A.x - C.x) + s1x * (A.y - C.y)) / denom
    t = ( s2x * (A.y - C.y) - s2y * (A.x - C.x)) / denom

  if t >= 0.0 and t <= 1.0 and s >= 0.0 and s <= 1.0:
    let ix = A.x + t * s1x
    let iy = A.y + t * s1y
    return some(Vector2(x: ix, y: iy))
  else:
    return none(Vector2)

proc line*(points:varargs[float]) =
  if points.len mod 2 != 0:
    raise newException(ValueError, "Invalid points definition! Must be even number of coordinates.")

  if points.len<4:
    raise newException(ValueError, "Invalid points definition! Needs a minimum of two points to draw a line.")

  var allPoints: seq[Vector2] = @[]
  for i in countup(0, points.len - 1, 2):
    #Filtering same points
    if i>0 :
      if (points[i]==points[i-2] and points[i+1]==points[i-1])  :
        continue
    allPoints.add(Vector2(x:points[i], y:points[i+1]))

  var tris: seq[Vector2] = @[]

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
      
      var prevIntersectionTestTop:Option[Vector2]=none(Vector2)
      var prevIntersectionTestDown:Option[Vector2]=none(Vector2)
      var p1,p2,p3:Vector2
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

        let seg1=p2-p1
        let seg1Unit=seg1.normalize()
        let seg1Normal=Vector2(x: seg1Unit.y,y: -seg1Unit.x)
        

        let seg2=p3-p2
        let seg2Unit=seg2.normalize()
        let seg2Normal=Vector2(x: seg2Unit.y,y: -seg2Unit.x)

        

        let segBetween=p3-p1
        let segBetweenPerp=Vector2(x: segBetween.y,y: -segBetween.x)
        var cornerNormal= segBetweenPerp.normalize()

        var normalSide:float
        var projectToBetween=seg1.dotProduct(segBetweenPerp)
        if projectToBetween>0 :
          normalSide= 1.0
        elif projectToBetween<0 :
          normalSide= -1.0

        #Drawing Line with Triangles
        
        var s1a=p1+seg1Normal*halfLineWidth
        var s1b=p2+seg1Normal*halfLineWidth
        var s1c=p2-seg1Normal*halfLineWidth
        var s1d=p1-seg1Normal*halfLineWidth

        var s2a=p2+seg2Normal*halfLineWidth
        var s2b=p3+seg2Normal*halfLineWidth
        var s2c=p3-seg2Normal*halfLineWidth
        var s2d=p2-seg2Normal*halfLineWidth

        

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
              let beginAngle=rm.angle(Vector2( x: 1.0,y: 0.0), -seg1Normal )
              let endAngle=beginAngle+PI
              
              var arcPoints=getArcPoints( p1.x,p1.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
              for n in countup(0, arcPoints.len - 3, 2) :
                var ax,ay,bx,by:float
                #Fill Arc
                ax=arcPoints[n]
                ay=arcPoints[n+1]
                bx=arcPoints[n+2]
                by=arcPoints[n+3]

                tris.add( Vector2(x:p1.x, y: p1.y) )
                tris.add(Vector2(x: bx, y: by) )
                tris.add(Vector2(x: ax, y: ay) )
            elif globalDrawState.drawerLineBeginCap==CapTypes.Square :
              s1a-=seg1Unit*halfLineWidth
              s1d-=seg1Unit*halfLineWidth
          #End Caps
          if i==allPoints.len-3 :
            if globalDrawState.drawerLineEndCap==CapTypes.Round :
              let radius=halfLineWidth
              let beginAngle=rm.angle(Vector2( x: 1.0,y: 0.0), seg2Normal )
              let endAngle=beginAngle+PI
              var arcPoints=getArcPoints( p3.x,p3.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
              for n in countup(0, arcPoints.len - 3, 2) :
                var ax,ay,bx,by:float
                #Fill Arc
                ax=arcPoints[n]
                ay=arcPoints[n+1]
                bx=arcPoints[n+2]
                by=arcPoints[n+3]

                tris.add( Vector2(x: p3.x, y: p3.y) )
                tris.add( Vector2(x: bx, y: by)  )
                tris.add( Vector2(x: ax, y: ay) )
            elif globalDrawState.drawerLineEndCap==CapTypes.Square :
              s2b+=seg2Unit*halfLineWidth
              s2c+=seg2Unit*halfLineWidth
          
        #Drawing Line Segment-1 Quad
        tris.add( Vector2(x: s1c.x, y: s1c.y))
        tris.add( Vector2(x: s1b.x, y: s1b.y))
        tris.add( Vector2(x: s1a.x, y: s1a.y))

        
        tris.add( Vector2(x: s1d.x, y: s1d.y) )
        tris.add( Vector2(x: s1c.x, y: s1c.y))
        tris.add( Vector2(x: s1a.x, y: s1a.y))

        #Drawing Line Last Segment Quad
        if i==allPoints.len-3 :
          tris.add( Vector2(x: s2c.x, y: s2c.y))
          tris.add( Vector2(x: s2b.x, y: s2b.y))
          tris.add( Vector2(x: s2a.x, y: s2a.y))

          
          tris.add( Vector2(x: s2d.x, y: s2d.y) )
          tris.add( Vector2(x: s2c.x, y: s2c.y))
          tris.add( Vector2(x: s2a.x, y: s2a.y))

        
        #Implementing Join Types
        let np1=if normalSide == -1 : s1c else : s1b
    
        let np2=if normalSide == -1 : s2d else : s2a

        var npc= if normalSide == -1.0 : s1b else :s1c

        

        if globalDrawState.drawerLineJoin==JoinTypes.Miter :
          var np3 = p2-(npc-p2)
          if (np3-p2).lengthSqr>globalDrawState.drawerLineWidth*globalDrawState.drawerLineWidth:
            np3=(np1+np2)*0.5
          if normalSide == -1.0 :
            tris.add( Vector2(x: np3.x, y: np3.y) )
            tris.add( Vector2(x: npc.x, y: npc.y) )
            tris.add( Vector2(x: np1.x, y: np1.y) )
            
            tris.add( Vector2(x: np3.x, y: np3.y) )
            tris.add( Vector2(x: np2.x, y: np2.y) )
            tris.add( Vector2(x: npc.x, y: npc.y) )
          else :
            
            tris.add( Vector2(x: np1.x, y: np1.y) )
            tris.add( Vector2(x: npc.x, y: npc.y) )
            tris.add( Vector2(x: np3.x, y: np3.y) )
            
            tris.add( Vector2(x: npc.x, y: npc.y) )
            tris.add( Vector2(x: np2.x, y: np2.y) )
            tris.add( Vector2(x: np3.x, y: np3.y) )

          
        elif globalDrawState.drawerLineJoin==JoinTypes.Bevel :
          if normalSide == -1.0 :
            tris.add( Vector2(x: npc.x, y: npc.y) )
            tris.add( Vector2(x: np1.x, y: np1.y) )
            tris.add( Vector2(x: np2.x, y: np2.y) )
          else :
            tris.add( Vector2(x: np2.x, y: np2.y) )
            tris.add( Vector2(x: np1.x, y: np1.y) )
            tris.add( Vector2(x: npc.x, y: npc.y) )
        
        elif globalDrawState.drawerLineJoin==JoinTypes.Round :
          
          var radius=halfLineWidth
          var beginAngle=rm.angle(Vector2( x: 1.0,y: 0.0), (np1-p2) )
          var angDiff:float=rm.angle( (np1-p2),(np2-p2))

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
              tris.add( Vector2(x: bx, y: by) )
              tris.add( Vector2(x: npc.x, y: npc.y) )
              tris.add( Vector2(x: ax, y: ay) )
              discard
              
            else :
              tris.add( Vector2(x: ax, y: ay) )
              tris.add( Vector2(x: npc.x, y: npc.y) )
              tris.add( Vector2(x: bx, y: by) )
              discard
              
          

        prevIntersectionTestDown=intersectionTestDown
        prevIntersectionTestTop=intersectionTestTop
      
      
    elif allPoints.len==2 : # One line 
      let p1=allPoints[0]
      let p2=allPoints[1]
      let seg=p2-p1
      let segUnit=seg.normalize()
      let segNormal=Vector2(x: segUnit.y,y: -segUnit.x)

      var sa=p1+segNormal*halfLineWidth
      var sb=p2+segNormal*halfLineWidth
      var sc=p2-segNormal*halfLineWidth
      var sd=p1-segNormal*halfLineWidth

      
      if globalDrawState.drawerLineBeginCap==CapTypes.Round :
        let radius=halfLineWidth
        let beginAngle=rm.angle(Vector2( x: 1.0,y: 0.0), -segNormal )
        let endAngle=beginAngle+PI
        var arcPoints=getArcPoints( p1.x,p1.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
        for n in countup(0, arcPoints.len - 3, 2) :
          var ax,ay,bx,by:float
          #Fill Arc
          ax=arcPoints[n]
          ay=arcPoints[n+1]
          bx=arcPoints[n+2]
          by=arcPoints[n+3]

          tris.add( Vector2(x:p1.x, y: p1.y))
          tris.add( Vector2(x:bx, y: by) )
          tris.add( Vector2(x:ax, y: ay))
      elif globalDrawState.drawerLineBeginCap==CapTypes.Square :
        sa-=segUnit*halfLineWidth
        sd-=segUnit*halfLineWidth
    
      if globalDrawState.drawerLineEndCap==CapTypes.Round :
        let radius=halfLineWidth
        let beginAngle=rm.angle(Vector2( x: 1.0,y: 0.0), segNormal )
        let endAngle=beginAngle+PI
        var arcPoints=getArcPoints( p2.x,p2.y,radius,radius,beginAngle,endAngle,roundedCapSegCount )
        for n in countup(0, arcPoints.len - 3, 2) :
          var ax,ay,bx,by:float
          #Fill Arc
          ax=arcPoints[n]
          ay=arcPoints[n+1]
          bx=arcPoints[n+2]
          by=arcPoints[n+3]

          tris.add( Vector2(x:p2.x, y: p2.y))
          tris.add( Vector2(x:bx, y: by) )
          tris.add( Vector2(x:ax, y: ay))
      elif globalDrawState.drawerLineEndCap==CapTypes.Square :
        sb+=segUnit*halfLineWidth
        sc+=segUnit*halfLineWidth

      #Drawing Segment-1 Quad
      tris.add( Vector2(x:sc.x, y: sc.y))
      tris.add( Vector2(x:sb.x, y: sb.y))
      tris.add( Vector2(x:sa.x, y: sa.y))

      
      tris.add( Vector2(x:sd.x, y: sd.y) )
      tris.add( Vector2(x:sc.x, y: sc.y))
      tris.add( Vector2(x:sa.x, y: sa.y))
    

    #Drawing All Triangles
    for i in 0..<tris.len: 
      var tp=transformPoint(tris[i].x,tris[i].y)
      tris[i]=Vector2(x:tp[0],y: tp[1]) 
    
    var isTransformMirrored:bool=globalTransform.isOrientationFlipped()
    for n in countup(0, tris.len - 3, 3) :
      if isTransformMirrored :
        drawTriangle( tris[n+2],tris[n+1],tris[n],globalDrawState.drawerColor )
      else :
        drawTriangle( tris[n],tris[n+1],tris[n+2],globalDrawState.drawerColor )
    
    


proc polygon*(mode:DrawModes,points:varargs[float]) =
    var allPoints:seq[Vec2]
    for i in countup(0, points.len - 1, 2):
        var pTransformed=transformPoint(points[i],points[i+1])
        allPoints.add( Vec2( x:pTransformed[0],y:pTransformed[1]) )
        
    
    if mode==Fill :
      var isTransformMirrored:bool=globalTransform.isOrientationFlipped()
      if isTransformMirrored :
        allPoints.reverse()
      
      var tris=triangulate(allPoints)
      for t in tris:
        drawTriangle(Vector2(x:t.c.x,y:t.c.y),Vector2(x:t.b.x,y:t.b.y),Vector2(x:t.a.x,y:t.a.y),globalDrawState.drawerColor)
        
        
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
  
  var maxScale=getAverageScale(globalTransform)
  var segments:int=getSmoothSegmentCount(TAU,radius,maxScale)

  var allPoints:seq[float]=getArcPoints(x,y,radius,radius,0,TAU,segments)

  if mode==Fill :
    polygon(Fill,allPoints)
  else:
    line(allPoints)

    

proc clear*() =
    clearBackground(globalDrawState.drawerColor)

proc clear*(color:Color) =
    clearBackground(color)

proc clear*(hexColor:string) =
    clearBackground(Color(hexColor))


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

  setTexture(texture.rTexture.id) # Bind texture
  
  rlBegin(Triangles)
  color4ub(globalDrawState.drawerColor.r, globalDrawState.drawerColor.g, globalDrawState.drawerColor.b, globalDrawState.drawerColor.a)
  normal3f(0.0, 0.0, 1.0); 
  #Quad normalized mapping
  let tcx1:float=quad.x/quad.sw
  let tcy1:float=quad.y/quad.sh
  let tcx2:float=tcx1+quad.w/quad.sw
  let tcy2:float=tcy1+quad.h/quad.sh
  
  var isTransformMirrored:bool=globalTransform.isOrientationFlipped()

  if isTransformMirrored :
    # Triangle 1: v1, v2, v3
    
    texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
    texCoord2f(tcx2, tcy1); vertex2f(v2x, v2y)
    texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)

    texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
    texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
    texCoord2f(tcx1, tcy2); vertex2f(v4x, v4y)
  else :
    # Triangle 1: v3, v2, v1
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
  color4ub(globalDrawState.drawerColor.r, globalDrawState.drawerColor.g, globalDrawState.drawerColor.b, globalDrawState.drawerColor.a)
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

    var isTransformMirrored:bool=globalTransform.isOrientationFlipped()

    
    if isTransformMirrored==false :
      # Triangle 1: v1, v2, v3
      texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
      texCoord2f(tcx2, tcy1); vertex2f(v2x, v2y)
      texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)

      # Triangle 2: v1, v3, v4
      texCoord2f(tcx1, tcy2); vertex2f(v4x, v4y)
      texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
      texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
    else :
      # Negative scale values exception  (inverse faces)
      # Triangle 1: v1, v2, v3
      texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
      texCoord2f(tcx2, tcy1); vertex2f(v2x, v2y)
      texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)

      # Triangle 2: v1, v3, v4
      texCoord2f(tcx1, tcy1); vertex2f(v1x, v1y)
      texCoord2f(tcx2, tcy2); vertex2f(v3x, v3y)
      texCoord2f(tcx1, tcy2); vertex2f(v4x, v4y)

    pop()
    
  

  rlEnd()
  setTexture(0) # Unbind texture
  

proc draw*( text:Text ,x:float=0.0,y:float=0.0, size:float=16, spacing:float=1.0 ) =
  
  if not isFontValid(fonts[text.font.id]):
    echo "Warning: font is nil, cannot draw text."
    return

  let scale = size / fonts[text.font.id].baseSize.float

  setTexture(fonts[text.font.id].texture.id)
  rlBegin(Triangles)
  color4ub(globalDrawState.drawerColor.r,globalDrawState.drawerColor.g,globalDrawState.drawerColor.b,globalDrawState.drawerColor.a)

  var penX = 0.0
  var penY = 0.0

  let sw = fonts[text.font.id].texture.width.float
  let sh = fonts[text.font.id].texture.height.float

  var isTransformMirrored:bool=globalTransform.isOrientationFlipped()

  for ch in text.str:
    if ch == '\n':
      penX = 0
      penY += fonts[text.font.id].baseSize.float * scale
      continue

    let gi = getGlyphIndex(fonts[text.font.id], toRunes($ch)[0] )
    if gi < 0: continue

    let g = addr fonts[text.font.id].glyphs[gi]
    let r = fonts[text.font.id].recs[gi]

    # Local quad (text space)
    let lx0 = x + (penX + g[].offsetX.float) 
    let ly0 = y + (penY + g[].offsetY.float*scale) 
    let lx1 = lx0 + r.width * scale
    let ly1 = ly0 + r.height * scale

    # World space 
    let (x0,y0) = transformPoint(lx0, ly0)
    let (x1,y1) = transformPoint(lx1, ly0)
    let (x2,y2) = transformPoint(lx1, ly1)
    let (x3,y3) = transformPoint(lx0, ly1)

    let u0 = r.x / sw
    let v0 = r.y / sh
    let u1 = (r.x + r.width) / sw
    let v1 = (r.y + r.height) / sh
    
    if isTransformMirrored :
      # Triangle 1
      texCoord2f(u0, v0); vertex2f(x0, y0)
      texCoord2f(u1, v0); vertex2f(x1, y1)
      texCoord2f(u1, v1); vertex2f(x2, y2)

      # Triangle 2
      texCoord2f(u0, v0); vertex2f(x0, y0)
      texCoord2f(u1, v1); vertex2f(x2, y2)
      texCoord2f(u0, v1); vertex2f(x3, y3)
    else :
      # Triangle 1
      texCoord2f(u1, v1); vertex2f(x2, y2)
      texCoord2f(u1, v0); vertex2f(x1, y1)
      texCoord2f(u0, v0); vertex2f(x0, y0)

      # Triangle 2
      texCoord2f(u0, v1); vertex2f(x3, y3)
      texCoord2f(u1, v1); vertex2f(x2, y2)
      texCoord2f(u0, v0); vertex2f(x0, y0)

    penX += g.advanceX.float * scale + spacing

  rlEnd()
  setTexture(0)
  


### End of Drawing Operations

#Export raylib colors
export  rl.Color,LightGray,Gray,DarkGray,Yellow,Gold,Orange,Pink,Red,Maroon,Green,Lime,DarkGreen,SkyBlue,Blue,DarkBlue,Purple,Violet,DarkPurple,Beige,Brown,DarkBrown,White, Black,Blank,Magenta
