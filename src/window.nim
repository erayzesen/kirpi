#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import backends/naylib/window_end

# Saving Monitor Resolution to fullscreen operations

proc setFullScreenMode*(value:bool) =
    window_end.setFullScreenMode(value)


proc getFullScreenMode*() :bool =
    result=window_end.getFullScreenMode()

proc setBorderlessMode*(value: bool ) =
    window_end.setBorderlessMode(value)

proc getBorderlessMode*() :bool =
    result= window_end.getBorderlessMode()


proc setMinSize*(width:int=1,height:int=1)  =
    window_end.setMinSize(width,height )

proc setFocused*() =
    window_end.setFocused()

proc isFocused*() :bool =
    result=window_end.isFocused()

proc isResized*() : bool =
    result=window_end.isResized()

proc setTitle*(title:string) =
    window_end.setTitle(title)

proc getWidth*() : int =
    result=window_end.getWidth()

proc getHeight*() : int =
    result=window_end.getHeight()