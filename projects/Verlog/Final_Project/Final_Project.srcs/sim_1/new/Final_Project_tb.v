`timescale 1ns / 1ps

module Final_Project_tb;

    // Inputs
    reg clk;
    reg btnC;
    reg btnR;
    reg btnL;
    reg btnU;
    reg btnD;

    // Outputs
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    Final_Project uut (
        .clk(clk), 
        .btnC(btnC), 
        .btnR(btnR), 
        .btnL(btnL), 
        .btnU(btnU), 
        .btnD(btnD), 
        .led(led), 
        .seg(seg), 
        .an(an)
    );

    // Clock Generation (100MHz = 10ns period)
    always #5 clk = ~clk;

    // --- Helper Task to Press a Button ---
    // Holds the button long enough to pass the Debouncer
    task press_button;
        input [2:0] btn_id; // 0=C, 1=U, 2=D, 3=L, 4=R
        begin
            case(btn_id)
                0: btnC = 1;
                1: btnU = 1;
                2: btnD = 1;
                3: btnL = 1;
                4: btnR = 1;
            endcase
            
            // Wait 20ms for debouncer (Debounce is approx 13ms in your code)
            #20_000_000; 
            
            btnC = 0; btnU = 0; btnD = 0; btnL = 0; btnR = 0;
            
            // Wait a bit after release
            #5_000_000;
        end
    endtask

    initial begin
        // 1. Initialize Inputs
        clk = 0;
        btnC = 0; btnR = 0; btnL = 0; btnU = 0; btnD = 0;

        // 2. Reset the System
        $display("--- Starting Simulation ---");
        $display("Applying Reset...");
        press_button(0); // Press Center (Reset)
        
        // Check State: Should be IDLE (0)
        if (uut.debug_state == 0) $display("State: IDLE (Correct)");
        else $display("Error: State is %d", uut.debug_state);

        // 3. Start Game (Press UP)
        $display("Starting Game (Pressing UP)...");
        press_button(1); // Press UP
        
        // Check State: Should be WAIT_REL (6) then NEW_ROUND(1) then WAIT_INPUT (2)
        // Since we release button in task, it should settle in WAIT_INPUT (2)
        #1000;
        if (uut.debug_state == 2) $display("State: WAIT_INPUT (Game Started!)");
        else $display("Error: Game did not start, State is %d", uut.debug_state);

        // 4. Test Timer Countdown (FORCE METHOD)
        // Instead of waiting 100,000,000 cycles, we force the pulse!
        $display("Testing Timer Countdown...");
        
        // Force the internal wire in game_logic to 1
        force uut.U_Game.pulse_1sec = 1; 
        #10; // Hold for 1 clock cycle
        force uut.U_Game.pulse_1sec = 0;
        release uut.U_Game.pulse_1sec; // Let it go back to normal
        
        #100; // Wait for logic to update
        
        if (uut.count_down == 29) $display("Timer Decremented to 29 (Success)");
        else $display("Timer Failed: %d", uut.count_down);

        // 5. Test Scoring (Cheating by looking at internal Direction)
        $display("Attempting to Score...");
        
        // Look at the random direction the game picked
        // 0=L, 1=R, 2=U, 3=D
        case(uut.dir)
            0: begin $display("Target is LEFT. Pressing Left..."); press_button(3); end
            1: begin $display("Target is RIGHT. Pressing Right..."); press_button(4); end
            2: begin $display("Target is UP. Pressing Up..."); press_button(1); end
            3: begin $display("Target is DOWN. Pressing Down..."); press_button(2); end
        endcase
        
        // Check if Score Increased
        if (uut.score == 1) $display("Score is 1! (Move Correct)");
        else $display("Score failed. Score is %d", uut.score);

        // 6. Test Menu (Pressing Right in IDLE)
        $display("Testing Menu Navigation...");
        press_button(0); // Reset first
        #1000;
        press_button(4); // Press Right (Menu)
        
        if (uut.debug_state == 9 || uut.debug_state == 8) // VIEW_HS or WAIT_TO_HS
            $display("Entered High Score Menu (Success)");
        else 
            $display("Menu Entry Failed. State: %d", uut.debug_state);

        $display("--- Simulation Complete ---");
        $finish;
    end
      
endmodule