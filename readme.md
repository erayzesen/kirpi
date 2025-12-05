
<div align="center">

![logo](media/logo.png) 

</div>

A lightweight 2D game framework featuring a clean, LÖVE2D-inspired graphics API (LÖVE2D developers will feel right at home). It uses Naylib (Raylib) as its well-maintained cross-platform backend within the Nim ecosystem.

**Supported Build Targets:** Web(Wasm),Linux,Windows,Macos,Android 

> 🚧 **Note:** This project is currently under development and has not yet reached a stable release. If you like the project, you can support it with a star, try it out and report any issues or bugs, and contribute to its further development.

## Why kirpi?
* Very small Web builds. An empty project ships at around 400–500 KB, and 150–200 KB when zipped — almost comparable to JavaScript game frameworks.
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
    sampleText=newText("Hello World!",getFont())

proc update(dt: float) =
    if isKeyPressed(KeyEscape):
        quit()

proc draw() =
    setColor(Black)
    clear()
    setColor(White)
    draw(sampleText,100,100)

run( "sample game",load update, draw)

```

However, for smooth builds across all supported platforms and an ideal folder structure, we recommend using the [kirpi_app_template](https://github.com/erayzesen/kirpi_app_template) repository. This repo also includes extensively customized compiler configuration files, thanks in part to the Naylib community, which automate nearly everything for Android builds. Additionally, we provide customized Emscripten configurations for Web builds. In short, you can deploy your project to Android with just a few commands, and to other platforms with a single command. Detailed build instructions are available in our template repository.



## Documentation
Kirpi doesn’t have fancy tutorials yet. But honestly, the entire API is basically the cheatsheet below. We weren’t joking about the simplicity of the API.
<details>
<summary> Cheatsheet </summary>

```nim
### CALLBACK FUNCTIONS
load()     # to do one-time setup of your game
update(dt:float)   # which is used to manage your game's state frame-to-frame
draw()     #  which is used to render the game state onto the screen
config(settings:AppSettings) = # which is used to config the game app
    #all properties
    settings.fps=60
    
    settings.window.width=800   
    settings.window.height=600  
    settings.window.borderless=false
    settings.window.resizeable= false
    settings.window.minWidth=1
    settings.window.minHeight=1
    settings.window.fullscreen=false
    settings.window.alwaysOnTop=false

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
newText(text:string, font:ptr rl.Font):Text    #creates a new drawable Text object.
newFont(filename:string):Font  #creates a new Font
newQuad(x,y,width,height,sw,sh:int):Quad  #creates a new Quad.
newQuad(x,y,width,height:int, texture:var Texture):Quad   #creates a new Quad.
newSpriteBatch(texture:var Texture, maxSprites:int=1000): SpriteBatch     #creates a new SpriteBatch

#Drawing State
setColor (r:uint8, g:uint8,b:uint8, a:uint8)  #sets the color used for drawing.
setColor (color:Color)     #sets the color used for drawing.	
getColor () :Color   #gets the current color
setLine(width:float)  #sets the line width.
getLine():float   #gets the current line width
setFont(font:rl.Font) #sets the font
getFont() :Font   #gets the current font

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

### SOUND
newSound(fileName:string, soundType:SoundType)  #creates a sound.

playSound(sound:Sound)  #plays the specified sound.	
stopSound(sound:Sound)  #stops the specified sound.
pauseSound(sound:Sound)     #Pauses the specific sound.
resumeSound(sound:Sound)    #Resumes the specific sound.

isSoundPlaying(sound:Sound) #returns whether the specific sound is playing
isSoundValid(sound:Sound) #returns whether the specific sound is valid

setSoundVolume(sound:Sound)    #sets the volume of the specified sound
setSoundPitch(sound:Sound)    #sets the pitch of the specified sound
setSoundPan(sound:Sound)    #sets the pan of the specified sound

### INPUTS
#Keyboard
isKeyPressed(key:rl.KeyboardKey):bool     #checks if a key has been pressed once

isKeyReleased(key:rl.KeyboardKey):bool        #checks if a key has been released once

isKeyDown(key:rl.KeyboardKey):bool        #checks if a key is being pressed

isKeyUp(key:rl.KeyboardKey):bool      #checks if a key is not being pressed

getCharPressed():int32        #get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty

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