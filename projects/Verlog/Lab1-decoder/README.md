\# 3-to-8 Line Decoder (Structural Verilog)



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN340\_Lab2\_Report.pdf)



\## Project Overview

This project implements a \*\*3-to-8 Line Decoder\*\* using Verilog \*\*Structural Modeling\*\*. Unlike behavioral definitions, this design explicitly instantiates logic primitives (`AND`, `NOT` gates) to define the circuit topology. The design targets the \*\*Basys3 FPGA\*\* development board.



\## Technical Implementation

\* \*\*Language:\*\* Verilog (Structural)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Toolchain:\*\* Xilinx Vivado

\* \*\*Input:\*\* 3 Switches (`sw\[2:0]`)

\* \*\*Output:\*\* 8 LEDs (`led\[7:0]`)



\### Logic Description

The design decodes a 3-bit binary input into a one-hot output (active high).

\* \*\*Inverters:\*\* Created inverted signals for all inputs (`nsw\_0`, `nsw\_1`, `nsw\_2`).

\* \*\*AND Gates:\*\* 8 instances of 3-input AND gates map every possible binary combination (000-111) to a specific LED.



\*\*Code Snippet:\*\*

```verilog

// Example: Logic for LED 0 (Active when sw = 000)

and and\_gate (led\[0], nsw\_2, nsw\_1, nsw\_0);



// Example: Logic for LED 7 (Active when sw = 111)

and and\_gate7 (led\[7], sw\[2], sw\[1], sw\[0]);

