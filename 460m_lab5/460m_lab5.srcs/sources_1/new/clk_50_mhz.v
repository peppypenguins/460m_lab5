`timescale 1ns / 1ps

module clk_50_mhz(
    input clk,
    output reg out_clk
    );
    
    initial begin
        out_clk = 1'b0;
    end
    
    
    always @ (*) begin
        if (clk == 1'b1)
            out_clk = ~out_clk;
        else 
            out_clk = out_clk;
    end
    
    
endmodule
