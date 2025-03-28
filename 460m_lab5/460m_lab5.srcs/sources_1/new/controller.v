`timescale 1ns / 1ps
module controller(clk, cs, we, address, data_in, data_out, btns, swtchs, leds, segs, an);
    input clk;
    output cs;
    output we;
    output[6:0] address;
    input[7:0] data_in;
    output[7:0] data_out;
    input[3:0] btns;
    input[7:0] swtchs;
    output[7:0] leds;
    output[6:0] segs;
    output[3:0] an;
    //WRITE THE FUNCTION OF THE CONTROLLER
    
    parameter   START = 0,
                DELETE = 1,
                ENTER = 2,
                ADD = 3,
                SUBTRACT = 4,
                CLEAR = 5,
                TOP = 6,
                DEC = 7,
                INC = 8,
                CLEAN = 9,
                DELETE_WAIT = 10,
                ENTER_WAIT_1 = 11,
                ENTER_CLEAN = 12,
                ADD_POP_1 = 13,
                ADD_POP_2 = 14,
                ADD_STORE_1 = 15,
                ADD_STORE_2 = 16,
                SUB_POP_1 = 17,
                SUB_POP_2 = 18,
                SUB_STORE_1 = 19,
                TOP_READ = 20,
                DEC_READ = 21,
                INC_READ = 22;
                
                  
    
    
    reg [4:0] S;
    reg [4:0] NS;
    
    wire btn3 = btns[3];
    wire btn2 = btns[2];
    wire btn1 = btns[1];
    wire btn0 = btns[0];
    
    wire pop = (!btn3) && (!btn2) && btn1;
    wire push = (!btn3) && (!btn2) && btn0;
    wire add = (!btn3) && btn2 && btn0;
    wire subtract = (!btn3) && btn2 && btn1;
    wire clear = (btn3) && (!btn2) && btn1;
    wire top = (btn3) && (!btn2) && btn0;
    wire dec = btn3 && btn2 && btn1;
    wire inc = btn3 && btn2 && btn0;
    
    wire[4:0] next_operation;
    
    reg [6:0] SPR;
    reg [6:0] DAR;
    reg [7:0] DVR;
    reg [7:0] bus_reg;
    reg [6:0] addr_reg;
    reg [7:0] op_1;
    reg [7:0] op_2;
    reg [7:0] res_reg;
    reg we_reg;
    reg cs_reg;
    reg[2:0] counter;
    
    wire[6:0] in3;
    wire[6:0] in2;
    wire[6:0] in1;
    wire[6:0] in0;
    
    wire fsm_clk;
    
    
    sel_next_state u1(.pop(pop), .push(push), . add(add), . subtract(subtract), .clear(clear),
        .top(top), . dec(dec), .inc(inc), .NS(next_operation));
        
    fsm_clk_div u2(.clk(clk), .reset(clear), .out_clk(fsm_clk));
        
    mem_to_dvr_out c0(.data_out_mem(DVR), .out0(in0), .out1(in1), .out2(in2), .out3(in3));
    
    time_mux_state_machine c1 ( // display sseg outputs on fpga board
    .clk(fsm_clk),
    .reset(0),
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .an(an),
    .sseg(segs)
    );
    
    assign address = addr_reg;
    assign data_out = bus_reg;
    assign we = we_reg;
    assign cs = cs_reg;
    assign leds[6:0] = DAR;
    assign leds[7:7] = (SPR == 7'h7f) ? 1 : 0;
    
    
    initial begin
        SPR = 7'h7f;
        DAR = 7'h00;
        DVR = 8'h00;
        bus_reg = 8'h00;
        S = 5'b00000;
        NS = 5'b00000;
        we_reg = 0;
        cs_reg = 0;
        counter = 0;        
    end
    
    always @ (posedge clk) begin
        if (clear) begin
            S <= 5'b00000;
            NS <= 5'b00000;
        end else
            S <= NS;          
    end
    
    
    always @(*) begin
        case (S) 
            START   : NS = next_operation;
            DELETE  : begin
                SPR = SPR + 1;
                DAR = SPR + 1;
                addr_reg = DAR; 
                we_reg = 1;   
                NS = DELETE_WAIT;       
            end
            DELETE_WAIT: 
            if (counter == 4) begin
                counter = 0;
                DVR = data_in;
                we_reg = 0;
                NS = START;
            end else begin
                counter = counter + 1;
                NS = DELETE_WAIT;
            end
            ENTER   : begin
                bus_reg = swtchs;
                addr_reg = SPR;
                NS = ENTER_WAIT_1;                           
            end
            ENTER_WAIT_1: 
            if (counter == 2) begin
                cs_reg = 1;
                we_reg = 1;
                counter = 0;
                NS = ENTER_CLEAN;
            end else begin
                counter = counter + 1;
                NS = ENTER_WAIT_1;
            end
            ENTER_CLEAN: begin
                SPR = SPR - 1;
                DAR = SPR + 1;
                DVR = data_in;
                we_reg = 0;
                cs_reg = 0;               
                NS = START;            
            end           
            ADD     : begin
                addr_reg = SPR + 1;
                we_reg = 1;
                NS = ADD_POP_1;            
            end
            ADD_POP_1: begin
                if (counter == 2) begin
                    counter = 0;
                    op_1 = data_in;
                    SPR = SPR + 1;
                    DAR = SPR + 1;
                    addr_reg = DAR;
                    NS = ADD_POP_2;
                end else begin
                    counter = counter + 1;
                    NS = ADD_POP_1;
                end                      
            end
            ADD_POP_2: begin
                if (counter == 2) begin
                    counter = 0;
                    op_2 = data_in;
                    SPR = SPR + 1;
                    DAR = SPR + 1;
                    we_reg = 0;
                    bus_reg = op_1 + op_2;
                    DVR = op_1 + op_2;
                    addr_reg = SPR;
                    NS = ADD_STORE_1;
                end else begin
                    counter = counter + 1;
                    NS = ADD_POP_2;               
                end           
            end
            ADD_STORE_1: begin
                if (counter == 2) begin
                    counter = 0;
                    cs_reg = 1;
                    we_reg = 1;                                   
                    NS = ADD_STORE_2;
                end else begin
                    counter = counter + 1;
                    NS = ADD_STORE_1;
                end
            end
            ADD_STORE_2: begin
                SPR = SPR - 1;
                DAR = SPR + 1;
                cs_reg = 0;
                we_reg = 0;
                NS = START;
            end
            SUBTRACT: begin
                addr_reg = SPR + 1;
                we_reg = 1;
                NS = SUB_POP_1;            
            end
            SUB_POP_1: begin
                if (counter == 2) begin
                    counter = 0;
                    op_1 = data_in;
                    SPR = SPR + 1;
                    DAR = SPR + 1;
                    addr_reg = DAR;
                    NS = SUB_POP_2;
                end else begin
                    counter = counter + 1;
                    NS = SUB_POP_1;
                end                      
            end
            SUB_POP_2: begin
                if (counter == 2) begin
                    counter = 0;
                    op_2 = data_in;
                    SPR = SPR + 1;
                    DAR = SPR + 1;
                    we_reg = 0;
                    bus_reg = op_1 - op_2;
                    DVR = op_1 - op_2;
                    addr_reg = SPR;
                    NS = SUB_STORE_1;
                end else begin
                    counter = counter + 1;
                    NS = SUB_POP_2;               
                end           
            end
            SUB_STORE_1: begin
                if (counter == 2) begin
                    counter = 0;
                    cs_reg = 1;
                    we_reg = 1;                                   
                    NS = ADD_STORE_2;
                end else begin
                    counter = counter + 1;
                    NS = SUB_STORE_1;
                end
            end
            CLEAR    : begin
                SPR = 7'h7f;
                DAR = 7'h00;
                DVR = 8'h00;
                NS = START;           
            end
            TOP      :begin
                DAR = SPR + 1;
                addr_reg = DAR;
                we_reg = 1; 
                NS = TOP_READ;           
            end
            TOP_READ: begin
                if (counter == 2) begin
                    counter = 0;
                    DVR = data_in;
                    we_reg = 0;
                    NS = START;
                end else begin
                    counter = counter + 1;
                    NS = TOP_READ;
                end          
            end
            DEC      :begin
                DAR = DAR - 1;
                addr_reg = DAR;
                we_reg = 1; 
                NS = DEC_READ;           
            end
            DEC_READ: begin
                if (counter == 2) begin
                    counter = 0;
                    DVR = data_in;
                    we_reg = 0;
                    NS = START;
                end else begin
                    counter = counter + 1;
                    NS = DEC_READ;
                end           
            end
            INC      :begin
                DAR = DAR + 1;
                addr_reg = DAR;
                we_reg = 1; 
                NS = DEC_READ;  
            
            end
            INC_READ :begin
                if (counter == 2) begin
                    counter = 0;
                    DVR = data_in;
                    we_reg = 0;
                    NS = START;
                end else begin
                    counter = counter + 1;
                    NS = INC_READ;
                end 
            end
            CLEAN    : NS = START;       
            default: NS = START;
        endcase 
    end
     
endmodule

