import ../src/kirpi
import random,math

# This example shows how to render thousands of sprites efficiently
# by batching them into **one draw call** using SpriteBatch.

# Minimal fish data for motion
type 
  Fish = object 
    x:float
    y:float
    beginY:float
    flip:bool # swim direction
    spriteID:int


var fishes:seq[Fish] # All fish instances stored here
var fishTexture:Texture
var spriteBatch:SpriteBatch

var fishCount=1000

# Reset fish list and batch when count changes
proc reCreateFishes(count:int) =
  fishes.setLen(0)
  # Clear previous frame's batched sprites
  spriteBatch.clear()
  # Add fish instances
  for i in 0..<count :
    var nFish=Fish(x:rand(window.getWidth().float), y:rand(window.getWidth().float))
    nFish.beginY=nFish.y
    nFish.flip=if rand(5.int)==3 : true else : false
    nFish.spriteID=spriteBatch.add(  # It returns an index; we capture it here just to demonstrate it.
      nFish.x, # x position
      nFish.y, # y position
      0.0,  # rotation
      1.0, # scale x
      1.0, # scale y
      fishTexture.width.float*0.5, # origin x 
      fishTexture.height.float*0.5 # origin y
    )
    fishes.add(nFish)
    


proc config(settings : var AppSettings) =
  settings.fps=60.int


proc load() =
  # Load fish texture 
  fishTexture=newTexture("tests/resources/fish.png")
    # Create a sprite batch with texture 
  spriteBatch=newSpriteBatch(fishTexture,1000)
  reCreateFishes(fishCount)
  

proc update( dt:float) =
  # Adjust fish count
  if isKeyPressed(Key.Space) :
    fishCount+=1000
    reCreateFishes(fishCount) # Rebuild batch with new count
  if isKeyPressed(Key.Backspace) :
    fishCount=max(0,fishCount-1000) 
    reCreateFishes(fishCount) # Rebuild batch with new count


  let scale=0.2
  # Update fish motion 
  # Horizontal movement + sine wave
  for i in 0..<fishes.len: 
    if fishes[i].x<0 : fishes[i].flip=true
    elif fishes[i].x>window.getWidth().float : fishes[i].flip=false

    if fishes[i].flip==false : fishes[i].x -= 0.5
    else : fishes[i].x += 0.5

    fishes[i].y = fishes[i].beginY + sin(getTime() + fishes[i].beginY)*16
    let flipFactor:float = if fishes[i].flip : -1 else : 1
    spriteBatch.setSpriteTransform(fishes[i].spriteID,fishes[i].x,fishes[i].y,0.0,flipFactor*scale,scale,fishTexture.width*0.5,fishTexture.height*0.5)
  
  # Refill batch with transforms
  
  
    

# Draw batch + UI
proc draw() =
  clear(SkyBlue)

  setColor(White)
  # Draw all fish in **one call**
  draw(spriteBatch,0,0) # one draw call

  # Info panel
  var panelColor=Black
  panelColor.a=150
  setColor(panelColor)
  rectangle(DrawModes.Fill,10.float,10.float,450.float,150.float)

  setColor(White)
  var iy:float=20
  draw(newText("Drawing fish sprites with 1 draw call.", getDefaultFont()),20,iy,24)
  iy+=24
  draw(newText("Fish Count: " & $fishCount, getDefaultFont()),20,iy,24)
  iy+=24
  draw(newText("FPS: " & $getFramesPerSecond(), getDefaultFont()),20,iy,24)

  setColor(Yellow)
  iy+=24
  draw(newText("Press Space to add 1000 fish.", getDefaultFont()),20,iy,24)
  iy+=24
  draw(newText("Press Backspace to remove 1000 fish.", getDefaultFont()),20,iy,24)

# Run the app
run("Using SpriteBatch",load,update,draw,config)
