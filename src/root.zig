//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn byte_to_block(byte: u8) u8 {
    return switch (byte) {
        0...31 => '▁',
        32...63 => '▂',
        64...95 => '▃',
        96...127 => '▄',
        128...159 => '▅',
        160...191 => '▆',
        192...223 => '▇',
        224...255 => '█',
    };
}
