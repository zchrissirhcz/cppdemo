# image_viewer

A tool for visual debugging images.

## GCC/Clang Usage

Compile main.cpp into `image_viewer` executable.

Create debugview.py script.

Edit launch.json to load debugview.py:
```json
"initCommands": [
    //"command script import ${env:HOME}/.lldb/debugview.py"
    "command script import ${workspaceFolder}/image_viewer/debugview.py"
]
```

For GDB:
```bash
source $HOME/work/cppdemo/image_viewer/gdb/debugview.py
```

Start image_viewer in another terminal.
```
./build/image_viewer/image_viewer
```

Set a breakpoint and hit it, then in gdb/lldb debug console:
```
debugview frame
```

## Windows

Compile debugview_dll into `debugview_dll.dll`.

Include `debug_helper.h` in your cpp file. It load debugview_dll.dll automatically.

Start image_viewer.exe in another terminal.

Set a breakpoint and hit it, then in Immediate Window of Visual Studio (Ctrl+Alt+I):
```
DebugView(&frame)
```