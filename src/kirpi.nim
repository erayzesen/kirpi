# Raylib

import tables
import raylib as rl

import graphics, inputs, sound, window




type
  WindowSettings* = object
    width*:int=800
    height*:int=600
    borderless*:bool=false
    resizeable*:bool= false
    minWidth*:int=1
    minHeight*:int=1
    fullscreen*:bool=false
    alwaysOnTop*:bool=false


  AppSettings* = object
    #Window
    window*:WindowSettings
    fps*:int=60
    
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
  closeAudioDevice()
  closeWindow()




proc `=sink`(x: var AppWindow; y: AppWindow) {.error.}
proc `=dup`(y: AppWindow): AppWindow {.error.}
proc `=copy`(x: var AppWindow; y: AppWindow) {.error.}
proc `=wasMoved`(x: var AppWindow) {.error.}

proc initAppWindow(title:string,appSettings:AppSettings) =
  assert not isWindowReady(), "Window is already opened"
  
  var flg:uint32=0
  if appSettings.window.resizeable :
    flg=flg or uint32(WindowResizable)

  if appSettings.window.borderless :
    flg=flg or uint32(BorderlessWindowedMode)
    
  if appSettings.window.alwaysOnTop :
    flg=flg or uint32(WindowTopmost)


  var allFlags:Flags[ConfigFlags]=Flags[ConfigFlags]( flg  )
  setConfigFlags(allFlags)

  window.setMinSize(appSettings.window.minWidth,appSettings.window.minHeight)

  initWindow( int32(appSettings.window.width), int32(appSettings.window.height), title)

  if appSettings.window.fullscreen :
    window.setFullScreenMode(true)

  
  
  setTargetFPS(int32(appSettings.fps))
  initAudioDevice()
  kirpiApp.load() # load 


var fpsTimer = 0.0
proc run*(title:string,load: proc(), update: proc(dt:float), draw: proc(), config : proc (settings : var AppSettings)=nil) =
  kirpiApp.load = load
  kirpiApp.update = update
  kirpiApp.draw = draw
  if config!=nil :
    config(kirpiApp.settings)
  initAppWindow(title,kirpiApp.settings)

  while not windowShouldClose() :
    #Update Sound Streams
    for id in soundStreamSources.keys:
      rl.updateMusicStream(soundStreamSources[id])
        

    kirpiApp.update(1.0) # update 

    beginDrawing()
    kirpiApp.draw() # draw
    endDrawing()

    let dt = 1.0 / 60.0
    fpsTimer += dt
    if fpsTimer >= 1.0:
      echo "FPS: " & $(getFrameTime() * 1000.0) & " ms"
      fpsTimer = 0.0
    


export graphics, inputs, window
export sound 