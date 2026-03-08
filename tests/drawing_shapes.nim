import ../src/kirpi
import math


proc load() =
    discard

proc update( dt:float) =
    discard

proc draw() =
    clear(Black)
    origin()
    
    setColor(Magenta)
    #Circles
    circle(DrawModes.Fill,128,128,64)
    circle(DrawModes.Line,128,128,72)
    draw(newText("Circle",getDefaultFont() ),102,210,24 )
    #Ellipses
    setColor(Yellow)
    ellipse(DrawModes.Fill,128,300,72,48)
    ellipse(DrawModes.Line,128,300,80,56)
    draw(newText("Ellipse",getDefaultFont() ),98,362,24 )
    #Rectangles     
    setColor(Green)
    rectangle(DrawModes.Fill,256,128,128,96)
    rectangle(DrawModes.Line,248,120,144,112)
    draw(newText("Rectangle",getDefaultFont() ),277,235,24 )

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
    draw(newText("Polygon Sample - Home",getDefaultFont() ),290,455,24 )

    #Polygon -Star Shape
    setColor(Blue)
    let cx = 565.0 # center x
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
    draw(newText("Polygon Sample - Star",getDefaultFont() ),460,290,24 )

    #Lines
    setColor(Violet)
    setLine(12,JoinTypes.Round,CapTypes.Round)

    line(
        100.0,500.0,
        200.0,500.0,
        200.0,450.0,
        250.0,450.0
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
    draw(newText("Line",getDefaultFont() ),128,470,24 )
    
    #Arc
    setColor(Orange)
    arc(DrawModes.Fill,ArcType.Pie,630,450,64,0,PI+PI/3,32)
    draw(newText("Arc",getDefaultFont() ),610,520,24 )
    


#Run the game
run("Drawing Shapes",load,update,draw)