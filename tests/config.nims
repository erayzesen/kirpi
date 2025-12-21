import os,strutils

let projectPathName=projectName()

proc createDirAll(file:string) =
    when defined(windows):
        exec "mkdir releases\\windows"
    elif defined(linux) or defined(macosx):
        exec "mkdir -p releases/linux"

when defined(emscripten):
    let htmlPath="releases/html5/" & projectPathName
    createDirAll(htmlPath)
    --define:GraphicsApiOpenGlEs2
    --define:NaylibWebResources
    switch("define", "NaylibWebResourcesPath=tests/resources")
    # switch("define", "NaylibWebPthreadPoolSize=2")
    # --define:NaylibWebAsyncify
    --os:linux
    --cpu:wasm32
    --cc:clang
    when buildOS == "windows":
        --clang.exe:emcc.bat
        --clang.linkerexe:emcc.bat
        --clang.cpp.exe:emcc.bat
        --clang.cpp.linkerexe:emcc.bat
    else:
        --clang.exe:emcc
        --clang.linkerexe:emcc
        --clang.cpp.exe:emcc
        --clang.cpp.linkerexe:emcc

    # Set the stack size to 5MB to prevent 'memory access out of bounds' errors.
    # This often happens in release builds due to aggressive optimizations.
    # If you still encounter memory access errors, feel free to increase this value.
    --passL:"-sSTACK_SIZE=5MB"

    # Allow the heap to grow dynamically if the game needs more memory for assets.
    --passL:"-sALLOW_MEMORY_GROWTH=1"

    # Ensure the initial memory is large enough for a typical game (e.g., 32MB or 64MB).
    --passL:"-sINITIAL_MEMORY=33554432" # 32MB
    
    # --mm:orc
    --threads:off
    --panics:on
    --define:noSignalHandler
    --passL:"-O3"
    # Use raylib/src/shell.html or raylib/src/minshell.html
    --passL:"--shell-file minshell.html"
    switch("out", htmlPath & "/index.html")
else :

    when defined(windows):
        createDirAll("releases/windows")
        switch("out", "releases/windows/" & projectPathName)
    elif defined(linux):
        createDirAll("releases/linux")
        switch("out", "releases/linux/" & projectPathName)
    elif defined(macosx):
        createDirAll("releases/macos")
        switch("out", "releases/macos/" & projectPathName)
        
 