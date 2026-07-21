#ifndef CONFIG_H
#define CONFIG_H

// String used to delimit block outputs in the status.
#define DELIMITER " | "

// Maximum number of Unicode characters that a block can output.
#define MAX_BLOCK_OUTPUT_LENGTH 45

// Control whether blocks are clickable.
#define CLICKABLE_BLOCKS 1

// Control whether a leading delimiter should be prepended to the status.
#define LEADING_DELIMITER 0

// Control whether a trailing delimiter should be appended to the status.
#define TRAILING_DELIMITER 0

// Define blocks for the status feed as X(icon, cmd, interval, signal).
#define BLOCKS(X)                                                \
    X("", "/home/wolk/dwmblocks/status/music.sh", 5, 2)         \
    X("", "/home/wolk/dwmblocks/status/cpu.sh", 5, 3)           \
    X("", "/home/wolk/dwmblocks/status/ram.sh", 5, 4)           \
    X("", "/home/wolk/dwmblocks/status/wifi.sh", 10, 5)         \
    X("", "/home/wolk/dwmblocks/status/volume.sh", 0, 6)        \
    X("", "/home/wolk/dwmblocks/status/datetime.sh", 1, 7)

#endif  // CONFIG_H
