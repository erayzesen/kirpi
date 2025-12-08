import ../src/kirpi
import math

proc load() =
    discard

proc update( dt:float) =
    discard

proc draw() =
    clear(Black)
    

    setColor(Magenta)
    #Circles
    circle(DrawModes.Fill,128,128,64)
    circle(DrawModes.Line,128,128,72)
    draw(newText("Circle",getFont() ),102,210,24 )
    #Ellipses
    setColor(Yellow)
    ellipse(DrawModes.Fill,128,300,72,48)
    ellipse(DrawModes.Line,128,300,80,56)
    draw(newText("Ellipse",getFont() ),98,362,24 )
    #Rect 
    setColor(Green)
    rectangle(DrawModes.Fill,256,128,128,96)
    rectangle(DrawModes.Line,248,120,144,112)
    draw(newText("Rectangle",getFont() ),277,235,24 )

    #Polygon
    setColor(Red)
    var housePoints: seq[float] = @[
        300, 400,  
        400, 300,  
        500, 400, 
        450, 400, 
        450, 450, 
        410, 450, 
        410, 420, 
        390, 420, 
        390, 450, 
        350, 450, 
        350, 400, 
        
    ]
    polygon(DrawModes.Fill, housePoints)
    draw(newText("Polygon Sample - Home",getFont() ),290,455,24 )

    #Polygon -Star Shape
    setColor(Blue)
    let cx = 550.0 # center x
    let cy = 200.0 # center y
    let radiusOuter = 100.0
    let radiusInner = 50.0
    var starPoints:seq[float] 
    for i in 0..<5:
        let angleOuter = (i * 72 - 90).float * PI / 180.0
        let angleInner = ((i * 72 + 36) - 90).float * PI / 180.0
        starPoints.add(cx + cos(angleOuter) * radiusOuter)
        starPoints.add(cy + sin(angleOuter) * radiusOuter)
        starPoints.add(cx + cos(angleInner) * radiusInner)
        starPoints.add(cy + sin(angleInner) * radiusInner)
    polygon(DrawModes.Fill, starPoints)
    draw(newText("Polygon Sample - Star",getFont() ),460,290,24 )

    #Lines
    setColor(250,250,250,128)
    setLine(15,JoinTypes.Miter)
    line(
        100.0,500.0,
        200.0,500.0,
        130.0,480.0,
        getMouseX(),getMouseY()
    )
    line(
        250.0,450.0,
        225.0,430.0,
    )
    line(
        250.0,450.0,
        225.0,470.0,
    )
    setLine(1)
    #draw(newText("Line",getFont() ),128,470,24 )

    #Arc
    setColor(Orange)
    arc(DrawModes.Fill,ArcType.Pie,630,450,64,0,PI+PI/3,32)
    draw(newText("Arc",getFont() ),610,520,24 )
    





run("Drawing Shapes",load,update,draw)