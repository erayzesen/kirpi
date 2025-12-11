import ../src/kirpi 
import math 

# shader declarations
var windShader:Shader
var waterShader:Shader
var waveShader:Shader
var parallaxShader:Shader

# texture declarations
var tree:Texture
var platform:Texture
var sky:Texture
var water:Texture
var fish:Texture
var moss:Texture

# variable for fish vertical position
var fishPosY:float=0

proc load() =
    # load textures
    tree=newTexture("tests/resources/tree.png")
    platform=newTexture("tests/resources/platform.png")
    water=newTexture("tests/resources/water.png")
    moss=newTexture("tests/resources/moss.png")
    fish=newTexture("tests/resources/fish.png")
    sky=newTexture("tests/resources/sky.png")

    # load shaders
    windShader=newShader("tests/resources/shaders/wind_effect.vs.glsl","tests/resources/shaders/wind_effect.fs.glsl")
    windShader.setShaderValue("amount",50.0) # set wind strength
    
    waterShader=newShader("tests/resources/shaders/water_effect.vs.glsl","tests/resources/shaders/water_effect.fs.glsl")
    
    # load wave shader (fs only, using default vs)
    waveShader=newShader("","tests/resources/shaders/wave_effect.fs.glsl")
    waveShader.setShaderValue("amplitude",0.1) # set swing amount
    waveShader.setShaderValue("frequency",20.0) # set wave density
    waveShader.setShaderValue("speed",3.0) # set animation speed
    
    # load parallax shader (fs only)
    parallaxShader=newShader("","tests/resources/shaders/parallax_effect.fs.glsl")
   

proc update( dt:float) =
    # update shader time uniforms
    # pass current time for animation
    windShader.setShaderValue("time",getTime())
    waterShader.setShaderValue("time",getTime())
    waveShader.setShaderValue("time",getTime())
    parallaxShader.setShaderValue("time",getTime())

    # calculate fish vertical sine wave movement
    fishPosY=sin( getTime()*0.4 )*16
    

proc draw() =
    clear( "#c7e1c0" ) # clear with background color
    setColor(White)

    # draw parallax sky
    setShader(parallaxShader) # use parallax shader
    draw(sky,0,60)
    setShader() # reset shader
    
    # draw wave effects (moss and fish)
    setShader(waveShader) # use wave shader
    draw(moss,400,500)
    draw(moss,600,550)
    # draw fish with vertical offset
    push()
    translate(0,fishPosY)
    draw(fish,500,500)
    pop()
    setShader() # reset shader
    
    # draw water surface
    setShader(waterShader)
    draw(water,250,440)
    setShader()

    # draw wind effect (tree)
    setShader(windShader)
    draw(tree,80,115) # tree sways
    setShader() 

    # draw static foreground
    draw(platform,-20,375)
    draw(platform,700,400)

#Run the game
run("Drawing Shapes",load,update,draw) # start the game