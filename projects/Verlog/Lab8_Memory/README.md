\# 16x16 Static RAM (SRAM) Controller



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN%20340%20-%20Lab%208%20Report%20(1).pdf)



\## Project Overview

This project involves the design and implementation of a synchronous \*\*16x16 Static Random Access Memory (SRAM)\*\* module. The memory is integrated into a larger top-level system on the \*\*Basys3 FPGA\*\*, allowing users to manually Write data via switches and Read data to the 7-segment display.



\*\*Key Engineering Concept:\*\* The design utilizes \*\*Tri-State Buffers\*\* (High-Impedance 'Z' states) to manage a bi-directional data bus, mimicking real-world memory architectures where Data-In and Data-Out share the same physical lines.



\## Technical Implementation

\* \*\*Language:\*\* Verilog (Structural \& Behavioral)

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Key Components:\*\*

&nbsp;   \* \*\*SRAM Cell:\*\* Custom 16-address x 16-bit memory module.

&nbsp;   \* \*\*Tri-State Logic:\*\* Used to drive the bus during 'Read' operations and release it (High-Z) during 'Write' operations.

&nbsp;   \* \*\*Debouncers:\*\* Cleaned mechanical button inputs for reliable Write Enable (WE) signaling.



\### Logic Description

The core memory module uses an `inout` port for the data bus. The logic ensures that the FPGA only drives the line when Output Enable (`oe`) is high and Write Enable (`we`) is low.



\*\*Code Snippet (Tri-State Logic):\*\*

```verilog

// If Output Enable is High and NOT Writing -> Drive the Bus

// Otherwise -> Set to High-Impedance (Z) to allow external writing

assign data = (oe \&\& !we) ? mem\[addr] : 16'hZZZZ;



always @(posedge clk) begin

&nbsp;   if (we) mem\[addr] <= data; // Write operation

end

