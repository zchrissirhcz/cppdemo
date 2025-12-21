# image_viewer

A tool for visual debugging images.

## Setup

Compile main.cpp into `image_viewer` executable.

Create debugview.py script.

Edit launch.json to load debugview.py:
```json
            "initCommands": [
                //"command script import ${env:HOME}/.lldb/debugview.py"
                "command script import ${workspaceFolder}/image_viewer/debugview.py"
            ]
```

## Usage

step1:
```
./build/image_viewer/image_viewer
```

step2:
In lldb debug console:
```
debugview frame
```