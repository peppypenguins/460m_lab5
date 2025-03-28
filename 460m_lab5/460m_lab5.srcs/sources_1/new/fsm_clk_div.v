`timescale 1ns / 1ps

module fsm_clk_div(
input clk,
input reset,
output out_clk
    );
    
    reg[14:0] COUNT = 0;
    assign out_clk = COUNT[14];
    
    always@(posedge clk) begin
    if (reset) begin
    COUNT <= 0;
    end
    else 
    COUNT <= COUNT + 1;
    end
    
    
endmodule
