#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import rsc

import graphics, inputs, sound, window, javascript
#backends
import backends/naylib/settings_end
import backends/naylib/app_end
import backends/naylib/graphics_end
import backends/naylib/sound_end
import backends/naylib/inputs_end
import backends/naylib/window_end



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
    antialias*:bool=true
    
  



proc getFramesPerSecond*():int =
  result=app_end.getFPS()

proc getFrameMiliSeconds*():float =
  result=app_end.getFrameMiliSeconds()

proc getTime*() : float =
  result=app_end.getTime()



proc run*(title:string,load: proc(), update: proc(dt:float), draw: proc(), config : proc (settings : var AppSettings)=nil) =

  var kirpiAppSettings:AppSettings=AppSettings()
  if config!=nil :
    config(kirpiAppSettings)

  var appBackendSettings:Settings=Settings()

  appBackendSettings.title=title
  appBackendSettings.width=kirpiAppSettings.window.width
  appBackendSettings.height=kirpiAppSettings.window.height
  appBackendSettings.resizeable=kirpiAppSettings.window.resizeable
  appBackendSettings.borderless=kirpiAppSettings.window.borderless
  appBackendSettings.alwaysOnTop=kirpiAppSettings.window.alwaysOnTop
  appBackendSettings.iconPath=kirpiAppSettings.window.iconPath
  appBackendSettings.minWidth=kirpiAppSettings.window.minWidth
  appBackendSettings.minHeight=kirpiAppSettings.window.minHeight
  appBackendSettings.fullscreen=kirpiAppSettings.window.fullscreen
  appBackendSettings.antialias=kirpiAppSettings.antialias
  appBackendSettings.targetFPS=kirpiAppSettings.fps
  appBackendSettings.printFrameTime=kirpiAppSettings.printFrameTime
  appBackendSettings.printFPS=kirpiAppSettings.printFPS

 
  app_end.init(appBackendSettings)
  window_end.init(appBackendSettings)
  sound_end.init(appBackendSettings)
  graphics_end.init(appBackendSettings)
  inputs_end.init(appBackendSettings)
  

  
  setColor(White)

   #Loading default font from data
  var defaultFontID=graphics_end.loadFontWithData("kirpi_default_font",".ttf",rsc.defaultFontData,kirpiAppSettings.antialias,36)
  graphics.defaultFont=graphics.Font( id:defaultFontID)
  setFont(graphics.defaultFont)

  #Init backends
  
  

  if kirpiAppSettings.window.fullscreen==true :
    window.setFullScreenMode(true)

  if kirpiAppSettings.defaultTextureFilter==TextureFilterSettings.Nearest :
    graphics.defaultFilter=TextureFilters.Nearest

  app_end.runApp(load, update, draw)


  app_end.deinit()
  window_end.deinit()
  graphics_end.deinit()
  sound_end.deinit()
  inputs_end.deinit()

  
   



export graphics 
export inputs, window
export sound 
export javascript