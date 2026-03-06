#   MIT License - Copyright (c) 2025 Eray Zesen
#   Github: https://github.com/erayzesen/kirpi
#   License information: https://github.com/erayzesen/kirpi/blob/master/LICENSE

import hashes


#backend
import backends/naylib/sound_end

type 
    SoundType* = enum
        Static,
        Stream

    SoundBase* = object 
        id:Hash
        sourceType*: SoundType

    Sound* = ref SoundBase 


proc `=destroy`(x:SoundBase) =
    var isStream=x.sourceType==SoundType.Stream
    sound_end.unloadSound(x.id,isStream)

# Sound
proc newSound*(fileName:string, soundType:SoundType):Sound =
    result=Sound()
    if soundType==SoundType.Static:
        result.id=sound_end.loadSound(fileName,false)
        result.sourceType=SoundType.Static
    elif soundType==SoundType.Stream:
        result.id=sound_end.loadSound(fileName,true)
        result.sourceType=SoundType.Stream


        

proc play*(sound:var Sound) =
    if sound.sourceType==SoundType.Static:
        sound_end.play(sound.id,false)
    elif sound.sourceType==SoundType.Stream:
        sound_end.play(sound.id,true)

proc stop*(sound:var Sound) =
    if sound.sourceType==SoundType.Static:
        sound_end.stop(sound.id,false)
    elif sound.sourceType==SoundType.Stream:
        sound_end.stop(sound.id,false)

proc pause*(sound:var Sound) =
    if sound.sourceType==SoundType.Static:
        sound_end.pause(sound.id,false)
    elif sound.sourceType==SoundType.Stream:
        sound_end.pause(sound.id,true)

proc resume*(sound:var Sound) =
    if sound.sourceType==SoundType.Static:
        sound_end.resume(sound.id,false)
    elif sound.sourceType==SoundType.Stream:
        sound_end.resume(sound.id,true)

proc isPlaying*(sound:var Sound):bool =
    if sound.sourceType==SoundType.Static:
        result=sound_end.isPlaying(sound.id,false)
    elif sound.sourceType==SoundType.Stream:
        result=sound_end.isPlaying(sound.id,true)
    

proc setVolume*(sound:var Sound, volume:float) =
    if sound.sourceType==SoundType.Static:
        sound_end.setVolume(sound.id,false, volume)
    elif sound.sourceType==SoundType.Stream:
        sound_end.setVolume(sound.id,true, volume)

proc setPitch*(sound:var Sound, pitch:float) =
    if sound.sourceType==SoundType.Static:
        sound_end.setPitch(sound.id,false, pitch)
    elif sound.sourceType==SoundType.Stream:
        sound_end.setPitch(sound.id,true, pitch)

proc setPan*(sound:var Sound, pan:float) =
    if sound.sourceType==SoundType.Static:
        sound_end.setPan(sound.id,false, pan)
    elif sound.sourceType==SoundType.Stream:
        sound_end.setPan(sound.id,true, pan)



