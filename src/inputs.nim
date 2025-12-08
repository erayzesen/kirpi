import raylib as rl


#KeyBoard
proc isKeyPressed*(key:rl.KeyboardKey):bool =
    return rl.isKeyPressed(key)

proc isKeyReleased*(key:rl.KeyboardKey):bool =
    return rl.isKeyReleased(key)

proc isKeyDown*(key:rl.KeyboardKey):bool =
    return rl.isKeyDown(key)

proc isKeyUp*(key:rl.KeyboardKey):bool =
    return rl.isKeyUp(key)

proc getCharPressed*():int32 =
    return rl.getCharPressed()

#Mouse 
proc isMouseButtonPressed*(button:rl.MouseButton):bool =
    return rl.isMouseButtonPressed(button)

proc isMouseButtonReleased*(button:rl.MouseButton):bool =
    return rl.isMouseButtonReleased(button)

proc isMouseButtonDown*(button:rl.MouseButton):bool =
    return rl.isMouseButtonDown(button)

proc isMouseButtonUp*(button:rl.MouseButton):bool =
    return rl.isMouseButtonUp(button)

proc getMouseX*():float =
    return float( rl.getMouseX() )

proc getMouseY*():float =
    return float( rl.getMouseY() )

#Gamepad

proc isGamepadAvailable*(gamepad:int):bool =
    return rl.isGamepadAvailable(int32(gamepad) )

proc getGamepadName*(gamepad:int):string =
    return rl.getGamepadName(int32(gamepad))

proc isGamepadButtonPressed*(gamepad:int, button:rl.GamepadButton):bool =
    return rl.isGamepadButtonPressed(int32(gamepad), button)

proc isGamepadButtonReleased*(gamepad:int, button:rl.GamepadButton):bool =
    return rl.isGamepadButtonReleased(int32(gamepad), button)

proc isGamepadButtonDown*(gamepad:int, button:rl.GamepadButton):bool =
    return rl.isGamepadButtonDown(int32(gamepad), button)

proc isGamepadButtonUp*(gamepad:int, button:rl.GamepadButton):bool =
    return rl.isGamepadButtonUp(int32(gamepad), button)

proc getGamepadAxisCount*(gamepad:int):int =
    return int(rl.getGamepadAxisCount(int32(gamepad)))

proc getGamepadAxisMovement*(gamepad:int, axis:rl.GamepadAxis):float =
    return rl.getGamepadAxisMovement(int32(gamepad), axis)

proc setGamepadMappings*(mappings:string): int32 =
    return rl.setGamepadMappings(mappings)

proc setGamepadVibration*(gamepad:int, leftMotor:float, rightMotor:float, duration:float) =
    rl.setGamepadVibration(int32(gamepad), float32(leftMotor), float32(rightMotor), float32(duration)) 

#Touch
proc getTouchX*():float =
    return float(rl.getTouchX() )

proc getTouchY*():float =
    return float(rl.getTouchY() )

proc getTouchPointId*(index:int):int =
    return int(rl.getTouchPointId(int32(index)) )

proc getTouchPointCount*():int =
    return int(rl.getTouchPointCount() )

proc getTouchHoldDuration*(index:int):float =
    return float( rl.getGestureHoldDuration() )

proc getTouchDragX*(index:int):float =
    return rl.getGestureDragVector().x

proc getTouchDragY*(index:int):float =
    return rl.getGestureDragVector().y

proc getTouchDragAngle*():float =
    return rl.getGestureDragAngle()

proc getTouchPinchX*() :float =
    return rl.getGesturePinchVector().x

proc getTouchPinchY*() :float =
    return rl.getGesturePinchVector().y

proc getTouchPinchAngle*():float =
    return rl.getGesturePinchAngle()

export KeyboardKey, MouseButton, GamepadButton, GamepadAxis