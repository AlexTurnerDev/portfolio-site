\# Traffic Light Controller (Finite State Machine)



\*\*Full Documentation:\*\* \[View Lab Report (PDF)](./ECEN%20340\_Lab7\_Report%20(1).pdf)



\## Project Overview

This project implements a \*\*Finite State Machine (FSM)\*\* to control a 4-way traffic intersection. The system manages the timing and transitions between Red, Yellow, and Green lights for both "Main Street" and "Center Street," ensuring safe and efficient traffic flow.



\## Technical Implementation

\* \*\*Architecture:\*\* Moore Finite State Machine

\* \*\*Hardware:\*\* Basys3 FPGA (Artix-7)

\* \*\*Key Concept:\*\* State Transition Logic \& Parameterized Timers



\### State Logic

\[cite\_start]The controller cycles through 4 distinct states\[cite: 882, 970]:

1\.  `MainG\_CenterR` (Main Green, Center Red) - Duration: 15s

2\.  `MainY\_CenterR` (Main Yellow, Center Red) - Duration: 3s

3\.  `MainR\_CenterG` (Main Red, Center Green) - Duration: 10s

4\.  `MainR\_CenterY` (Main Red, Center Yellow) - Duration: 3s



\### Modular Design

\* \[cite\_start]\*\*`traffic\_light\_controller\_top`:\*\* The main FSM logic that handles state transitions based on timer done signals\[cite: 960].

\* \*\*`timer`:\*\* A reusable, parameterized module created to handle specific delays (3s, 10s, 15s)\[cite: 983, 1109].

\* \[cite\_start]\*\*`clk\_gen`:\*\* Generates a 1Hz reference pulse from the 100MHz system clock for accurate timing\[cite: 971].



\*\*Code Snippet (State Transition):\*\*

```verilog

always @(\*) begin

&nbsp;   next\_state = current\_state;

&nbsp;   case(current\_state)

&nbsp;       MainG\_CenterR: begin

&nbsp;           if(tm15\_done) next\_state = MainY\_CenterR;

&nbsp;       end

&nbsp;       MainY\_CenterR: begin

&nbsp;           if(tm3\_done) next\_state = MainR\_CenterG;

&nbsp;       end

&nbsp;       // ... additional states

&nbsp;   endcase

end

