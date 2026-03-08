#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE


import unicode
import inputs_map

import backends/naylib/inputs_end


#KeyBoard
proc isKeyPressed*(key:Key):bool =
    return inputs_end.isKeyPressed(key)

proc getKeyPressed*():Key =
    return inputs_end.getPressedKey()

proc isKeyReleased*(key:Key):bool =
    return inputs_end.isKeyReleased(key)

proc isKeyDown*(key:Key):bool =
    return inputs_end.isKeyDown(key)

proc isKeyUp*(key:Key):bool =
    return inputs_end.isKeyUp(key)

proc getCharPressed*():Rune =
    result=inputs_end.getPressedChar()


#Mouse 
proc isMouseButtonPressed*(button:MouseButton):bool =
    return inputs_end.isMouseButtonPressed(button)

proc isMouseButtonReleased*(button:MouseButton):bool =
    return inputs_end.isMouseButtonReleased(button)

proc isMouseButtonDown*(button:MouseButton):bool =
    return inputs_end.isMouseButtonDown(button)

proc isMouseButtonUp*(button:MouseButton):bool =
    return inputs_end.isMouseButtonUp(button)

proc getMouseX*():float =
    return inputs_end.getMouseX()

proc getMouseY*():float =
    return inputs_end.getMouseY()

#Gamepad

proc isGamepadAvailable*(gamepad:int):bool =
    return inputs_end.isGamepadAvailable(gamepad )

proc getGamepadName*(gamepad:int):string =
    return inputs_end.getGamepadName(gamepad)

proc isGamepadButtonPressed*(gamepad:int, button:GamepadButton):bool =
    return inputs_end.isGamepadButtonPressed(gamepad, button)

proc isGamepadButtonReleased*(gamepad:int, button:GamepadButton):bool =
    return inputs_end.isGamepadButtonReleased(gamepad, button)

proc isGamepadButtonDown*(gamepad:int, button:GamepadButton):bool =
    return inputs_end.isGamepadButtonDown(gamepad, button)

proc isGamepadButtonUp*(gamepad:int, button:GamepadButton):bool =
    return inputs_end.isGamepadButtonUp(gamepad, button)

proc getGamepadAxisCount*(gamepad:int):int =
    return inputs_end.getGamepadAxisCount(int32(gamepad))

proc getGamepadAxisMovement*(gamepad:int, axis:GamepadAxis):float =
    return inputs_end.getGamepadAxisMovement(int32(gamepad), axis)

proc setGamepadMappings*(mappings:string) =
    inputs_end.setGamepadMappings(mappings)
    
proc setGamepadVibration*(gamepad:int, leftMotor:float, rightMotor:float, duration:float) =
    inputs_end.setGamepadVibration(gamepad, leftMotor, rightMotor, duration) 

#Touch
proc getTouchX*():float =
    return inputs_end.getTouchX()

proc getTouchY*():float =
    return inputs_end.getTouchY() 

proc getTouchPointId*(index:int):int =
    return inputs_end.getTouchPointId(index) 

proc getTouchPointCount*():int =
    return inputs_end.getTouchPointCount() 

proc getTouchHoldDuration*(index:int):float =
    return inputs_end.getTouchHoldDuration(index) 

proc getTouchDragX*(index:int):float =
    return inputs_end.getTouchDragX(index)

proc getTouchDragY*(index:int):float =
    return inputs_end.getTouchDragY(index)

proc getTouchDragAngle*():float =
    return inputs_end.getTouchDragAngle()

proc getTouchPinchX*() :float =
    return inputs_end.getTouchPinchX()

proc getTouchPinchY*() :float =
    return inputs_end.getTouchPinchY()

proc getTouchPinchAngle*():float =
    return inputs_end.getTouchPinchAngle()

export inputs_map