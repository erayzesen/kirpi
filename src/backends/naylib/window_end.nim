#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import raylib as rl
import settings_end

#region Backend Needs
proc init*(appBackendSettings:Settings)
proc deinit*()
proc setFullScreenMode*(value:bool)
proc getFullScreenMode*() :bool
proc setBorderlessMode*(value: bool )
proc getBorderlessMode*() :bool 
proc setMinSize*(width:int=1,height:int=1)
proc setFocused*()
proc isFocused*() :bool
proc isResized*() : bool 
proc setTitle*(title:string) 
proc getWidth*() : int 
proc getHeight*() : int 


#endregion

#region Methods & Properties

proc init*(appBackendSettings:Settings) =
    discard
proc deinit*() =
    discard

# Saving Monitor Resolution to fullscreen operations

var mWidthBeforeFullScreen:int32
var mHeightBeforeFullScreen:int32

var wWidthBeforeFullScreen:int32
var wHeightBeforeFullScreen:int32

proc setFullScreenMode*(value:bool) =
    if value==true and isWindowFullscreen()==false :
        wWidthBeforeFullScreen=getScreenWidth()
        wHeightBeforeFullScreen=getScreenHeight()
        mWidthBeforeFullScreen=getMonitorWidth(getCurrentMonitor() )
        mHeightBeforeFullScreen=getMonitorHeight(getCurrentMonitor() )
        setWindowSize(mWidthBeforeFullScreen,mHeightBeforeFullScreen)
        toggleFullscreen()
    elif value==false and isWindowFullscreen()==true :
        toggleFullscreen()
        setWindowSize(wWidthBeforeFullScreen,wHeightBeforeFullScreen)

proc getFullScreenMode*() :bool =
    result=isWindowFullscreen()

proc setBorderlessMode*(value: bool ) =
    if value==true and isWindowState(BorderlessWindowedMode)==false :
        toggleBorderlessWindowed()
    elif value==false and isWindowState(BorderlessWindowedMode)==true :
        toggleBorderlessWindowed()

proc getBorderlessMode*() :bool =
    result= isWindowState(BorderlessWindowedMode)


proc setMinSize*(width:int=1,height:int=1)  =
    rl.setWindowMinSize( int32(width),int32(height) )

proc setFocused*() =
    setWindowFocused()

proc isFocused*() :bool =
    result=rl.isWindowFocused()

proc isResized*() : bool =
    result=rl.isWindowResized()

proc setTitle*(title:string) =
    setWindowTitle(title)

proc getWidth*() : int =
    result=getRenderWidth()

proc getHeight*() : int =
    result=getRenderHeight()

#endregion