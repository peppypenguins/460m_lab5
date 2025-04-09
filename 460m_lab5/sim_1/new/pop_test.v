`timescale 1ns / 1ps
module pop_test();
    reg clk;
    reg[3:0] btns;
    reg[7:0] swtchs;
    wire[7:0] leds;
    wire[6:0] segs;
    wire[3:0] an;
    
    top u1(.clk(clk), .btns(btns), .swtchs(swtchs), .leds(leds), .segs(segs), .an(an));
    
    
    initial begin
        clk = 1'b0;
        btns = 4'b0000;
        swtchs = 8'h00;
        
        #2;
        
        btns = 4'b1000;
         
        #50;
        
        btns = 4'b1010;
        
        #50;
        
        btns = 4'b0000;
        swtchs = 8'b01010000;
        
        #50;
        
        btns = 4'b0001;
        
        #50;
        
        btns = 4'b0000;
        swtchs = 8'b01010001;
        
        #50;
        
        btns = 4'b0001;
        
        #50;
        
        btns = 4'b0000;
        swtchs = 8'b01010010;
        
        #50;
        
        btns = 4'b0001;
        
        #50;
        
        btns = 4'b0000;
        
        #50;
        btns = 4'b0010;   
        
        #50;
        
        btns = 4'b0000;
        
        #50;
        
        btns = 4'b0010; 
        
        #50;
        
        btns = 4'b0000;
        
        #50;
        btns = 4'b0010;     
        
        #50;
        btns = 4'b0000; 
    end
    
    
    always
        clk = #1 ~clk;
    
endmodule
