`timescale 1ns / 1ps


module top(clk, btns, swtchs, leds, segs, an);
input clk;
input[3:0] btns;
input[7:0] swtchs;
output[7:0] leds;
output[6:0] segs;
output[3:0] an;

//might need to change some of these from wires to regs
wire cs;
wire we;
wire[6:0] addr;
wire[7:0] data_out_mem;
wire[7:0] data_out_ctrl;
tri[7:0] data_bus;

wire true_clk;

wire btn3;
wire btn2;
wire btn1;
wire btn0;

wire[3:0] btns_debounce = {btn3, btn2, btn1, btn0};


debouncer b3( .clk(clk), .reset(0), .button(btns[3]), .out(btn3));
debouncer b2( .clk(clk), .reset(0), .button(btns[2]), .out(btn2));
debouncer b1( .clk(clk), .reset(0), .button(btns[1]), .out(btn1));
debouncer b0( .clk(clk), .reset(0), .button(btns[0]), .out(btn0));

clk_50_mhz u2(.clk(clk), .out_clk(true_clk));

//CHANGE THESE TWO LINES
//assign data_bus = 1; // 1st driver of the data bus -- tri state switches
// function of we and data_out_ctrl

//assign data_bus = 1; // 2nd driver of the data bus -- tri state switches
// function of we and data_out_mem

tri_data_bus t0(.we(we), .driver1_data(data_out_ctrl), .driver2_data(data_out_mem), .data_bus(data_bus));

controller ctrl(true_clk, cs, we, addr, data_bus, data_out_ctrl,
btns_debounce, swtchs, leds, segs, an);
memory mem(true_clk, cs, we, addr, data_bus, data_out_mem);
//add any other functions you need
//(e.g. debouncing, multiplexing, clock-division, etc)



endmodule

