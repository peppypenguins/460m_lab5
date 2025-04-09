`timescale 1ns / 1ps
module tri_data_bus(
    input clk,
    input we,                // Write enable
    input [7:0] driver1_data,
    input [7:0] driver2_data,
    output [7:0] data_bus
);
    reg[7:0] data_reg;
    assign data_bus = data_reg;
    initial begin
        data_reg = 8'h00;
    end


    always @(posedge clk) begin       
        if (we) begin
            data_reg <= driver2_data;
        end else begin
            data_reg <= driver1_data;
        end
    end

endmodule

