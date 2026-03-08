#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

type 
    Settings* = object
        #Kirpi needs these properties
        #window
        title*:string
        width*:int=800
        height*:int=600
        resizeable*:bool=false
        borderless*:bool=false
        alwaysOnTop*:bool=false
        iconPath*:string=""        
        minWidth*:int=1
        minHeight*:int=1
        fullscreen*:bool=false

        #others
        antialias*:bool=true
        targetFPS*:int=60

        #orders
        printFrameTime*:bool=false
        printFPS*:bool=false

        