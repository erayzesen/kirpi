# Raylib

import tables,std/private/ospaths2
import raylib as rl


import graphics, inputs, sound, window

type
  WindowSettings* = object
    iconPath*:string=""
    width*:int=800
    height*:int=600
    borderless*:bool=false
    resizeable*:bool= false
    minWidth*:int=1
    minHeight*:int=1
    fullscreen*:bool=false
    alwaysOnTop*:bool=false

  TextureFilterSettings = enum 
    Linear,
    Nearest

  AppSettings* = object
    #Window
    window*:WindowSettings
    fps*:int=60
    printFPS*:bool=false
    printFrameTime*:bool=false
    defaultTextureFilter*:TextureFilterSettings=TextureFilterSettings.Linear
    antialias=true
    
  App* = object
    settings:AppSettings
    load: proc() 
    draw: proc()  
    update: proc(dt:float) 
    
  AppWindow* = object #A Wrapper solution for raylib issues about closing window time
  

var kirpiApp*:App=App()
var appWindow:AppWindow


proc `=destroy`(app:var AppWindow) =
  assert isWindowReady(), "Window is already closed!"
  echo "appWindow"
  #resources clear
  fonts.clear()
  
  closeAudioDevice()
  closeWindow()


proc `=sink`(x: var AppWindow; y: AppWindow) {.error.}
proc `=dup`(y: AppWindow): AppWindow {.error.}
proc `=copy`(x: var AppWindow; y: AppWindow) {.error.}
proc `=wasMoved`(x: var AppWindow) {.error.}

#Frame Time Properties
var fpsTimer = 0.0
var enablePrintFPS:bool=false
var enablePrintFrameTime:bool=false
var fps:int=0
var frameMS:float=0.0


proc getFramesPerSecond*():int =
  result=fps

proc getFrameMiliSeconds*():float =
  result=frameMS

proc getTime*() : float =
  result=rl.getTime()


#Window

proc initAppWindow(title:string,appSettings:AppSettings) =
  assert not isWindowReady(), "Window is already opened"
  
  var flg:uint32=0
  if appSettings.window.resizeable :
    flg=flg or uint32(WindowResizable)

  if appSettings.window.borderless :
    flg=flg or uint32(BorderlessWindowedMode)
    
  if appSettings.window.alwaysOnTop :
    flg=flg or uint32(WindowTopmost)

  if appSettings.antialias==true :
    flg=flg or uint32(Msaa4xHint)


  var allFlags:Flags[ConfigFlags]=Flags[ConfigFlags]( flg  )
  setConfigFlags(allFlags)

  initWindow( int32(appSettings.window.width), int32(appSettings.window.height), title)

  window.setMinSize(appSettings.window.minWidth,appSettings.window.minHeight)

  if appSettings.window.fullscreen :
    window.setFullScreenMode(true)

  setTargetFPS(int32(appSettings.fps))
  enablePrintFrameTime=appSettings.printFrameTime
  enablePrintFPS=appSettings.printFPS
  

  if appSettings.defaultTextureFilter==TextureFilterSettings.Nearest :
    graphics.defaultFilter=TextureFilters.Nearest
  
  if appSettings.window.iconPath!="" :
    var iconIMG=loadImage(appSettings.window.iconPath)
    if isImageValid(iconIMG) :
      setWindowIcon(iconIMG)
    else :
      var defaultIconIMG=loadImage(currentSourcePath.parentDir() & "/resources/icon.png")
      setWindowIcon(defaultIconIMG)
  else :
    var defaultIconIMG=loadImage(currentSourcePath.parentDir() & "/resources/icon.png")
    setWindowIcon(defaultIconIMG)

  initAudioDevice()

  setExitKey(KeyboardKey.Null)
  



proc run*(title:string,load: proc(), update: proc(dt:float), draw: proc(), config : proc (settings : var AppSettings)=nil) =
  kirpiApp.load = load
  kirpiApp.update = update
  kirpiApp.draw = draw
  if config!=nil :
    config(kirpiApp.settings)
  initAppWindow(title,kirpiApp.settings)
  graphics.defaultFont=newFont("src/resources/RobotoSlab-Regular.ttf")
  setFont(graphics.defaultFont)
  setColor(White)

  kirpiApp.load() # load 

  while not windowShouldClose() :
    #Update Sound Streams
    for id in soundStreamSources.keys:
      rl.updateMusicStream(soundStreamSources[id])
    
    kirpiApp.update(getFrameTime() ) # update 

    beginDrawing()
    kirpiApp.draw() # draw
    
    endDrawing()

    
    let dt = 1.0 / 60.0
    fpsTimer += dt
    fps=getFPS()
    if fpsTimer >= 1.0:
      frameMS=getFrameTime() * 1000.0
      if enablePrintFrametime :
        echo "Frame Time: " & $frameMS & " ms"
      if enablePrintFPS :
        echo "FPS: " & $fps
      fpsTimer = 0.0
   



export graphics except defaultFilter,shaders,fonts
export inputs, window
export sound 