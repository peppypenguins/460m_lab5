`timescale 1ns / 1ps

module debouncer(
    input clk,
    input reset,
    input button,
    output reg out
    );

reg count = 1'd0;
wire tick;


// the counter that will generate the tick.

always @ (posedge clk or posedge reset)
    begin
        if(reset)
            count <= 0;
        else
            count <= count + 1;        
    end
    
assign tick = &count;  
// now for the debouncing FSM

localparam[3:0]                     //defining the various states to be used
                zero = 4'b000, 
                high1 = 4'b001,
                high2 = 4'b010,
                high3 = 4'b011,                
                one = 4'b100,
                low1 = 4'b101,
                low2 = 4'b110,
                low3 = 4'b111,
                waitState = 4'b1000,
                waitState2 = 4'b1001,
                high4 = 4'b1010,
                high5 = 4'b1011,
                high6 = 4'b1100,
                high7 = 4'b1101,
                high8 = 4'b1110;

reg [3:0]state_reg;
reg [3:0]state_next;
                
always @ (posedge clk or posedge reset)      
    begin
        if (reset)
            state_reg <= zero;
        else
            state_reg <= state_next;
    end
    

always @ (*)
    begin
        state_next <= state_reg;  // to make the current state the default state
        out <= 1'b0;                    // default output low
        
        case(state_reg)
            zero:
                if (button)                    //if button is detected go to next state high1
                    state_next <= high1;
            high1:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)                //but if button remains high go to next state high2.
                    state_next <= high2;
            high2:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)               
                    state_next <= high3;
            high3:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)         
                    state_next <= high4;
            high4:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)               
                    state_next <= high5;
            high5:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)               
                    state_next <= high6;
            high6:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)         
                    state_next <= high7;
            high7:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)               
                    state_next <= high8;
            high8:
                if (~button)                //while here if button goes back to zero then input is not yet stable and go back to state zero
                    state_next <= zero;
                else if (tick)         
                    state_next <= one;
            
            one:                                
                begin
                    out <= 1'b1;
                            state_next <=  waitState2; // go to waitstate for on pulse
                end
            low1:
                if (button)              
                    state_next <= one;
                else if (tick)            
                    state_next <= low2;
            low2:
                if (button)                
                    state_next <= one;
                else if (tick)            
                    state_next <= low3;
            low3:
                if (button)                
                    state_next <= one;
                else if (tick)           
                    state_next <= zero;
            waitState: begin
            out <= 1'b1;
                    state_next <= waitState2;   // extra state incase 2 cycle pulse was needed   
                    end     
            waitState2: begin // wait for button to be released before reset state. Ouput remains 0.
            out <= 1'b0;
                if (~button)
                    state_next <= zero;     
                    end           
            default state_next <= zero;
            
        endcase
    end
    
endmodule
