#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import raylib as rl
import tables
import unicode
import ../../inputs_map
import settings_end




#region Backend Needs

#Initialization
proc init*(appBackendSettings:Settings)
proc loop*()
proc deInit*()

#Keys
proc isKeyPressed*(key:inputs_map.Key) :bool
proc getPressedKey*():inputs_map.Key
proc isKeyReleased*(key:inputs_map.Key) : bool
proc isKeyDown*(key:inputs_map.Key) : bool 
proc isKeyUp*(key:inputs_map.Key) : bool

#Mouse
proc isMouseButtonPressed*(button:inputs_map.MouseButton):bool
proc isMouseButtonReleased*(button:inputs_map.MouseButton):bool 
proc isMouseButtonDown*(button:inputs_map.MouseButton):bool
proc isMouseButtonUp*(button:inputs_map.MouseButton):bool
proc getMouseX*():float
proc getMouseY*():float

#Gamepad
proc isGamepadAvailable*(gamepad:int):bool
proc getGamepadName*(gamepad:int):string
proc isGamepadButtonPressed*(gamepad:int, button:inputs_map.GamepadButton):bool
proc isGamepadButtonReleased*(gamepad:int, button:inputs_map.GamepadButton):bool
proc isGamepadButtonDown*(gamepad:int, button:inputs_map.GamepadButton):bool
proc isGamepadButtonUp*(gamepad:int, button:inputs_map.GamepadButton):bool
proc getGamepadAxisCount*(gamepad:int):int
proc getGamepadAxisMovement*(gamepad:int, axis:inputs_map.GamepadAxis):float
proc setGamepadMappings*(mappings:string)
proc setGamepadVibration*(gamepad:int, leftMotor:float, rightMotor:float, duration:float)

#Touch
proc getTouchX*():float
proc getTouchY*():float
proc getTouchPointId*(index:int):int
proc getTouchPointCount*():int
proc getTouchHoldDuration*(index:int):float
proc getTouchDragX*(index:int):float
proc getTouchDragY*(index:int):float
proc getTouchDragAngle*():float
proc getTouchPinchX*() :float
proc getTouchPinchY*() :float
proc getTouchPinchAngle*():float


#endregion

#region Input Tables

# Tables for mapping input enums between kirpi framework and the backend
#Keys
var kirpiKeyMap* = {
  inputs_map.Key.NULL:           rl.KeyboardKey.Null,
  inputs_map.Key.APOSTROPHE:     rl.KeyboardKey.Apostrophe,
  inputs_map.Key.COMMA:          rl.KeyboardKey.Comma,
  inputs_map.Key.MINUS:          rl.KeyboardKey.Minus,
  inputs_map.Key.PERIOD:         rl.KeyboardKey.Period,
  inputs_map.Key.SLASH:          rl.KeyboardKey.Slash,
  inputs_map.Key.ZERO:           rl.KeyboardKey.Zero,
  inputs_map.Key.ONE:            rl.KeyboardKey.One,
  inputs_map.Key.TWO:            rl.KeyboardKey.Two,
  inputs_map.Key.THREE:          rl.KeyboardKey.Three,
  inputs_map.Key.FOUR:           rl.KeyboardKey.Four,
  inputs_map.Key.FIVE:           rl.KeyboardKey.Five,
  inputs_map.Key.SIX:            rl.KeyboardKey.Six,
  inputs_map.Key.SEVEN:          rl.KeyboardKey.Seven,
  inputs_map.Key.EIGHT:          rl.KeyboardKey.Eight,
  inputs_map.Key.NINE:           rl.KeyboardKey.Nine,
  inputs_map.Key.SEMICOLON:      rl.KeyboardKey.Semicolon,
  inputs_map.Key.EQUAL:          rl.KeyboardKey.Equal,
  inputs_map.Key.A:              rl.KeyboardKey.A,
  inputs_map.Key.B:              rl.KeyboardKey.B,
  inputs_map.Key.C:              rl.KeyboardKey.C,
  inputs_map.Key.D:              rl.KeyboardKey.D,
  inputs_map.Key.E:              rl.KeyboardKey.E,
  inputs_map.Key.F:              rl.KeyboardKey.F,
  inputs_map.Key.G:              rl.KeyboardKey.G,
  inputs_map.Key.H:              rl.KeyboardKey.H,
  inputs_map.Key.I:              rl.KeyboardKey.I,
  inputs_map.Key.J:              rl.KeyboardKey.J,
  inputs_map.Key.K:              rl.KeyboardKey.K,
  inputs_map.Key.L:              rl.KeyboardKey.L,
  inputs_map.Key.M:              rl.KeyboardKey.M,
  inputs_map.Key.N:              rl.KeyboardKey.N,
  inputs_map.Key.O:              rl.KeyboardKey.O,
  inputs_map.Key.P:              rl.KeyboardKey.P,
  inputs_map.Key.Q:              rl.KeyboardKey.Q,
  inputs_map.Key.R:              rl.KeyboardKey.R,
  inputs_map.Key.S:              rl.KeyboardKey.S,
  inputs_map.Key.T:              rl.KeyboardKey.T,
  inputs_map.Key.U:              rl.KeyboardKey.U,
  inputs_map.Key.V:              rl.KeyboardKey.V,
  inputs_map.Key.W:              rl.KeyboardKey.W,
  inputs_map.Key.X:              rl.KeyboardKey.X,
  inputs_map.Key.Y:              rl.KeyboardKey.Y,
  inputs_map.Key.Z:              rl.KeyboardKey.Z,
  inputs_map.Key.LEFT_BRACKET:   rl.KeyboardKey.LeftBracket,
  inputs_map.Key.BACKSLASH:      rl.KeyboardKey.Backslash,
  inputs_map.Key.RIGHT_BRACKET:  rl.KeyboardKey.RightBracket,
  inputs_map.Key.GRAVE:          rl.KeyboardKey.Grave,
  inputs_map.Key.SPACE:          rl.KeyboardKey.Space,
  inputs_map.Key.ESCAPE:         rl.KeyboardKey.Escape,
  inputs_map.Key.ENTER:          rl.KeyboardKey.Enter,
  inputs_map.Key.TAB:            rl.KeyboardKey.Tab,
  inputs_map.Key.BACKSPACE:      rl.KeyboardKey.Backspace,
  inputs_map.Key.INSERT:         rl.KeyboardKey.Insert,
  inputs_map.Key.DELETE:         rl.KeyboardKey.Delete,
  inputs_map.Key.RIGHT:          rl.KeyboardKey.Right,
  inputs_map.Key.LEFT:           rl.KeyboardKey.Left,
  inputs_map.Key.DOWN:           rl.KeyboardKey.Down,
  inputs_map.Key.UP:             rl.KeyboardKey.Up,
  inputs_map.Key.PAGE_UP:        rl.KeyboardKey.PageUp,
  inputs_map.Key.PAGE_DOWN:      rl.KeyboardKey.PageDown,
  inputs_map.Key.HOME:           rl.KeyboardKey.Home,
  inputs_map.Key.END:            rl.KeyboardKey.End,
  inputs_map.Key.CAPS_LOCK:      rl.KeyboardKey.CapsLock,
  inputs_map.Key.SCROLL_LOCK:    rl.KeyboardKey.ScrollLock,
  inputs_map.Key.NUM_LOCK:       rl.KeyboardKey.NumLock,
  inputs_map.Key.PRINT_SCREEN:   rl.KeyboardKey.PrintScreen,
  inputs_map.Key.PAUSE:          rl.KeyboardKey.Pause,
  inputs_map.Key.F1:             rl.KeyboardKey.F1,
  inputs_map.Key.F2:             rl.KeyboardKey.F2,
  inputs_map.Key.F3:             rl.KeyboardKey.F3,
  inputs_map.Key.F4:             rl.KeyboardKey.F4,
  inputs_map.Key.F5:             rl.KeyboardKey.F5,
  inputs_map.Key.F6:             rl.KeyboardKey.F6,
  inputs_map.Key.F7:             rl.KeyboardKey.F7,
  inputs_map.Key.F8:             rl.KeyboardKey.F8,
  inputs_map.Key.F9:             rl.KeyboardKey.F9,
  inputs_map.Key.F10:            rl.KeyboardKey.F10,
  inputs_map.Key.F11:            rl.KeyboardKey.F11,
  inputs_map.Key.F12:            rl.KeyboardKey.F12,
  inputs_map.Key.LEFT_SHIFT:     rl.KeyboardKey.LeftShift,
  inputs_map.Key.LEFT_CONTROL:   rl.KeyboardKey.LeftControl,
  inputs_map.Key.LEFT_ALT:       rl.KeyboardKey.LeftAlt,
  inputs_map.Key.LEFT_SUPER:     rl.KeyboardKey.LeftSuper,
  inputs_map.Key.RIGHT_SHIFT:    rl.KeyboardKey.RightShift,
  inputs_map.Key.RIGHT_CONTROL:  rl.KeyboardKey.RightControl,
  inputs_map.Key.RIGHT_ALT:      rl.KeyboardKey.RightAlt,
  inputs_map.Key.RIGHT_SUPER:    rl.KeyboardKey.RightSuper,
  inputs_map.Key.KB_MENU:        rl.KeyboardKey.KbMenu,
  inputs_map.Key.KP_0:           rl.KeyboardKey.Kp0,
  inputs_map.Key.KP_1:           rl.KeyboardKey.Kp1,
  inputs_map.Key.KP_2:           rl.KeyboardKey.Kp2,
  inputs_map.Key.KP_3:           rl.KeyboardKey.Kp3,
  inputs_map.Key.KP_4:           rl.KeyboardKey.Kp4,
  inputs_map.Key.KP_5:           rl.KeyboardKey.Kp5,
  inputs_map.Key.KP_6:           rl.KeyboardKey.Kp6,
  inputs_map.Key.KP_7:           rl.KeyboardKey.Kp7,
  inputs_map.Key.KP_8:           rl.KeyboardKey.Kp8,
  inputs_map.Key.KP_9:           rl.KeyboardKey.Kp9,
  inputs_map.Key.KP_DECIMAL:     rl.KeyboardKey.KpDecimal,
  inputs_map.Key.KP_DIVIDE:      rl.KeyboardKey.KpDivide,
  inputs_map.Key.KP_MULTIPLY:    rl.KeyboardKey.KpMultiply,
  inputs_map.Key.KP_SUBTRACT:    rl.KeyboardKey.KpSubtract,
  inputs_map.Key.KP_ADD:         rl.KeyboardKey.KpAdd,
  inputs_map.Key.KP_ENTER:       rl.KeyboardKey.KpEnter,
  inputs_map.Key.KP_EQUAL:       rl.KeyboardKey.KpEqual,
  # Android key buttons
  inputs_map.Key.BACK:           rl.KeyboardKey.Back,       # Key: Android back button
  inputs_map.Key.MENU:           rl.KeyboardKey.Menu,       # Key: Android menu button
  inputs_map.Key.VOLUME_UP:      rl.KeyboardKey.VolumeUp,       # Key: Android volume up button
  inputs_map.Key.VOLUME_DOWN:    rl.KeyboardKey.VolumeDown        # Key: Android volume down button
}.toTable()

#Mouse Buttons
var kirpiMouseButtonMap* = {
  inputs_map.MouseButton.LEFT:     rl.MouseButton.Left,
  inputs_map.MouseButton.RIGHT:    rl.MouseButton.Right,
  inputs_map.MouseButton.MIDDLE:   rl.MouseButton.Middle,    
  inputs_map.MouseButton.SIDE:     rl.MouseButton.Side,    
  inputs_map.MouseButton.EXTRA:    rl.MouseButton.Extra,     
  inputs_map.MouseButton.FORWARD:  rl.MouseButton.Forward,     
  inputs_map.MouseButton.BACK:     rl.MouseButton.Back
}.toTable()

#Gamepad
var kirpiGamepadButtonMap* = {
  inputs_map.GamepadButton.UNKNOWN:         rl.GamepadButton.Unknown,
  inputs_map.GamepadButton.LEFT_FACE_UP:    rl.GamepadButton.LeftFaceUp,      
  inputs_map.GamepadButton.LEFT_FACE_RIGHT: rl.GamepadButton.LeftFaceRight,        
  inputs_map.GamepadButton.LEFT_FACE_DOWN:  rl.GamepadButton.LeftFaceDown,        
  inputs_map.GamepadButton.LEFT_FACE_LEFT:  rl.GamepadButton.LeftFaceLeft,        
  inputs_map.GamepadButton.RIGHT_FACE_UP:   rl.GamepadButton.RightFaceUp,      
  inputs_map.GamepadButton.RIGHT_FACE_RIGHT:rl.GamepadButton.RightFaceRight,          
  inputs_map.GamepadButton.RIGHT_FACE_DOWN: rl.GamepadButton.RightFaceDown,        
  inputs_map.GamepadButton.RIGHT_FACE_LEFT: rl.GamepadButton.RightFaceLeft,        
  inputs_map.GamepadButton.LEFT_TRIGGER_1:  rl.GamepadButton.LeftTrigger1,        
  inputs_map.GamepadButton.LEFT_TRIGGER_2:  rl.GamepadButton.LeftTrigger2,        
  inputs_map.GamepadButton.RIGHT_TRIGGER_1: rl.GamepadButton.RightTrigger1,        
  inputs_map.GamepadButton.RIGHT_TRIGGER_2: rl.GamepadButton.RightTrigger2,        
  inputs_map.GamepadButton.MIDDLE_LEFT:     rl.GamepadButton.MiddleLeft,    
  inputs_map.GamepadButton.MIDDLE:          rl.GamepadButton.Middle,
  inputs_map.GamepadButton.MIDDLE_RIGHT:    rl.GamepadButton.MiddleRight,      
  inputs_map.GamepadButton.LEFT_THUMB:      rl.GamepadButton.LeftThumb,    
  inputs_map.GamepadButton.RIGHT_THUMB:     rl.GamepadButton.RightThumb
}.toTable()

#Gamepad Axis
var kirpiGamepadAxisMap* = {
  inputs_map.GamepadAxis.LEFT_X:          rl.GamepadAxis.LeftX,        
  inputs_map.GamepadAxis.LEFT_Y:          rl.GamepadAxis.LeftY,      
  inputs_map.GamepadAxis.RIGHT_X:         rl.GamepadAxis.RightX,     
  inputs_map.GamepadAxis.RIGHT_Y:         rl.GamepadAxis.RightY,     
  inputs_map.GamepadAxis.LEFT_TRIGGER:    rl.GamepadAxis.LeftTrigger,      
  inputs_map.GamepadAxis.RIGHT_TRIGGER:   rl.GamepadAxis.RightTrigger     
}.toTable()

#Generating the backend input table with the kirpi input table 
#key
var backendKeyMap* = initTable[rl.KeyboardKey, inputs_map.Key]()
for k, v in kirpiKeyMap.pairs:
  backendKeyMap[v] = k
#mouse button
var backendMouseButtonMap* = initTable[rl.MouseButton, inputs_map.MouseButton]()
for k, v in kirpiMouseButtonMap.pairs:
  backendMouseButtonMap[v] = k
#gamepad 
var backendGamepadButtonMap* = initTable[rl.GamepadButton, inputs_map.GamepadButton]()
for k, v in kirpiGamepadButtonMap.pairs:
  backendGamepadButtonMap[v] = k

#endregion

#region Methods & Properties

proc init(appBackendSettings:Settings) =
    discard

proc loop*() =
    discard

proc deinit() =
    discard



proc isKeyPressed*(key:inputs_map.Key) :bool =
  result = rl.isKeyPressed( kirpiKeyMap[key] )

proc getPressedKey*():inputs_map.Key =
  let key=rl.getKeyPressed()
  if backendKeyMap.hasKey(key) :
    return backendKeymap[key]
  return inputs_map.Key.NULL

proc isKeyReleased*(key:inputs_map.Key) : bool =
  result = rl.isKeyReleased( kirpiKeyMap[key] )

proc isKeyDown*(key:inputs_map.Key) : bool =
  result = rl.isKeyDown( kirpiKeyMap[key] )

proc isKeyUp*(key:inputs_map.Key) : bool =
  result = rl.isKeyUp( kirpiKeyMap[key] )

proc getPressedChar*():Rune =
    result=rl.getCharPressed().Rune


#Mouse 
proc isMouseButtonPressed*(button:inputs_map.MouseButton):bool =
    return rl.isMouseButtonPressed( kirpiMouseButtonMap[button])

proc isMouseButtonReleased*(button:inputs_map.MouseButton):bool =
    return rl.isMouseButtonReleased(kirpiMouseButtonMap[button])

proc isMouseButtonDown*(button:inputs_map.MouseButton):bool =
    return rl.isMouseButtonDown(kirpiMouseButtonMap[button])

proc isMouseButtonUp*(button:inputs_map.MouseButton):bool =
    return rl.isMouseButtonUp(kirpiMouseButtonMap[button])

proc getMouseX*():float =
    return float( rl.getMouseX() )

proc getMouseY*():float =
    return float( rl.getMouseY() )

#Gamepad

proc isGamepadAvailable*(gamepad:int):bool =
    return rl.isGamepadAvailable(int32(gamepad) )

proc getGamepadName*(gamepad:int):string =
    return rl.getGamepadName(int32(gamepad))

proc isGamepadButtonPressed*(gamepad:int, button:inputs_map.GamepadButton):bool =
    return rl.isGamepadButtonPressed(int32(gamepad), kirpiGamepadButtonMap[button])

proc isGamepadButtonReleased*(gamepad:int, button:inputs_map.GamepadButton):bool =
    return rl.isGamepadButtonReleased(int32(gamepad), kirpiGamepadButtonMap[button])

proc isGamepadButtonDown*(gamepad:int, button:inputs_map.GamepadButton):bool =
    return rl.isGamepadButtonDown(int32(gamepad), kirpiGamepadButtonMap[button])

proc isGamepadButtonUp*(gamepad:int, button:inputs_map.GamepadButton):bool =
    return rl.isGamepadButtonUp(int32(gamepad), kirpiGamepadButtonMap[button])

proc getGamepadAxisCount*(gamepad:int):int =
    return int(rl.getGamepadAxisCount(int32(gamepad)))

proc getGamepadAxisMovement*(gamepad:int, axis:inputs_map.GamepadAxis):float =
    return rl.getGamepadAxisMovement(int32(gamepad), kirpiGamepadAxisMap[axis])

type GamepadError* = object of CatchableError
proc setGamepadMappings*(mappings:string) =
    let res=rl.setGamepadMappings(mappings)
    if res<0 :
        let errorMessage = "Failed to load Gamepad Mappings. Return code: " & $res
        raise newException(GamepadError, errorMessage)
    

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

#endregion