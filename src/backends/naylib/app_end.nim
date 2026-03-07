#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import raylib as rl

import settings_end

#region Backend Needs
type 
    App* = object
        settings:Settings=Settings()
        load: proc() 
        draw: proc()  
        update: proc(dt:float) 

    AppWindow* = object #A Wrapper solution for raylib issues about closing window time


var app*:App=App()
var appWindow:AppWindow

proc init*(appBackendSettings:Settings)
proc deinit*()
proc runApp*(load: proc(), update: proc(dt:float), draw: proc())
proc getFPS*():int
proc getFrameMiliSeconds*():float
proc getTime*() : float 

#endregion


#Emscripten /Web Main Loop Fix Wrapper (We don't want to use Asyncify on the web targets)
#https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5)#41-avoid-raylib-whilewindowshouldclose-loop

when defined(emscripten):
  type GameData = object
    shouldClose: bool

  var gameData: GameData
  proc emscripten_set_main_loop_arg(
    f: proc(arg: pointer) {.cdecl.},
    arg: pointer,
    fps: cint,
    simulateInfiniteLoop: cint
  ) {.importc, cdecl, header: "<emscripten/emscripten.h>".}


proc `=destroy`(app:var AppWindow) =
  assert isWindowReady(), "Window is already closed!"
  echo "Closing Audio Device... "
  
  
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


proc getFPS*():int =
    discard

proc getFrameMiliSeconds*():float =
    discard

proc getTime*() : float =
    discard

proc initAppWindow()=
    assert not isWindowReady(), "Window is already opened"
  
    var flg:uint32=0
    if app.settings.resizeable :
        flg=flg or uint32(WindowResizable)

    if app.settings.borderless :
        flg=flg or uint32(BorderlessWindowedMode)
        
    if app.settings.alwaysOnTop :
        flg=flg or uint32(WindowTopmost)

    if app.settings.antialias==true :
        flg=flg or uint32(Msaa4xHint)


    var allFlags:Flags[ConfigFlags]=Flags[ConfigFlags]( flg  )
    rl.setConfigFlags(allFlags) 

    rl.initWindow( int32(app.settings.width), int32(app.settings.height), app.settings.title)

    rl.setWindowMinSize( app.settings.minWidth.int32,app.settings.minHeight.int32 )

    setTargetFPS(int32(app.settings.targetFPS))

    enablePrintFrameTime=app.settings.printFrameTime
    enablePrintFPS=app.settings.printFPS


    setExitKey(KeyboardKey.Null)
    

proc appLoop(arg: pointer) {.cdecl.} =
      #Update Sound Streams
    #[ for id in soundStreamSources.keys:
        rl.updateMusicStream(soundStreamSources[id]) ]#
    
    app.update(getFrameTime() ) # update 

    beginDrawing()
    app.draw() # draw
    
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

proc runApp*(load: proc(), update: proc(dt:float), draw: proc()) =
    app.load = load
    app.update = update
    app.draw = draw


    app.load() # load 

    when defined(emscripten):
        emscripten_set_main_loop_arg(appLoop,addr gameData,0.cint, 1.cint)
    else :
        while not windowShouldClose() :
            appLoop(nil)

    
proc init*(appBackendSettings:Settings) =
    app.settings=appBackendSettings
    initAppWindow()
    
proc deinit*()=
    discard