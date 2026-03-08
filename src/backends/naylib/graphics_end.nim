#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE


import tables,os,hashes
import raylib as rl
import rlgl as rlgl
import std/unicode
import settings_end
#region Backend Needs

### Resource Managment ###
type 
  FontEntry = object
    data:rl.Font
    refCount: int
  TextureEntry = object
    data: rl.Texture
    refCount: int
  ShaderEntry = object
    data: rl.Shader
    refCount: int


var fonts*: Table[Hash, FontEntry] = initTable[Hash, FontEntry]()
var textures*: Table[Hash, TextureEntry] = initTable[Hash, TextureEntry]()
var shaders*: Table[Hash, ShaderEntry] = initTable[Hash, ShaderEntry]()

#Initialization
proc init*(appBackendSettings:Settings)
proc loop*()
proc deInit*()
#Fonts
proc loadFontFile*(filename:string, antialias:bool=true, rasterSize:int=32): Hash 
proc unloadFont*(fontID:Hash)
proc loadFontWithData*(uniqueTextForHash:string,fileType:string,fileData:openArray[uint8],antialias:bool=true, rasterSize:int=32): Hash 
proc isFontIDValid*(fontID:Hash):bool
proc getFontTextureDataID*(fontID:Hash):int
proc getGlyphTextureQuad*(fontID:Hash,rune:Rune):tuple[x,y,w,h:float]
proc getGlyphAdvancePositionX*(fontID:Hash,rune:Rune):int
proc getGlyphOffset*(fontID:Hash,rune:Rune):tuple[x,y:float]
proc getFontBaseSize*(fontID:Hash) :float
proc getFontTextureWidth*(fontID:Hash) : float
proc getFontTextureHeight*(fontID:Hash) : float
proc getTextSizeWithFont*(fontID:Hash,text:string,fontSize:float,spacing:float):tuple[x:float,y:float]

#Textures
proc loadTextureFile*(filename:string, antialias:bool=true) : Hash
proc unloadTexture*(textureID:Hash)
proc getTextureDataID*(textureID:Hash):int
proc getTextureWidth*(textureID:Hash):int
proc getTextureHeight*(textureID:Hash):int

#Shaders
proc loadShaderFile*(shaderFolderPath:string,shaderName:string) : Hash 
proc unloadShader*(shaderID:Hash)
proc beginShader*(shaderID:Hash)
proc endShader*()
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:float)
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:int)
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float)) 
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float,float)) 
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float,float,float)) 
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int)) 
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int,int))
proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int,int,int))
proc setShaderTextureValue*(shaderID:Hash, uniformName:string, textureID:Hash) 

#Rendering
proc renderGeometry*(vertices:var seq[tuple[x,y,uvx,uvy:float]],indices:var seq[int],color:tuple[r,g,b,a:uint8],textureDataID:int=0)
proc renderGeometry*(trianglePoints:var seq[tuple[x,y,uvx,uvy:float]],color:tuple[r,g,b,a:uint8],textureDataID:int=0)

proc clearCanvas*(color:tuple[r,g,b,a:uint8]) 
    
#endregion

#region Initialization
var shapeTexture:Texture2D #We're using custom shape texture because there're some issues about the shape texture id of raylib 
proc init*(appBackendSettings:Settings) =
    let whiteImage = genImageColor(1, 1, WHITE) # 1x1 beyaz resim üret
    shapeTexture = loadTextureFromImage(whiteImage)

proc loop*() =
    discard

proc deInit*() =
    discard

#endregion
    

#region Methods & Properties
proc loadFontFile*(filename:string, antialias:bool=true, rasterSize:int=32): Hash =
  var normalizedPath=filename.normalizedPath()
  var hashID:Hash=normalizedPath.hash()
  result=hashID
  # Load the font if not already cached
  if fonts.hasKey(hashID)==false :
    fonts[hashID]=FontEntry(data:rl.loadFont(filename,rasterSize.int32,0),refCount:1)
    if antialias :
      setTextureFilter(fonts[hashID].data.texture,TextureFilter.Bilinear)
  else :
    fonts[hashID].refCount+=1


proc loadFontWithData*(uniqueTextForHash:string,fileType:string,fileData:openArray[uint8],antialias:bool=true, rasterSize:int=32): Hash =
    var hashID:Hash=uniqueTextForHash.hash()
    result=hashID
    if fonts.hasKey(hashID)==false :
        fonts[hashID]=FontEntry(data:loadFontFromMemory(fileType,filedata,rasterSize.int32,0 ),refCount:1)
        if antialias==true :
            setTextureFilter(fonts[hashID].data.texture,TextureFilter.Bilinear)
    else :
        fonts[hashID].refCount+=1


proc unloadFont*(fontID:Hash) =
    fonts[fontID].refCount-=1
    if fonts[fontID].refCount<=0 :
        fonts.del(fontID)
    
    


proc isFontIDValid*(fontID:Hash):bool =
    result=isFontValid(fonts[fontID].data)

proc getFontTextureDataID*(fontID:Hash):int =
    result=fonts[fontID].data.texture.id.int

proc getGlyphTextureQuad*(fontID:Hash,rune:Rune):tuple[x,y,w,h:float] =
    var gi=getGlyphIndex(fonts[fontID].data, rune )
    if gi<0 :
        return (x: -1 ,y: -1 ,w: -1,h: -1)
    let r = fonts[fontID].data.recs[gi]
    result=(x:r.x.float,y:r.y.float,w:r.width.float,h:r.height.float)

proc getGlyphOffset*(fontID:Hash,rune:Rune):tuple[x,y:float] =
    var gi=getGlyphIndex(fonts[fontID].data, rune )
    if gi<0 :
        return (x: -1 ,y: -1)
    let g = addr fonts[fontID].data.glyphs[gi]
    result=(x:g[].offsetX.float,y:g[].offsetY.float)


proc getGlyphAdvancePositionX*(fontID:Hash,rune:Rune):int =
    let gi = getGlyphIndex(fonts[fontID].data, rune )
    let g = addr fonts[fontID].data.glyphs[gi]
    result=g.advanceX
    
    
proc getFontBaseSize*(fontID:Hash) :float =
    result=fonts[fontID].data.baseSize.float

proc getFontTextureWidth*(fontID:Hash) : float =
    result=fonts[fontID].data.texture.width.float

proc getFontTextureHeight*(fontID:Hash) : float =
    result=fonts[fontID].data.texture.height.float

proc getTextSizeWithFont*(fontID:Hash,text:string,fontSize:float,spacing:float) :tuple[x:float,y:float]=
    var size=measureText(fonts[fontID].data,text,fontSize.float32,spacing.float32)
    result=(x:size.x,y:size.y)

#Textures

proc loadTextureFile*(filename:string, antialias:bool=true) : Hash =
  var normalizedPath=filename.normalizedPath()
  var hashID:Hash=normalizedPath.hash()
  result=hashID
  if textures.hasKey(hashID)==false :
    textures[hashID]=TextureEntry(data:loadTexture(filename),refCount:1)

    if antialias :
        setTextureFilter(textures[hashID].data,TextureFilter.Bilinear)
    else :
        setTextureFilter(textures[hashID].data,TextureFilter.Point)
  else :
    textures[hashID].refCount+=1

proc unloadTexture*(textureID:Hash) =
    textures[textureID].refCount-=1
    if textures[textureID].refCount<=0 :
        textures.del(textureID)

proc getTextureDataID*(textureID:Hash):int =
    result=textures[textureID].data.id.int

proc getTextureWidth*(textureID:Hash):int =
    result=textures[textureID].data.width

proc getTextureHeight*(textureID:Hash):int =
    result=textures[textureID].data.height

#Shaders 

proc loadShaderFile*(shaderFolderPath:string,shaderName:string) : Hash =
    let basePath = shaderFolderPath.normalizedPath() / shaderName.toLower()
    let hashID = basePath.hash()
    result = hashID
    if shaders.hasKey(hashID)==false :
            # Lists of possible extensions for Vertex and Fragment shaders
        let vExtensions = [".vs", ".vs.glsl", ".vert"]
        let fExtensions = [".fs", ".fs.glsl", ".frag"]

        var vFile, fFile: string
        var vExists, fExists: bool

        # Find the first existing vertex shader file
        for ext in vExtensions:
            if fileExists(basePath & ext) :
                vFile = basePath & ext
                vExists = true
                break

        # Find the first existing fragment shader file
        for ext in fExtensions:
            if fileExists(basePath & ext):
                fFile = basePath & ext
                fExists = true
                break

        # If neither file exists among all possible extensions, raise the error
        if not vExists and not fExists:
            let errorMsg = "\n[RESOURCE ERROR] Graphics Backend could not find shader files!" &
                            "\n  Base Path: " & basePath.absolutePath() &
                            "\n  Tried extensions: .vs, .vs.glsl, .vert, .fs, .fs.glsl, .frag"
            raise newException(IOError, errorMsg)

        # Use found paths or empty string for default Raylib shaders
        let finalV = if vExists: vFile else: ""
        let finalF = if fExists: fFile else: "" 

        # Load and store
        shaders[hashID] = ShaderEntry(data: rl.loadShader(finalV, finalF), refCount: 1)
        
    else :
        shaders[hashID].refCount+=1

proc unloadShader*(shaderID:Hash) =
    shaders[shaderID].refCount-=1
    if shaders[shaderID].refCount<=0 :
        shaders.del(shaderID) 

proc beginShader*(shaderID:Hash) =
    beginShaderMode(shaders[shaderID].data)

proc endShader*() =
    endShaderMode()

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:float) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, float32(value) )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:int) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, int32(value) )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, Vector2(x:value[0],y:value[1]) )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float,float)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, Vector3(x:value[0],y:value[1],z:value[2]) )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(float,float,float,float)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, Vector4(x:value[0],y:value[1],z:value[2],w:value[3],) )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, [int32(value[0]),int32(value[1]) ] )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int,int)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, [int32(value[0]),int32(value[1]),int32(value[2]) ] )

proc setShaderUniform*(shaderID:Hash, uniformName:string, value:(int,int,int,int)) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValue(shaders[shaderID].data, loc, [int32(value[0]),int32(value[1]),int32(value[2]),int32(value[3]) ] )

proc setShaderTextureValue*(shaderID:Hash, uniformName:string, textureID:Hash) =
    let loc = getShaderLocation(shaders[shaderID].data, uniformName)
    rl.setShaderValueTexture(shaders[shaderID].data, loc, textures[textureID].data )



#endregion

#region Rendering


proc renderGeometry*(vertices:var seq[tuple[x,y,uvx,uvy:float]],indices:var seq[int],color:tuple[r,g,b,a:uint8],textureDataID:int=0) =
    
    if textureDataID == 0 :
        setTexture(shapeTexture.id)
    else :
        setTexture(textureDataID.uint32)
        

    rlBegin(Quads)
    color4ub(color.r.uint8, color.g.uint8, color.b.uint8, color.a.uint8)
    normal3f(0.0, 0.0, 1.0);
    for i in countup(0,indices.len,3) :
        let 
            v1=vertices[indices[i]]
            v2=vertices[indices[i+1]]
            v3=vertices[indices[i+2]]
        if textureDataID==0 :
            texCoord2f(0.0,0.0); vertex2f(v1.x, v1.y)
            texCoord2f(0.0, 1.0); vertex2f(v2.x, v2.y)
            texCoord2f( 1.0, 1.0); vertex2f(v3.x, v3.y)
            texCoord2f( 1.0,0.0); vertex2f(v3.x, v3.y)
        else :
            texCoord2f(v1.uvx, v1.uvy); vertex2f(v1.x, v1.y)
            texCoord2f(v2.uvx, v2.uvy); vertex2f(v2.x, v2.y)
            texCoord2f(v3.uvx, v3.uvy); vertex2f(v3.x, v3.y)
            texCoord2f(v3.uvx, v3.uvy); vertex2f(v3.x, v3.y)
        

    rlEnd()
    setTexture(0)
    discard


proc renderGeometry*(trianglePoints:var seq[tuple[x,y,uvx,uvy:float]],color:tuple[r,g,b,a:uint8],textureDataID:int=0) =

    if textureDataID == 0 :
        setTexture(shapeTexture.id)
    else :
        setTexture(textureDataID.uint32)
        
        #setTexture(getShapesTexture().id)
        

    rlBegin(Quads)
    color4ub(color.r.uint8, color.g.uint8, color.b.uint8, color.a.uint8)
    normal3f(0.0, 0.0, 1.0);
    for i in countup(0,trianglePoints.len-3,3) :
        let 
            v1=trianglePoints[i]
            v2=trianglePoints[i+1]
            v3=trianglePoints[i+2]
        if textureDataID==0 :
            texCoord2f(0.0,0.0); vertex2f(v1.x, v1.y)
            texCoord2f(0.0, 1.0); vertex2f(v2.x, v2.y)
            texCoord2f( 1.0, 1.0); vertex2f(v3.x, v3.y)
            texCoord2f( 1.0,0.0); vertex2f(v3.x, v3.y)
        else :
            texCoord2f(v1.uvx, v1.uvy); vertex2f(v1.x, v1.y)
            texCoord2f(v2.uvx, v2.uvy); vertex2f(v2.x, v2.y)
            texCoord2f(v3.uvx, v3.uvy); vertex2f(v3.x, v3.y)
            texCoord2f(v3.uvx, v3.uvy); vertex2f(v3.x, v3.y)
        

    rlEnd()
    setTexture(0)

proc clearCanvas*(color:tuple[r,g,b,a:uint8]) =
    clearBackground( Color(r:color.r,g:color.g,b:color.b,a:color.a) )
  
#endregion