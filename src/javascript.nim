
type
    JSCallback* = proc(arg: cstring) {.cdecl.}      # For JSON argument callbacks(string)
    JSCallbackVoid* = proc() {.cdecl.}             # Only for no-argument callbacks

when defined(emscripten):
    {.emit: """
    #include <emscripten.h>
    #include <stdlib.h>

    typedef void (*JSCallback)(char*);
    typedef void (*JSCallbackVoid)();

    // 1. Json Callback Version
    EM_JS(int, kirpi_create_callback, (JSCallback cb, const char* eventName), {
        var eventStr = UTF8ToString(eventName);
        document.addEventListener(eventStr, function() {
            var args = Array.from(arguments).map(arg => {
                if (arg && typeof arg === 'object') {
                    var obj = {};
                    for (var key in arg) {
                        var val = arg[key];
                        if (typeof val === 'string' || typeof val === 'number' || typeof val === 'boolean') {
                            obj[key] = val;
                        }
                    }
                    return obj;
                }
                return arg;
            });
            var jsonStr = JSON.stringify(args);
            var length = lengthBytesUTF8(jsonStr) + 1;
            var ptr = _malloc(length);
            stringToUTF8(jsonStr, ptr, length);
            
            if (typeof wasmTable !== 'undefined') wasmTable.get(cb)(ptr);
            else Module["dynCall_vi"](cb, ptr);
            _free(ptr);
        });
        return 0;
    });

    // 2. Void Version for no-arg callbacks
    EM_JS(int, kirpi_create_callback_void, (JSCallbackVoid cb, const char* eventName), {
        var eventStr = UTF8ToString(eventName);
        document.addEventListener(eventStr, function() {
            if (typeof wasmTable !== 'undefined') wasmTable.get(cb)();
            else Module["dynCall_v"](cb);
        });
        return 0;
    });
    """.}

    proc kirpi_create_callback(cb: JSCallback, eventName: cstring): cint {.importc, nodecl.}
    proc kirpi_create_callback_void(cb: JSCallbackVoid, eventName: cstring): cint {.importc, nodecl.}

    # Eval Functions
    proc emscripten_run_script_string(script: cstring): cstring {.importc, header: "<emscripten/emscripten.h>".}
    #---Maybe useful later
    #proc emscripten_run_script_int(script: cstring): cint {.importc, header: "<emscripten/emscripten.h>".}
    #proc emscripten_run_script_double(script: cstring): cdouble {.importc, header: "<emscripten/emscripten.h>".}
    #proc emscripten_run_script_bool(script: cstring): cint {.importc, header: "<emscripten/emscripten.h>".}
    #proc emscripten_run_script(script: cstring): void {.importc, header: "<emscripten/emscripten.h>".}

proc cstring2String(cstr: cstring): string =
  if cstr == nil: ""
  else: $cstr

# Json Returning Callback
proc createCallback*(cb: JSCallback; jsEvent: cstring) =
    when defined(emscripten):
        discard kirpi_create_callback(cb, jsEvent)
    else: discard

# Void Callback
proc createCallback*(cb: JSCallbackVoid; jsEvent: cstring) =
    when defined(emscripten):
        discard kirpi_create_callback_void(cb, jsEvent)
    else: discard

# generic eval
proc eval*(code: string): string =
  when defined(emscripten):
    result = emscripten_run_script_string(code.cstring).cstring2String()
  else:
    result = ""


