`timescale 1ns / 1ps

module time_mux_state_machine(
input clk,
input reset,
input [6:0] in0,
input [6:0] in1,
input [6:0] in2,
input [6:0] in3,
output reg [3:0] an,
output reg [6:0] sseg
    );
    
    reg [1:0] state = 2'b0;
    reg [1:0] next_state;
    
    always @(*) begin // decides next state
    case (state)
    2'b00 : next_state = 2'b01; 
    2'b01 : next_state = 2'b10;
    2'b10 : next_state = 2'b11; 
    2'b11 : next_state = 2'b00;
    endcase
    end
    
    always @(*) begin // decides what number will be lit up on display
    
    case (state)
    2'b00 : sseg = in0 | 7'b0000000;
    2'b01 : sseg = in1 | 7'b0000000;
    2'b10 : sseg = in2 & 7'b1111111;
    2'b11 : sseg = in3 | 7'b0000000;
    
    endcase
    case (state) // decides which digit is being updated
    2'b00 : an = 4'b1110;
    2'b01 : an = 4'b1101;
    2'b10 : an = 4'b1011;
    2'b11 : an = 4'b0111;  
    endcase
    end
       
    always @(posedge clk or posedge reset) begin // changes states
    if (reset)
    state <= 2'b00;
    else
    state <= next_state;
    end
    
endmodule
