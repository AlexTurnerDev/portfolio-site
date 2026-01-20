\# 8-Bit Ripple Carry Adder



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN%20340%20-%20Lab%203%20(1).pdf)



\## Project Overview

This project implements an \*\*8-bit Ripple Carry Adder\*\* on the \*\*Basys3 FPGA\*\*. It takes two 8-bit binary numbers from the on-board switches, calculates their sum using a chain of full adders, and displays the result on the LEDs.



\## Technical Implementation

\* \*\*Language:\*\* Verilog (Modular Design)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Toolchain:\*\* Xilinx Vivado

\* \*\*Key Feature:\*\* Used Verilog `generate` blocks to programmatically instantiate adder stages, making the design scalable to any bit-width.



\### Hardware Mapping

\* \*\*Inputs:\*\*

&nbsp;   \* `sw\[7:0]`: First 8-bit number ($A$)

&nbsp;   \* `sw\[15:8]`: Second 8-bit number ($B$)

&nbsp;   \* `btnC`: Initial Carry-In ($C\_{in}$)

\* \*\*Outputs:\*\*

&nbsp;   \* `led\[8:0]`: 9-bit Result (Sum + Final Carry Out)



\### Logic Description

The design uses a \*\*Full Adder\*\* module as the base building block. It calculates the Sum ($S$) and Carry-Out ($C\_{out}$) using logic primitives:

\* \*\*Sum:\*\* $A \\oplus B \\oplus C\_{in}$

\* \*\*Carry:\*\* $(A \\cdot B) + (C\_{in} \\cdot (A \\oplus B))$



\*\*Code Snippet (Scalable Architecture):\*\*

Instead of manually typing out 8 separate stages, I utilized a `generate` loop to create the ripple carry chain:

```verilog

generate

&nbsp;   genvar i;

&nbsp;   for (i = 0; i < 8; i = i + 1) begin : ripple\_carry\_stage

&nbsp;       fulladd stage (

&nbsp;           .Cin(c\[i]),

&nbsp;           .x(a\[i]),

&nbsp;           .y(b\[i]),

&nbsp;           .s(led\[i]),

&nbsp;           .Cout(c\[i+1])

&nbsp;       );

&nbsp;   end

endgenerate

