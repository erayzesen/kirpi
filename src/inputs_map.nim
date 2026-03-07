
#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

#Keyboard Keys
type 
    Key* = enum
        NULL            = 0        # Key: NULL, used for no key pressed
        APOSTROPHE      = 39       # Key: '
        COMMA           = 44       # Key: ,
        MINUS           = 45       # Key: -
        PERIOD          = 46       # Key: .
        SLASH           = 47       # Key: /
        ZERO            = 48       # Key: 0
        ONE             = 49       # Key: 1
        TWO             = 50       # Key: 2
        THREE           = 51       # Key: 3
        FOUR            = 52       # Key: 4
        FIVE            = 53       # Key: 5
        SIX             = 54       # Key: 6
        SEVEN           = 55       # Key: 7
        EIGHT           = 56       # Key: 8
        NINE            = 57       # Key: 9
        SEMICOLON       = 59       # Key: ;
        EQUAL           = 61       # Key::int =
        A               = 65       # Key: A | a
        B               = 66       # Key: B | b
        C               = 67       # Key: C | c
        D               = 68       # Key: D | d
        E               = 69       # Key: E | e
        F               = 70       # Key: F | f
        G               = 71       # Key: G | g
        H               = 72       # Key: H | h
        I               = 73       # Key: I | i
        J               = 74       # Key: J | j
        K               = 75       # Key: K | k
        L               = 76       # Key: L | l
        M               = 77       # Key: M | m
        N               = 78       # Key: N | n
        O               = 79       # Key: O | o
        P               = 80       # Key: P | p
        Q               = 81       # Key: Q | q
        R               = 82       # Key: R | r
        S               = 83       # Key: S | s
        T               = 84       # Key: T | t
        U               = 85       # Key: U | u
        V               = 86       # Key: V | v
        W               = 87       # Key: W | w
        X               = 88       # Key: X | x
        Y               = 89       # Key: Y | y
        Z               = 90       # Key: Z | z
        LEFT_BRACKET    = 91       # Key: [
        BACKSLASH       = 92       # Key: '\'
        RIGHT_BRACKET   = 93       # Key: ]
        GRAVE           = 96       # Key: `
        # Function keys
        SPACE           = 32       # Key: Space
        ESCAPE          = 256      # Key: Esc
        ENTER           = 257      # Key: Enter
        TAB             = 258      # Key: Tab
        BACKSPACE       = 259      # Key: Backspace
        INSERT          = 260      # Key: Ins
        DELETE          = 261      # Key: Del
        RIGHT           = 262      # Key: Cursor right
        LEFT            = 263      # Key: Cursor left
        DOWN            = 264      # Key: Cursor down
        UP              = 265      # Key: Cursor up
        PAGE_UP         = 266      # Key: Page up
        PAGE_DOWN       = 267      # Key: Page down
        HOME            = 268      # Key: Home
        END             = 269      # Key: End
        CAPS_LOCK       = 280      # Key: Caps lock
        SCROLL_LOCK     = 281      # Key: Scroll down
        NUM_LOCK        = 282      # Key: Num lock
        PRINT_SCREEN    = 283      # Key: Print screen
        PAUSE           = 284      # Key: Pause
        F1              = 290      # Key: F1
        F2              = 291      # Key: F2
        F3              = 292      # Key: F3
        F4              = 293      # Key: F4
        F5              = 294      # Key: F5
        F6              = 295      # Key: F6
        F7              = 296      # Key: F7
        F8              = 297      # Key: F8
        F9              = 298      # Key: F9
        F10             = 299      # Key: F10
        F11             = 300      # Key: F11
        F12             = 301      # Key: F12
        LEFT_SHIFT      = 340      # Key: Shift left
        LEFT_CONTROL    = 341      # Key: Control left
        LEFT_ALT        = 342      # Key: Alt left
        LEFT_SUPER      = 343      # Key: Super left
        RIGHT_SHIFT     = 344      # Key: Shift right
        RIGHT_CONTROL   = 345      # Key: Control right
        RIGHT_ALT       = 346      # Key: Alt right
        RIGHT_SUPER     = 347      # Key: Super right
        KB_MENU         = 348      # Key: KB menu
        # Keypad keys
        KP_0            = 320      # Key: Keypad 0
        KP_1            = 321      # Key: Keypad 1
        KP_2            = 322      # Key: Keypad 2
        KP_3            = 323      # Key: Keypad 3
        KP_4            = 324      # Key: Keypad 4
        KP_5            = 325      # Key: Keypad 5
        KP_6            = 326      # Key: Keypad 6
        KP_7            = 327      # Key: Keypad 7
        KP_8            = 328      # Key: Keypad 8
        KP_9            = 329      # Key: Keypad 9
        KP_DECIMAL      = 330      # Key: Keypad .
        KP_DIVIDE       = 331      # Key: Keypad /
        KP_MULTIPLY     = 332      # Key: Keypad *
        KP_SUBTRACT     = 333      # Key: Keypad -
        KP_ADD          = 334      # Key: Keypad +
        KP_ENTER        = 335      # Key: Keypad Enter
        KP_EQUAL        = 336      # Key: Keypad =
        # Android key buttons
        BACK            = 4        # Key: Android back button
        MENU            = 5        # Key: Android menu button
        VOLUME_UP       = 24       # Key: Android volume up button
        VOLUME_DOWN     = 25        # Key: Android volume down button

    #Mouse Buttons
    MouseButton* = enum
        LEFT    = 0       # Mouse button left
        RIGHT   = 1       # Mouse button right
        MIDDLE  = 2       # Mouse button middle (pressed wheel)
        SIDE    = 3       # Mouse button side (advanced mouse device)
        EXTRA   = 4       # Mouse button extra (advanced mouse device)
        FORWARD = 5       # Mouse button forward (advanced mouse device)
        BACK    = 6       # Mouse button back (advanced mouse device)

    #Gamepad Buttons
    GamepadButton* = enum
        UNKNOWN = 0         # Unknown button, for error checking
        LEFT_FACE_UP        # Gamepad left DPAD up button
        LEFT_FACE_RIGHT     # Gamepad left DPAD right button
        LEFT_FACE_DOWN      # Gamepad left DPAD down button
        LEFT_FACE_LEFT      # Gamepad left DPAD left button
        RIGHT_FACE_UP       # Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
        RIGHT_FACE_RIGHT    # Gamepad right button right (i.e. PS3: Circle, Xbox: B)
        RIGHT_FACE_DOWN     # Gamepad right button down (i.e. PS3: Cross, Xbox: A)
        RIGHT_FACE_LEFT     # Gamepad right button left (i.e. PS3: Square, Xbox: X)
        LEFT_TRIGGER_1      # Gamepad top/back trigger left (first), it could be a trailing button
        LEFT_TRIGGER_2      # Gamepad top/back trigger left (second), it could be a trailing button
        RIGHT_TRIGGER_1     # Gamepad top/back trigger right (first), it could be a trailing button
        RIGHT_TRIGGER_2     # Gamepad top/back trigger right (second), it could be a trailing button
        MIDDLE_LEFT         # Gamepad center buttons, left one (i.e. PS3: Select)
        MIDDLE              # Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
        MIDDLE_RIGHT        # Gamepad center buttons, right one (i.e. PS3: Start)
        LEFT_THUMB          # Gamepad joystick pressed button left
        RIGHT_THUMB         # Gamepad joystick pressed button right

    #Gamepad Axis
    GamepadAxis* = enum
        LEFT_X        = 0,     # Gamepad left stick X axis
        LEFT_Y        = 1,     # Gamepad left stick Y axis
        RIGHT_X       = 2,     # Gamepad right stick X axis
        RIGHT_Y       = 3,     # Gamepad right stick Y axis
        LEFT_TRIGGER  = 4,     # Gamepad back trigger left, pressure level: [1..-1]
        RIGHT_TRIGGER = 5      # Gamepad back trigger right, pressure level: [1..-1]