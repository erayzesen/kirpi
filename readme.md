
<div align="center">

![logo](media/logo.png) 

</div>

A lightweight 2D game framework featuring a clean, [Löve2D](https://love2d.org/)-inspired graphics API (Löve2D developers will feel right at home). It uses [Naylib](https://github.com/planetis-m/naylib) (Raylib) as its well-maintained cross-platform backend within the Nim ecosystem.

**Supported Build Targets:** Web(Wasm),Linux,Windows,Macos,Android 



## Why kirpi?
* Very small Web builds for a WASM-based runtime. Performance-first builds of an empty project ship at ~750 KB uncompressed and ~350 KB zipped, comparable to many JavaScript game frameworks.
* Easy to learn with a minimal, well-placed abstraction layer. Want to use an ECS library? Bring your own. Need a physics engine or just a simple collider library? Your call.
* Straightforward multi-platform builds thanks to the configuration in the template project, including Android. Each platform also gets a clean, organized folder structure.
* You write your game in Nim, a pleasant and elegant language that’s easy to pick up and often delivers near-C performance. Nim uses ARC (Automatic Reference Counting), a deterministic, low-overhead memory model similar to C++’s RAII.


And really, the motivation behind Kirpi explains it best:
tiny web builds, a fun and elegant language to work in, great performance, a minimal API you can build an ecosystem around, and fully compiled (non-VM) games.



## Getting Started
Install kirpi easily with `nimble install kirpi`.

To compile a Kirpi project for your desktop platform, the Nim toolchain and compiler are sufficient. The command `nim c -r game.nim` will do the job. 

```nim
#game.nim
import kirpi

var sampleText:Text

proc load() =
    sampleText=newText("Hello World!",getDefaultFont())

proc update(dt: float) =
    if isKeyPressed(KeyboardKey.Escape):
        quit()

proc draw() =
    clear(Black)
    setColor(White)
    draw(sampleText,100,100)

run( "sample game",load,update,draw)

```

However, for smooth builds across all supported platforms and an ideal folder structure, we recommend using the [kirpi_app_template](https://github.com/erayzesen/kirpi_app_template) repository.
 

```shell
#Clone kirpi_app_template project 
git clone https://github.com/erayzesen/kirpi_app_template.git your_project_name

# Then install the project dependencies. (It will install it since its only dependency is the kirpi package.)
cd your_project_name
nimble install --depsOnly

```


 This repo also includes extensively customized compiler configuration files, thanks in part to the Naylib community, which automate nearly everything for Android builds. Additionally, we provide customized Emscripten configurations for Web builds. In short, you can deploy your project to Android with just a few commands, and to other platforms with a single command. Detailed build instructions are available in our template repository.

## Learning Samples 
<table>
  <tr>
    <td align="center">
      <b>Flappy Bird</b><br>
      <a href="https://erayzesen.github.io/kirpi-flappy-bird-game/">
        <img src="https://github.com/erayzesen/kirpi-flappy-bird-game/raw/master/media/gameplay.gif" width="250">
      </a><br>
      <a href="https://github.com/erayzesen/kirpi-flappy-bird-game">🦔 Repo</a> | 
      <a href="https://erayzesen.github.io/kirpi-flappy-bird-game/">🎮 Play Now</a>
    </td>
    <td align="center">
      <b>Snake</b><br>
      <a href="URL_BURAYA">
        <img src="https://github.com/erayzesen/kirpi-snake-game/raw/master/media/gameplay.gif" width="250">
      </a><br>
      <a href="https://github.com/erayzesen/kirpi-snake-game">🦔 Repo</a> | 
      <a href="https://erayzesen.github.io/kirpi-snake-game/">🎮 Play Now</a>
    </td>
  </tr>
</table>


## Documentation
The examples repo is [here](https://github.com/erayzesen/kirpi-examples).

Kirpi doesn’t have fancy tutorials yet. But honestly, the entire API is basically the cheatsheet below. We weren’t joking about the simplicity of the API.
<details>
<summary> Cheatsheet </summary>

```nim
### CALLBACK FUNCTIONS
load()     # to do one-time setup of your game
update(dt:float)   # which is used to manage your game's state frame-to-frame
draw()     #  which is used to render the game state onto the screen
config(settings:AppSettings) = # which is used to config the game app
    #all properties with default values.

    settings.fps=60
    settings.printFPS=false
    settings.printFrameTime=false

    settings.defaultTextureFilter=TextureFilterSettings.Linear
    settings.antialias=true

    
    setting.iconPath=""  # Should be RGBA 32bit PNG
    settings.window.width=800   
    settings.window.height=600  
    settings.window.borderless=false
    settings.window.resizeable= false
    settings.window.minWidth=1
    settings.window.minHeight=1
    settings.window.fullscreen=false
    settings.window.alwaysOnTop=false

getFramesPerSecond() # Returns FPS
getFrameMiliseconds() # Returns time in seconds for last frame (delta time)
getTime() # Returns the elapsed time in seconds since the application started.

#  opens a window and runs the game 
run(title:string,load: proc(), update: proc(dt:float), draw: proc(), config : proc (settings : var AppSettings)=nil)  


### GRAPHICS
#Coordinate System
applyTransform(t: Transform)  #applies the given Transform object to the current coordinate transformation.	
origin()   #resets the current coordinate transformation. 
push()     #copies and pushes the current coordinate transformation to the transformation stack.
pop()      #pops the current coordinate transformation from the transformation stack.
translate(dx:float,dy:float)   #translates the coordinate system in two dimensions.
rotate(angle:float)    #rotates the coordinate system in two dimensions.	
scale(sx:float,sy:float)   #scales the coordinate system in two dimensions.	
shear(shx:float,shy:float)     #shears the coordinate system.	
transformPoint(x:float,y:float)    #converts the given 2D position from global coordinates into screen-space.	
inverseTransformPoint(x:float,y:float)    #converts the given 2D position from screen-space into global coordinates.	
replaceTransform(t: Transform)    #replaces the current coordinate transformation with the given Transform object.


#Object Creation
newTexture(filename:string):Texture    #creates a new Texture.
newFont(filename:string, antialias:bool=true, rasterSize:int=32):Font #creates a new Font
newShader(vertexShaderFile: string, fragmentShaderFile: string) #creates a new shader. If you don't want to use a vertex shader, set the vertexShaderFile argument to an empty string("")
newText(text:string, font:ptr rl.Font):Text    #creates a new drawable Text object.
newQuad(x,y,width,height,sw,sh:int):Quad  #creates a new Quad.
newQuad(x,y,width,height:int, texture:var Texture):Quad   #creates a new Quad (it just uses the texture to get width&height properties).
newSpriteBatch(texture:var Texture, maxSprites:int=1000): SpriteBatch     #creates a new SpriteBatch

#Drawing State
setColor (r:uint8, g:uint8,b:uint8, a:uint8)  #sets the color used for drawing.
setColor (color:Color)     #sets the color used for drawing.	
getColor () :Color   #gets the current color
setLine(width:float,joinType:JoinTypes=JoinTypes.Miter,beginCap:CapTypes,endCap:CapTypes=beginCap)   # sets the line stroke parameters (width, join type, and cap styles).
setLineWidth(width:float)   #sets the line stroke width.
getLineWidth():float    #returns the current line stroke width.
setLineJoin(joinType:JoinTypes)      # sets the line join style.
getLineJoin()    # returns the current line join style.
setLineCaps(beginCap:CapTypes,endCap:CapTypes=beginCap)  # sets the line cap style for the start and end of strokes.
getLineBeginCap():CapTypes  # returns the line cap style used at the beginning of strokes.
getLineEndCap():CapTypes  # returns the line cap style used at the end of strokes.
setFont(font:rl.Font) #sets the font
getFont() :Font   #returns the current font
getDefaultFont() :Font  #returns the framework's default font.
pushState()     #copies the current drawing state (color, line settings, font, etc.) and pushes it onto the state stack.
popState()      #restores the previous drawing state by popping it from the state stack.
resetState()    # resets the current drawing state (color, line settings, font, etc.) back to its default values.Does not affect previously saved states in the stack.

#Drawing
polygon(mode:DrawModes,points:varargs[float])   #draws a polygon
line(points:varargs[float])     #draws lines between points
arc(mode:DrawModes,arcType:ArcType, x:float,y:float,radius:float,angle1:float,angle2:float,segments:int=16)     #draws an arc
circle(mode:DrawModes,x:float,y:float,radius:float)     #draws a circle
ellipse(mode:DrawModes,x:float,y:float,radiusX:float,radiusY:float) #draws an ellipse.
rectangle(mode:DrawModes,x:float,y:float,width:float,height:float,rx:float=0,ry:float=rx,segments:int=12)   #draws a rectangle
quad(mode:DrawModes,x1:float,y1:float,x2:float,y2:float,x3:float,y3:float,x4:float,y4:float)    #draws a quadrilateral shape.
pixel(x:float,y:float)  #Draws a pixel.
draw(texture:Texture, x:float=0.0,y:float=0.0)  #draws a texture
draw(texture:Texture, quad:Quad, x:float=0.0,y:float=0.0)   #draws a texture with the specified quad 
draw(spriteBatch:SpriteBatch, x:float=0,y:float=0)  #draws a spritebatch
draw(text:Text ,x:float=0.0,y:float=0.0, size:float=16, spacing:float=1.0 )     #draws a text
clear()     #clears the screen with the active color.
clear(color:Color)     #clears the screen with the specified color.

#Text Methods 
getSizeWith(text:Text,fontSize:float,spacing:float=1.0) :tuple[x:float,y:float] # returns the text size using the specified font size and spacing.

#SpriteBatch Methods 
#adds an instance to SpriteBatch
add(spriteBatch: var SpriteBatch,x,y:float,r:float=0,sx:float=1,sy:float=1,ox:float=0,oy:float=0,kx:float=0,ky:float=0):int
#adds an instance to SpriteBatch with Quad
add(spriteBatch: var SpriteBatch, quad:Quad, x,y:float,r:float=0,sx:float=1,sy:float=1,ox:float=0,oy:float=0,kx:float=0,ky:float=0):int 

#Shader Methods  
setShader(shader:Shader) #  sets the specified shader for subsequent drawing operations. 
setShader() # Unsets the currently active shader.
setValue(shader: Shader, uniformName: string, value: float) # sets the value of a float-typed uniform.
setValue(shader: Shader, uniformName: string, value: int) #sets the value of a int-typed uniform.
setValue(shader: Shader, uniformName: string, value: (float,float)) #sets the value of a vec2-typed uniform.
setValue(shader: Shader, uniformName: string, value: (float,float,float))  #sets the value of a vec3-typed uniform.
setValue(shader: Shader, uniformName: string, value: (float,float,float,float)) #sets the value of a vec4-typed uniform.
setValue(shader: Shader, uniformName: string, value: (int,int)) #sets the value of a Ivec2-typed uniform.
setValue(shader: Shader, uniformName: string, value: (int,int,int))  #sets the value of a Ivec3-typed uniform.
setValue(shader: Shader, uniformName: string, value: (int,int,int,int)) #sets the value of a Ivec4-typed uniform.
setValue(shader: Shader, uniformName: string, value:Texture) #sets the value of a texture-typed uniform.

### SOUND
newSound(fileName:string, soundType:SoundType)  #creates a sound.

play(sound:Sound)  #plays the specified sound.	
stop(sound:Sound)  #stops the specified sound.
pause(sound:Sound)     #Pauses the specific sound.
resume(sound:Sound)    #Resumes the specific sound.

isPlaying(sound:Sound) #returns whether the specific sound is playing
isValid(sound:Sound) #returns whether the specific sound is valid

setVolume(sound:Sound)    #sets the volume of the specified sound
setPitch(sound:Sound)    #sets the pitch of the specified sound
setPan(sound:Sound)    #sets the pan of the specified sound

### INPUTS
#Keyboard
isKeyPressed(key:rl.KeyboardKey):bool     #checks if a key has been pressed once

isKeyReleased(key:rl.KeyboardKey):bool        #checks if a key has been released once

isKeyDown(key:rl.KeyboardKey):bool        #checks if a key is being pressed

isKeyUp(key:rl.KeyboardKey):bool      #checks if a key is not being pressed

getKeyPressed():KeyboardKey     #get key pressed (keycode), call it multiple times for keys queued, returns KeyboardKey.Null when the queue is empty

getCharPressed():Rune     #get char pressed (unicode), call it multiple times for chars queued, returns 0.Rune when the queue is empty


#Mouse
isMouseButtonPressed(button:rl.MouseButton):bool   #checks if a mouse button has been pressed once

isMouseButtonReleased(button:rl.MouseButton):bool  #checks if a mouse button has been released once

isMouseButtonDown(button:rl.MouseButton):bool  #checks if a mouse button is being pressed

isMouseButtonUp(button:rl.MouseButton):bool    #checks if a mouse button is not being pressed

getMouseX():int    #returns mouse position x

getMouseY():int    #returns mouse position y

#Gamepad
isGamepadAvailable(gamepad:int):bool       #checks if a gamepad is available

getGamepadName(gamepad:int):string     #returns gamepad internal name id

isGamepadButtonPressed(gamepad:int, button:rl.GamepadButton):bool      #checks if a gamepad button has been pressed once

isGamepadButtonReleased(gamepad:int, button:rl.GamepadButton):bool     #checks if a gamepad button has been released once

isGamepadButtonDown(gamepad:int, button:rl.GamepadButton):bool     #checks if a gamepad button is being pressed

isGamepadButtonUp(gamepad:int, button:rl.GamepadButton):bool       #checks if a gamepad button is not being pressed

getGamepadAxisCount(gamepad:int):int       #returns gamepad axis count for a gamepad

getGamepadAxisMovement(gamepad:int, axis:rl.GamepadAxis):float     #returns axis movement value for a gamepad axis

setGamepadMappings(mappings:string): int32     #set internal gamepad mappings (SDL_GameControllerDB)

setGamepadVibration(gamepad:int, leftMotor:float, rightMotor:float, duration:float)   #set gamepad vibration for both motors (duration in seconds)

#Touch
getTouchX():int    #get touch position x for touch point 0 (relative to screen size)

getTouchY():int    #get touch position Y for touch point 0 (relative to screen size)

getTouchPointId(index:int):int     #get touch point identifier for given index

getTouchPointCount():int   #get number of touch points

getTouchHoldDuration(index:int):float  #get touch hold time in seconds

getTouchDragX(index:int):float     #get touch drag vector x

getTouchDragY(index:int):float     #get touch drag vector y

getTouchDragAngle():float  #get touch drag angle

getTouchPinchX() :float    #get gesture pinch delta x

getTouchPinchY() :float    #get gesture pinch delta y

getTouchPinchAngle():float     #get gesture pinch angle

#WINDOW
setFullScreenMode(value:bool)   #sets window state: fullscreen/windowed, resizes monitor to match window resolution
getFullScreenMode(): bool   #checks if window is currently fullscreen
setBorderlessMode(value: bool )     #sets window state: borderless windowed, resizes window to match monitor resolution
getBorderlessMode() :bool   #checks if window state is currently borderless

setMinSize(width:int=1,height:int=1)  #sets window minimum dimensions (for resizeable windows)
setFocused()   #sets window focused
isFocused(): bool  #checks if window is currently focused
isResized(): bool  #checks if window has been resized last frame
setTitle(title:string)    #sets title for window
getWidth() : int   #returns current window width
getHeight() : int  #returns current window height

#JAVASCRIPT
eval(code: string): string   # Executes JS code and returns result as string.
createCallback(cb: JSCallback; jsEvent: cstring)  # Registers a callback that receives JS event data as JSON. (JSCallback type is: proc(arg: cstring){.cdecl.}  )
createCallback(cb: JSCallbackVoid; jsEvent: cstring) # Registers a more performant callback thanks to no event data arguments (JSCallbackVoid type is: proc(){.cdecl.} )

```
</details>

## Contributing
* To contribute code to the project, please try to follow Nim’s standard library [style guide](https://nim-lang.org/docs/nep1.html). We generally strive to maintain consistency with it throughout this project.(You might not like this guide, but after all, it’s a prepared style guide that everyone can access and use collectively.)
* We avoid using macros and metaprogramming unless absolutely necessary. Please refrain from using them unnecessarily; this project is intended to be readable even by newcomers to Nim, in its simplest form.
* We aim to keep the API minimal and avoid expanding or changing it unless truly necessary. Feel free to suggest ideas, but please don’t take offense at any potential negative feedback.
* This project uses Naylib (Nim’s Raylib wrapper) as its backend. The backend is actually where we are most flexible. If you have ideas for alternative implementations—for example, a Pixi.js backend for the JS target, or a backend that could extend the framework to consoles and more platforms, or a fully Nim-written, cross-platform library to replace Raylib—these kinds of contributions are very welcome.
* You can also contribute separate Nim modules aimed at the ecosystem rather than the framework repository itself, which we really appreciate. We can even list these modules here.
* If you’re not interested in development, creating tutorials is a significant way to contribute, and we’d be happy to share them in our repository.
* If you’re not interested in development and can’t create tutorials, reporting bugs or opening issues about usability problems is also highly valued.

## What's mean kirpi?
"Hedgehog” in my native language Turkish is “kirpi.” 
Its pronunciation is /keer-pee/.We like hedgehogs and we share the games and prototypes we build with kirpi using the **#madewithkirpi** tag.
