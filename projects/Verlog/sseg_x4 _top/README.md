\# 4-Digit Multiplexed Display Controller



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN%20340\_%20Lab%206%20-%20Clock%20Generation%20and%20Module%20Instantiation%20(1).pdf)



\## Project Overview

This project implements a \*\*Time-Division Multiplexing\*\* system to drive all four digits of the 7-segment display on the \*\*Basys3 FPGA\*\* simultaneously. By rapidly switching between digits at a specific frequency, the design creates the "Persistence of Vision" illusion, making all numbers appear static and lit at once.



\## Technical Implementation

\* \*\*Architecture:\*\* Modular Hierarchy (Top-Level Instantiation)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7), Tektronix Oscilloscope (for timing verification)

\* \*\*Key Concept:\*\* Clock Division \& Module Instantiation



\### System Architecture

The design is split into four distinct modules managed by a top-level controller (`sseg\_x4\_top`):

1\.  \*\*`clk\_gen` (Clock Divider):\*\* Down-converts the Basys3's 100MHz system clock into a slower scanning clock. It uses a 26-bit counter and taps bit 16 to generate the strobe signal.

2\.  \*\*`digit\_selector` (Anode Control):\*\* A 2-bit counter that cycles through the 4 anodes (`an`), enabling one digit at a time.

3\.  \*\*`hex\_num\_gen` (Data Mux):\*\* Selects the correct 4-bit slice of data from the 16 switches based on which digit is currently active.

4\.  \*\*`sseg` (Decoder):\*\* The hex decoder (reused from Lab 4) that converts the 4-bit data into 7-segment LED patterns.



\*\*Code Snippet (Clock Division):\*\*

```verilog

// Simple counter-based clock divider

always @ (posedge clk) begin

&nbsp;   if (rst)

&nbsp;       reg\_count <= 26'b0;

&nbsp;   else

&nbsp;       reg\_count <= reg\_count + 1;

end

assign clkd = reg\_count\[16]; // Taps the 16th bit for the scanning frequency

