# cavablocks-zig

Like [cavablocks](https://github.com/Typhoon1551/cavablocks), but written in zig.

Converts Cava output into ASCII block characters (i.e. ▁▂▃▄▅▆▇█) for use in taskbars or other things.

## Usage

`<path to executable> <output width> <framerate>`

## Building

### Dependencies
 - Zig
 - Cava

### Steps
1. Clone repo
2. run `zig build --release=fast`
3. Copy/move executable onto PATH
