# prince-of-persia-asm
embedded
# Prince of Persia Clone in Assembly

A simple **x86 Assembly** game inspired by *Prince of Persia*, running in **real mode (DOS)**.

## Features
- Move left and right using arrow keys
- Jump using the up arrow key
- Runs in **Video Mode 13h (320x200, 256 colors)**

## Installation & Usage
1. Install **NASM** and **DOSBox**.
2. Assemble the code:
   ```bash
   nasm -f bin prince_clone.asm -o prince_clone.com

