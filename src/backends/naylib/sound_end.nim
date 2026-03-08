#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE


import tables,hashes,os
import raylib as rl
import settings_end


#region Backend Needs
### Resource Managment ###
type 
    SoundEntry = object
        data:rl.Sound
        refCount:int
    SoundStreamEntry = object
        data:rl.Music
        refCount:int

var sounds*: Table[Hash, SoundEntry] = initTable[Hash, SoundEntry]()
var soundStreams*: Table[Hash, SoundStreamEntry] = initTable[Hash, SoundStreamEntry]()

#Initialization
proc init*(appBackendSettings:Settings)
proc loop*()
proc deInit*()

#Load&Unload Sources
proc loadSound*(fileName:string, isStream=false):Hash
proc unloadSound*(soundID:Hash,isStream:bool)

#Controlling 
proc play*(soundID:Hash, isStream:bool) 
proc stop*(soundID:Hash, isStream:bool) 
proc pause*(soundID:Hash, isStream:bool) 
proc resume*(soundID:Hash, isStream:bool) 
proc isPlaying*(soundID:Hash, isStream:bool):bool 
proc setVolume*(soundID:Hash, isStream:bool, value:float)
proc setPan*(soundID:Hash, isStream:bool,value:float) 
proc setPitch*(soundID:Hash, isStream:bool,value:float) 

#endregion



#region Initialization
proc init*(appBackendSettings:Settings) =
    initAudioDevice()
    discard

proc loop*() =
    for id in soundStreams.keys:
        rl.updateMusicStream(soundStreams[id].data)
    

proc deInit*() =
    echo "Closing Audio Device... "
    closeAudioDevice()
    discard

#endregion


#region Load Resources

proc loadSound*(fileName:string, isStream=false):Hash =
    var normalizedPath=filename.normalizedPath()
    var hashID:Hash=normalizedPath.hash()
    result=hashID
    if isStream :
        if soundStreams.hasKey(hashID)==false :
            soundStreams[hashID]=SoundStreamEntry(data:rl.loadMusicStream(filename),refCount:1)
        else :
            soundStreams[hashID].refCount+=1
    else :
        if sounds.hasKey(hashID)==false :
            sounds[hashID]=SoundEntry(data:rl.loadSound(filename),refCount:1)
        else :
            sounds[hashID].refCount+=1


proc unloadSound*(soundID:Hash,isStream:bool) =
    if isStream :
        soundStreams[soundID].refCount-=1
        if soundStreams[soundID].refCount<=0 :
            soundStreams.del(soundID)
    else :
        sounds[soundID].refCount-=1
        if sounds[soundID].refCount<=0 :
            sounds.del(soundID)


proc play*(soundID:Hash, isStream:bool) =
    if isStream:
        rl.playMusicStream(soundStreams[soundID].data )
    else:
        rl.playSound(sounds[soundID].data)

proc stop*(soundID:Hash, isStream:bool) =
    if isStream:
        rl.stopMusicStream(soundStreams[soundID].data )
    else:
        rl.stopSound(sounds[soundID].data)

proc pause*(soundID:Hash, isStream:bool) =
    if isStream:
        rl.pauseMusicStream(soundStreams[soundID].data )
    else:
        rl.pauseSound(sounds[soundID].data)

proc resume*(soundID:Hash, isStream:bool) =
    if isStream:
        rl.resumeMusicStream(soundStreams[soundID].data )
    else:
        rl.resumeSound(sounds[soundID].data)


proc isPlaying*(soundID:Hash, isStream:bool):bool =
    if isStream:
        result=rl.isMusicStreamPlaying(soundStreams[soundID].data)
    else :
        result=rl.isSoundPlaying(sounds[soundID].data)


proc setVolume*(soundID:Hash, isStream:bool, value:float) =
    if isStream:
        rl.setMusicVolume(soundStreams[soundID].data,value)
    else:
        rl.setSoundVolume(sounds[soundID].data,value)

proc setPan*(soundID:Hash, isStream:bool,value:float) =
    if isStream:
        rl.setMusicPan(soundStreams[soundID].data, value )
    else:
        rl.setSoundPan(sounds[soundID].data,value)

proc setPitch*(soundID:Hash, isStream:bool,value:float) =
    if isStream:
        rl.setMusicPitch(soundStreams[soundID].data, value )
    else:
        rl.setSoundPitch(sounds[soundID].data,value)

        


    