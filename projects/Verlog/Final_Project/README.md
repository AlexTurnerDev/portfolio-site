\# FPGA "Reaction Gauntlet" Game (Bop-It Style)



\*\*Full Documentation:\*\* \[View Final Report (PDF)](./ECEN%20340%20-%20Final%20Project%20Report%20(1).pdf)



\## Project Overview

This final capstone project implements a fast-paced reaction game on the \*\*Basys3 FPGA\*\*. Similar to "Bop-It," players must respond to directional commands (Up, Down, Left, Right) shown on the 7-segment display within a decreasing time limit.



\*\*Key Features:\*\*

\* \*\*High Score System:\*\* Uses onboard RAM to persistently store and retrieve the highest score achieved during the session.

\* \*\*Scrolling Text Engine:\*\* A custom driver that scrolls text strings (e.g., "LEGEND FALLEN", "NEW RECORD") across the 4-digit display.

\* \*\*Pseudo-Random Generation:\*\* Uses a Linear Feedback Shift Register (LFSR) to generate unpredictable command sequences.



\## Technical Implementation

\* \*\*Architecture:\*\* Modular System with a Central Game Controller

\* \*\*Hardware:\*\* Basys3 FPGA, 7-Segment Display, 5 Pushbuttons, 16 LEDs.

\* \*\*Complexity:\*\* 11 distinct FSM states managing gameplay loops, menus, and memory IO.



\### System Modules

1\.  \*\*`game\_logic.v`:\*\* The brain of the system. Contains the main FSM (`IDLE`, `WAIT\_INPUT`, `CHECK\_FAIL`, `SAVE\_SCORE`) and the LFSR for random direction generation.

2\.  \*\*`memory.v`:\*\* A 16x16 RAM module used to store the high score.

3\.  \*\*`segdisplay\_driver.v`:\*\* A complex driver that handles both static numbers (score/timer) and scrolling alphanumeric text messages using a lookup table of custom character patterns.

4\.  \*\*`debounce\_buttons.v`:\*\* Ensures reliable user input by filtering mechanical switch bounce.



\### Logic Description (LFSR)

To ensure the game is not predictable, I implemented a 4-bit Linear Feedback Shift Register.

```verilog

// LFSR for Random Direction Generation

always @(posedge clk) begin

&nbsp;   lfsr <= {lfsr\[2:0], lfsr\[3] ^ lfsr\[2]}; // XOR feedback tap

end

