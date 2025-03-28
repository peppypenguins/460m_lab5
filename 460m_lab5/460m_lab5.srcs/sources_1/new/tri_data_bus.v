`timescale 1ns / 1ps
module tri_data_bus(
    input we,               
    input [7:0] driver1_data,
    input [7:0] driver2_data,
    output tri [7:0] data_bus
);

    assign data_bus = (we == 0) ? driver1_data : 8'bz;

    assign data_bus = (we == 1) ? driver2_data : 8'bz;

endmodule
