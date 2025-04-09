
`timescale 1ns / 1ps

module clk_50_mhz(
input clk,
input reset,
output out_clk
    );    
    reg [27:0] COUNT;
    reg tmp;
    initial begin
        COUNT = 0;
        tmp = 0;
    end
    
    assign out_clk = tmp;
    
    always @(posedge clk) begin
        if (reset || COUNT == 28'd1) begin
            COUNT <= 0;
            tmp <= ~tmp;
            end
        else 
            COUNT <= COUNT + 1;      
    end
    
    
endmodule
   
