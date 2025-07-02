# Menu Module - 64-bit Assembly

## Overview

The `menu.s` module provides an interactive terminal-based user interface for navigating through different program options. It's designed to offer a smooth and accessible experience, simulating a real navigable menu in the terminal environment.

## Features

### Visual Interface
- **ANSI Color Support**: Uses ANSI escape codes for colors, highlighting, and screen management
- **Dynamic Highlighting**: Currently selected option is highlighted in green with reverse video
- **Clean Layout**: Formatted headers and options for improved readability
- **Screen Management**: Automatic screen clearing and cursor positioning

### Navigation Methods
The menu supports dual navigation modes for maximum flexibility:

1. **Arrow Key Navigation**: 
   - Use UP/DOWN arrow keys to navigate between options
   - Press ENTER to select the highlighted option

2. **Direct Numeric Input**: 
   - Press keys 1-4 to directly select options
   - Immediate execution without requiring ENTER

### Menu Options
1. **Exit** - Terminates the program
2. **Option 2** - Placeholder for future functionality 
3. **Option 3** - Placeholder for future functionality
4. **Option 4** - Placeholder for future functionality

## Technical Implementation

### Terminal Mode Management
The module implements sophisticated terminal control:

- **Raw Mode**: Activated during menu navigation to capture individual keystrokes in real-time
- **Canonical Mode**: Restored when exiting or calling external functions
- **State Preservation**: Original terminal settings are saved and restored properly

### Memory Organization

#### `.data` Section (Initialized Data)
- **ANSI Sequences**: Terminal control codes for colors and positioning
- **Menu Text**: Option labels and interface messages
- **Position Codes**: Cursor positioning sequences for screen layout

#### `.bss` Section (Uninitialized Data)
- **Input Buffer**: 32-byte buffer for user input
- **Terminal Settings**: Storage for original and modified terminal configurations

### Key Technical Features

#### ANSI Escape Sequences Used
```assembly
clear_screen: .ascii "\x1B[H\x1B[J"     # Clear screen and home cursor
colore_reset: .ascii "\x1B[0m"          # Reset all formatting
verde: .ascii "\x1B[32m"                # Green text color
giallo: .ascii "\x1B[33m"               # Yellow text color 
reverse_video: .ascii "\x1B[7m"         # Reverse video highlighting
```

#### Register Usage (64-bit)
- **%r9**: Current menu selection (0-3)
- **%r8**: Loop counter for menu rendering
- **%rax**: System call number and return values
- **%rdi**: File descriptors and function parameters
- **%rsi**: Buffer addresses and data pointers
- **%rdx**: Data lengths for system calls

### Input Handling

#### Arrow Key Detection
The module detects arrow key sequences by parsing the three-byte ANSI sequence:
- ESC (0x1B) + '[' (0x5B) + 'A'/'B' (0x41/0x42) for UP/DOWN

#### Wrap-around Navigation
- Moving up from the first option wraps to the last option
- Moving down from the last option wraps to the first option

## Function Descriptions

### Core Functions

#### `_start`
Entry point that initializes the terminal and starts the main menu loop.

#### `menu_loop`
Main program loop that:
1. Renders the complete menu interface
2. Waits for user input
3. Processes the input and updates selection
4. Handles option execution

#### `disegna_tutto` (Draw Everything)
Comprehensive menu rendering function that:
- Clears the screen
- Draws the header with highlighting
- Renders all menu options
- Highlights the currently selected option
- Positions the cursor appropriately

#### `prepara_terminale` (Prepare Terminal)
Configures the terminal for raw mode operation:
- Saves original terminal settings
- Disables canonical mode (ICANON)
- Disables echo (ECHO)
- Sets minimum read characters (VMIN=1)
- Sets read timeout (VTIME=0)

#### `restore_terminal`
Restores the terminal to its original state:
- Reapplies saved terminal settings
- Clears screen and resets colors
- Ensures clean program exit

#### `mostra_non_implementato` (Show Not Implemented)
Displays a message for unimplemented options and waits for user acknowledgment.

### Error Handling

The module includes robust error handling:
- Graceful handling of invalid input
- Proper terminal state restoration on exit
- Clear user feedback for unimplemented features

## Project Structure

```
project/
├── Makefile              # Build configuration
├── src/
│   └── menu.s           # Main assembly source file
├── obj/
│   └── menu.o           # Compiled object file (generated)
└── bin/
    └── menu             # Final executable (generated)
```

## Building and Running

### Prerequisites
- GNU Assembler (as) with 64-bit support
- GNU Linker (ld)
- Linux environment with terminal support

### Compilation
```bash
make all    # Build the executable
make run    # Build and run the program
make clean  # Remove object files and executables
```

### Manual Compilation
```bash
as --64 -o obj/menu.o src/menu.s
ld -o bin/menu obj/menu.o
./bin/menu
```

### Makefile Structure
The project uses a structured approach with separate directories:
- **src/**: Contains the source assembly file (`menu.s`)
- **obj/**: Stores compiled object files (`menu.o`)
- **bin/**: Contains the final executable (`menu`)

This organization keeps the project clean and separates source code from build artifacts.

## Design Decisions

### 64-bit Architecture Adaptations
- Updated from 32-bit registers (%eax, %ebx) to 64-bit registers (%rax, %rdi, %rsi)
- Modified system call conventions for x86_64
- Adjusted memory addressing for 64-bit pointers
- Updated terminal control structure handling for 64-bit compatibility

### User Experience Focus
- **Accessibility**: Multiple navigation methods accommodate different user preferences
- **Visual Clarity**: Color coding and highlighting improve usability
- **Responsiveness**: Real-time input processing without waiting for Enter key
- **Robustness**: Comprehensive error handling prevents crashes

### Future Extensibility
The modular design allows for easy integration of additional functionality:
- Option handlers can be easily replaced with actual implementations
- Menu structure can be extended with additional options
- Color scheme and layout can be customized through data section modifications

## Known Limitations

- Currently supports only 4 menu options (expandable)
- Options 2-4 are placeholder implementations
- Terminal compatibility limited to ANSI-compatible terminals
- No configuration file support (hard-coded menu structure)

## Technical Notes

The code serves as both a functional user interface and an educational example of systems programming in assembly language.
