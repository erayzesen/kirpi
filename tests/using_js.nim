import ../src/kirpi

# tests
proc onDetailedClick(jsonArgs: cstring) {.cdecl.} =
    echo "Detailed Click Data: ", $jsonArgs


proc onSimpleClick() {.cdecl.} =
    echo "There's no data, it's just a callback."


proc load() =
    javascript.createCallback(onDetailedClick, "contextmenu") # Right Click, with Callback Data
    javascript.createCallback(onSimpleClick, "click")         # Left Click, No Callback Data
    

proc update( dt:float) =
    if isKeyPressed(KeyboardKey.Space):
        discard javascript.eval("alert('Hello from Nim via JS eval!');")
    

proc draw() =
    clear(White)
    setColor(Black)
    draw(newText("-Right Click anywhere to see detailed event data in console.",getDefaultFont()),50,100,32)
    draw(newText("-Left Click anywhere to see a simple alert callback.",getDefaultFont()),50,150,32)
    draw(newText("-Press SPACE to see JS eval in action.",getDefaultFont()),50,200,32)
    

    discard

run("Using JS", load, update, draw)