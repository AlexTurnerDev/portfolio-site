\# 7-Segment Display Hex Decoder



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN340\_Lab4\_Report%20(1).pdf)



\## Project Overview

This project implements a hardware driver for the \*\*7-Segment Display\*\* on the \*\*Basys3 FPGA\*\*. The system reads a 4-bit binary input from the physical switches and decodes it to display the corresponding Hexadecimal digit (0-9) on the LED display.



\## Technical Implementation

\* \*\*Language:\*\* Verilog (Behavioral Modeling)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Toolchain:\*\* Xilinx Vivado

\* \*\*Key Feature:\*\* Implemented a \*\*Testbench\*\* (`seg7\_tb`) to verify logic via simulation waveform analysis before hardware deployment.



\### Hardware Mapping

\* \*\*Inputs:\*\*

&nbsp;   \* `sw\[3:0]`: 4-bit binary number to display.

\* \*\*Outputs:\*\*

&nbsp;   \* `seg\[6:0]`: 7-bit signal driving the individual LED segments (active low).

&nbsp;   \* `an\[3:0]`: Anode signals to select the active digit.

&nbsp;   \* `dp`: Decimal point control.



\### Logic Description

The core logic utilizes a Verilog `case` statement to look up the correct segment pattern for each input value.

\* \*\*Anode Control:\*\* Hardcoded to `4'b1110` to enable the right-most digit only.

\* \*\*Decoder Logic:\*\* Maps binary inputs (e.g., `4'h0`) to segment patterns (e.g., `7'b1000000`).



\*\*Code Snippet:\*\*

```verilog

always @(sw)

&nbsp;   case (sw)

&nbsp;       4'h0: seg = 7'b1000000; // Display '0'

&nbsp;       4'h1: seg = 7'b1111001; // Display '1'

&nbsp;       4'h2: seg = 7'b0100100; // Display '2'

&nbsp;       // ... mappings for 3-9

&nbsp;   endcase

