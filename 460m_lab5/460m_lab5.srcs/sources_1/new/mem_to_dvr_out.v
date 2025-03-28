`timescale 1ns / 1ps
module mem_to_dvr_out(
input[7:0] data_out_mem,
output[6:0] out0,
output[6:0] out1,
output[6:0] out2,
output[6:0] out3
    );
    
    hex_to_seven_seg u1(.x(data_out_mem[3:0]), .r(out0));
    hex_to_seven_seg u2(.x(data_out_mem[7:4]), .r(out1));
    assign out2 = 7'b1111111;
    assign out3 = 7'b1111111;   
endmodule
