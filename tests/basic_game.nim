import ../src/kirpi
import math , random


var sampleTexture:Texture
var sampleText:Text
var sampleSound:Sound
var atlasTexture:Texture
var sampleSpriteBatch:SpriteBatch

var walkAnim:seq[Quad]
var walkAnimCounter=0

var batchCount:int=1
var frameCount:int=0

proc config(settings:var AppSettings) =
    settings.window.width=800
    settings.window.height=600
    settings.window.resizeable=false
    settings.window.fullscreen=false

proc load() =
    sampleTexture=newTexture("resources/mario.png")
    atlasTexture=newTexture("resources/sampleAtlas.png")
    sampleText=newText("Hello World!",getFont())
    sampleSound=newSound("resources/music.mp3",SoundType.Stream)
    sampleSound.playSound()


    sampleSpriteBatch=newSpriteBatch(sampleTexture)


    #Animated Sprite Test
    
    walkAnim.add( newQuad(0,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(96,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(192,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(288,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(384,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(480,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(576,512,96,128,atlasTexture) )
    walkAnim.add( newQuad(672,512,96,128,atlasTexture) )
    

    

var angle=0.0

proc update(dt:float) =
    
    if isKeyDown(KeyboardKey.Right) or isKeyDown(KeyboardKey.D) :
        angle+=0.1
    if isKeyDown(KeyboardKey.Left) or isKeyDown(KeyboardKey.A):
        angle-=0.1

    if isKeyPressed(KeyboardKey.Down) :
        batchCount=max( (batchCount-100) ,0)
        echo "batchCount: " & $batchCount
    if isKeyPressed(KeyboardKey.Up):
        batchCount=batchCount+100
        echo "batchCount: " & $batchCount

    if isKeyPressed(KeyboardKey.Space):
        window.setFullScreenMode( not window.getFullScreenMode() )
    
    sampleSpriteBatch.clear()
    var quad=newQuad(0,0,64,64,sampleTexture)
    for i in 0..batchCount :
        var posX:float=float(rand(300))
        var posY:float=float( rand(300))
        var n=sampleSpriteBatch.add(quad,posX,posY)

    frameCount+=1

    angle+=0.001
    


proc draw() =
    origin()
    setColor(Black)
    clear()
    setColor(White)

    

    rotate(angle)
    #star
    #var points:seq[float] =  @[50.0,10.0,61.0,38.0,92.0,38.0,67.0,59.0,76.0,90.0,50.0,72.0,24.0,90.0,33.0,59.0,8.0,38.0,39.0,38.0]
    #hearth
    #var points: seq[float] = @[50.0,90.0,20.0,60.0,20.0,45.0,30.0,30.0,50.0,40.0,70.0,30.0,80.0,45.0,80.0,60.0,50.0,90.0]
    #intersecting
    #var points: seq[float] =  @[  10.0, 10.0, 90.0, 10.0, 50.0, 50.0, 90.0, 90.0,10.0, 90.0, 30.0, 60.0, 70.0, 60.0, 50.0, 30.0]


    #cross
    #var points:seq[float] =  @[10.0,10.0,90.0,10.0,10.0,90.0,90.0,90.0]
    #irregular
    #var points:seq[float] =  @[10.0,50.0,20.0,10.0,40.0,20.0,60.0,5.0,80.0,30.0,70.0,50.0,90.0,70.0,60.0,80.0,40.0,60.0,20.0,80.0]

    
    #polygon(DrawMode.line,points)

    

    translate(100,100)
    #circle(DrawMode.Line,0,0,150)
    #arc(DrawMode.Line,ArcType.Open,0,0,64,0,3.14,16)
    #rectangle(DrawMode.Line,-50,-50,200,100,32)
    #ellipse(DrawMode.Line,0,0,150,50)
    #quad(DrawMode.Fill,-100,-100,100,-100,150,100,-150,100)
    #draw(sampleTexture,-sampleTexture.width/2,-sampleTexture.height/2)
    #draw(sampleText,100,100)
    #polygon(DrawMode.fill,points)
    draw(atlasTexture,walkAnim[walkAnimCounter],-48,-64)
    if (frameCount mod 5) == 0 :
        walkAnimCounter=(walkAnimCounter+1) mod walkAnim.len
        #echo walkAnimCounter
    




    #Batch Test
    draw(sampleSpriteBatch,0,0)


run("Sample Game",load,update,draw,config)