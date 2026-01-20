\# 8-Bit Signed/Unsigned Multiplier



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN%20340\_%20Lab%205%20Report%20(1).pdf)



\## Project Overview

This project implements a hardware-based \*\*8-Bit Multiplier\*\* on the \*\*Basys3 FPGA\*\*. It takes two 8-bit inputs from the onboard switches, calculates their 16-bit product using a shift-and-add algorithm, and displays the result on the LEDs.



\*\*Advanced Feature:\*\* This implementation supports \*\*Signed Numbers\*\* (2's Complement) arithmetic, allowing for the multiplication of negative integers (e.g., $-4 \\times 6 = -24$).



\## Technical Implementation

\* \*\*Language:\*\* Verilog (Dataflow/Structural)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Logic:\*\* Manual Partial Product Accumulation (Shift-and-Add)



\### Hardware Mapping

\* \*\*Inputs:\*\*

&nbsp;   \* `sw\[15:8]`: Input A (8-bit signed/unsigned)

&nbsp;   \* `sw\[7:0]`: Input B (8-bit signed/unsigned)

\* \*\*Outputs:\*\*

&nbsp;   \* `led\[15:0]`: 16-bit Product Result



\### Logic Description

The design breaks down the multiplication into partial products (`p0` - `p7`), similar to long multiplication.

\* \*\*Signed Arithmetic:\*\* Used the `signed` Verilog keyword and 2's complement logic to handle negative inputs correctly.

\* \*\*Partial Products:\*\* Each bit of the multiplier is ANDed with the multiplicand and shifted left by its bit position.

\* \*\*Final Sum:\*\* All partial products are summed to produce the final 16-bit output.



\*\*Code Snippet (Signed Logic):\*\*

```verilog

wire signed \[7:0] left\_sw = sw\[15:8];

wire signed \[7:0] right\_sw = sw\[7:0];



// Calculation of the last partial product (p7) with negation for 2's complement

assign p7 = -({1'b0, {8{right\_sw\[7]}} \& left\_sw\[7:0], 7'b0});



assign product = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;

