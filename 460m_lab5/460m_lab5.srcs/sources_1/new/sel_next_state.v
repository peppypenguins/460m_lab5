`timescale 1ns / 1ps

module sel_next_state(
    input pop,
    input push,
    input add,
    input subtract,
    input clear,
    input top,
    input dec,
    input inc,
    output[4:0] NS
    );
    reg[4:0] NS_reg = 5'b00001;
    
    assign NS = NS_reg;
    
    always @ (*) begin
        if (pop)
            NS_reg = 4'd1;
        else if (push)
            NS_reg = 4'd2;
        else if (add)
            NS_reg = 4'd3;
        else if (subtract)
            NS_reg = 4'd4;
        else if (clear)
            NS_reg = 4'd5;
        else if (top)
            NS_reg = 4'd6;
        else if (dec)
            NS_reg = 4'd7;
        else if (inc)
            NS_reg = 4'd8;
        else 
            NS_reg = 4'd0;  
    end
endmodule
