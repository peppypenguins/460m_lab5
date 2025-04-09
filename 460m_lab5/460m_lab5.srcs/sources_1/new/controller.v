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
                INC_READ = 22,
                WAIT_ONE_CYCLE = 23,
                ADD_POP_MID = 24,
                SUB_POP_MID = 26;   
    
    reg [4:0] S;
    reg [4:0] NS;
    reg [4:0] PS;
    reg [4:0] prev_op;
    
    wire pop = (!btns[3]) && (!btns[2]) && btns[1];
    wire push = (!btns[3]) && (!btns[2]) && btns[0];
    wire add = (!btns[3]) && btns[2] && btns[0];
    wire subtract = (!btns[3]) && btns[2] && btns[1];
    wire clear = (btns[3]) && (!btns[2]) && btns[1];
    wire top = (btns[3]) && (!btns[2]) && btns[0];
    wire dec = btns[3] && btns[2] && btns[1];
    wire inc = btns[3] && btns[2] && btns[0];
    
    wire clk_change = clk;
    
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
        addr_reg = 7'b0000000;
        S = 5'b00000;
        NS = 5'b00000;
        PS = 5'b00000;
        prev_op = 5'b00000;
        we_reg = 0;
        cs_reg = 0;
        counter = 0;        
    end
    
    always @ (*) begin
        case (S)
           START:begin
                NS = next_operation;
                PS = START;
                prev_op = next_operation;
           end
           DELETE:begin
                prev_op = prev_op;
                NS = DELETE_WAIT;
                PS = DELETE;
           end
           ENTER:begin
                prev_op = prev_op;
                NS = ENTER_WAIT_1;
                PS = ENTER;
           end
           ADD:begin
                prev_op = prev_op;
                NS = ADD_POP_1; 
                PS = ADD;
           end
           SUBTRACT:begin
                prev_op = prev_op;
                NS = SUB_POP_1;
                PS = SUBTRACT;
           end
           CLEAR:begin
                prev_op = prev_op;
                NS = CLEAN;
                PS = CLEAR;
           end
           TOP:begin
                prev_op = prev_op;
                NS = TOP_READ;
                PS = TOP;
           end
           DEC:begin
                prev_op = prev_op;
                NS = DEC_READ;
                PS = DEC;
           end
           INC:begin
                prev_op = prev_op;
                NS = INC_READ;
                PS = INC;
           end
           CLEAN:begin
                prev_op = prev_op;
                PS = CLEAN;
                if (prev_op != next_operation) 
                    NS <= START;
                else 
                    NS <= CLEAN; 
           end
           DELETE_WAIT:begin
                prev_op = prev_op;
                PS = DELETE_WAIT;
            if (counter >= 1)
                NS = CLEAN;
            else 
                NS = DELETE_WAIT;
           end
           ENTER_WAIT_1:begin
                PS = ENTER_WAIT_1;
                prev_op = prev_op;
                
                if (counter >= 1)
                    NS = ENTER_CLEAN;
                else
                    NS = ENTER_WAIT_1;
           end
           ENTER_CLEAN:begin
                prev_op = prev_op;
                NS = CLEAN;
                PS = ENTER_CLEAN;
           end
           ADD_POP_1:begin
                prev_op = prev_op;
                NS = ADD_POP_MID;
                PS = ADD_POP_1;
           end
           ADD_POP_2:begin
                prev_op = prev_op;
                NS = ADD_STORE_1;
                PS = ADD_POP_2;
           end
           ADD_STORE_1:begin
                prev_op = prev_op;
                PS = ADD_STORE_1;
                if (counter >= 1)
                    NS = ADD_STORE_2;
                else 
                    NS = ADD_STORE_1;
           end
           ADD_STORE_2:begin
                prev_op = prev_op;
                NS = CLEAN;
                PS = ADD_STORE_2;
           end
           SUB_POP_1:begin
                prev_op = prev_op;
                NS = SUB_POP_MID;
                PS = SUB_POP_1;
           end
           SUB_POP_2:begin
                prev_op = prev_op;
                NS = SUB_STORE_1;
                PS = SUB_POP_2;
           end
           SUB_STORE_1:begin
                prev_op = prev_op;
                PS = SUB_STORE_1;
                if (counter >= 1)
                    NS = ADD_STORE_2;
                else 
                    NS = SUB_STORE_1;
           end
           TOP_READ:begin
                prev_op = prev_op;
                
                if (counter >= 1)
                    NS = CLEAN;
                else 
                    NS = TOP_READ;
                PS = TOP_READ;
           end
           DEC_READ:begin
                prev_op = prev_op;
                if (counter >= 1)           
                    NS = CLEAN;
                else 
                    NS = DEC_READ;
                PS = DEC_READ;
           end
           INC_READ:begin
                prev_op = prev_op;
                if (counter >= 1)
                    NS = CLEAN;
                else 
                    NS = INC_READ;
                PS = INC_READ;
           end
           ADD_POP_MID: begin
                prev_op = prev_op;
                NS = ADD_POP_2;
                PS = ADD_POP_MID;
           end
           SUB_POP_MID: begin
                prev_op = prev_op;
                NS = SUB_POP_2;
                PS = SUB_POP_MID;
           end
           WAIT_ONE_CYCLE: begin
                prev_op = prev_op;
                case (PS)
                    ENTER_WAIT_1: NS = ENTER_CLEAN;
                    ADD_STORE_1: NS = ADD_STORE_2;
                    SUB_STORE_1: NS = ADD_STORE_2;
                    default: NS = CLEAN;
                endcase
                PS = WAIT_ONE_CYCLE;
           end
           default: begin
                prev_op = prev_op;
                NS = START;
                PS = START;
           end
        endcase
    end
    
    
    always @ (posedge clk) begin
            S <= NS;          
    end
    
    always @(posedge clk) begin
        case (S) 
            START   : begin             
                //NS <= next_operation;
                //prev_op <= next_operation;
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
            end
            DELETE  : begin
                SPR <= SPR;
                DAR <= DAR;
                addr_reg <= SPR + 2; 
                we_reg <= 1;   
                //NS <= DELETE_WAIT;                  
                cs_reg <= cs_reg;
                counter <= counter;
                DVR <= DVR; 
                prev_op <= prev_op;  
                
                /*
                addr_reg <= SPR + 1;
                we_reg <= 1;
                //NS <= ADD_POP_1;    
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;  
                */                 
            end
            DELETE_WAIT: 
            if (counter >= 1) begin
                counter <= 0;
                DVR <= data_in;
                we_reg <= 0;
                cs_reg <= cs_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= SPR + 2;
                SPR <= SPR + 1;
                op_1 <= op_1;
                op_2 <= op_2;
            end else begin
                    counter <= counter + 1;
                    op_1 <= op_1;
                    SPR <= SPR;
                    DAR <= SPR;
                    addr_reg <= addr_reg;
                    cs_reg <= cs_reg;
                    we_reg <= we_reg;
                    op_2 <= op_2;
                    DVR <= DVR;
                    prev_op <= prev_op; 
            end
            ENTER   : begin
                bus_reg <= swtchs;
                addr_reg <= SPR;
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                //NS <= ENTER_WAIT_1;  
                prev_op <= prev_op;                         
            end
            ENTER_WAIT_1: 
            if (counter >= 1) begin
                //NS <= CLEAN;
                cs_reg <= 1;
                we_reg <= 1;
                counter <= counter;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;
            end else begin
                counter <= counter + 1;
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                //NS <= ENTER_CLEAN;
                prev_op <= prev_op;
            end
            ENTER_CLEAN: begin
                //NS <= CLEAN;
                SPR <= SPR - 1;
                DAR <= SPR;
                DVR <= data_in;
                we_reg <= 0;
                cs_reg <= 0;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                counter <= 0;
                op_1 <= op_1;
                op_2 <= op_2;             
                prev_op <= prev_op;            
            end           
            ADD     : begin
                addr_reg <= SPR + 1;
                we_reg <= 1;
                //NS <= ADD_POP_1;    
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;        
            end
            ADD_POP_1: begin
                //if (counter >= 2) begin
                    counter <= 0;
                    op_1 <= data_in;
                    SPR <= SPR + 1;
                    DAR <= SPR + 2;
                    addr_reg <= SPR + 2;
                    cs_reg <= cs_reg;
                    we_reg <= 1;
                    op_2 <= op_2;
                    DVR <= DVR;
                    //NS <= ADD_POP_2;
                    prev_op <= prev_op;                   
                /*end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    NS = ADD_POP_1;
                    prev_op = prev_op;
                end  */                    
            end
            ADD_POP_MID: begin
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
            end
            ADD_POP_2: begin
                //if (counter == 2) begin
                    counter <= 0;
                    op_2 <= data_in;
                    SPR <= SPR + 1;
                    DAR <= SPR + 2;
                    we_reg <= 0;
                    bus_reg <= op_1 + data_in;
                    DVR <= op_1 + data_in;
                    addr_reg <= SPR + 1;
                    //NS <= ADD_STORE_1;
                    prev_op <= prev_op;
               /* end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    NS = ADD_POP_2;
                    prev_op = prev_op;               
                end     */      
            end
            ADD_STORE_1: begin
                if (counter >= 1) begin
                    counter <= 0;
                    cs_reg <= 1;
                    we_reg <= 1;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    DVR <= DVR;                                   
                    //NS <= ADD_STORE_2;
                    prev_op <= prev_op;
                end else begin
                    counter <= counter + 1;
                    cs_reg <= cs_reg;
                    we_reg <= we_reg;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    DVR <= DVR;
                    //NS <= ADD_STORE_1;
                    prev_op <= prev_op;
                end
            end
            ADD_STORE_2: begin
                SPR <= SPR - 1;
                DAR <= SPR;
                cs_reg <= 0;
                we_reg <= 0;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                //NS <= CLEAN;
                prev_op <= prev_op;
            end
            SUBTRACT: begin
                addr_reg <= SPR + 1;
                we_reg <= 1;   
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;            
            end
            SUB_POP_1: begin
                    counter <= 0;
                    op_1 <= data_in;
                    SPR <= SPR + 1;
                    DAR <= SPR + 2;
                    addr_reg <= SPR + 2;
                    cs_reg <= cs_reg;
                    we_reg <= 1;
                    op_2 <= op_2;
                    DVR <= DVR;
                    prev_op <= prev_op;
                /*end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    NS = SUB_POP_1;
                    prev_op = prev_op;
                end   */                   
            end
            SUB_POP_MID: begin
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
            end
            SUB_POP_2: begin
                //if (counter == 2) begin
                    counter <= 0;
                    op_2 <= data_in;
                    SPR <= SPR + 1;
                    DAR <= SPR + 2;
                    we_reg <= 0;
                    bus_reg <= data_in - op_1;
                    DVR <= data_in - op_1;
                    addr_reg <= SPR + 1;
                    //NS <= ADD_STORE_1;
                    prev_op <= prev_op;
                /*end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    NS = SUB_POP_2;
                    prev_op = prev_op;               
                end  */         
            end
            SUB_STORE_1: begin
                if (counter >= 1) begin
                    counter <= 0;
                    cs_reg <= 1;
                    we_reg <= 1;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    DVR <= DVR;                                   
                    prev_op <= prev_op;
                end else begin
                    counter <= counter + 1;
                    cs_reg <= cs_reg;
                    we_reg <= we_reg;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    DVR <= DVR;
                    prev_op <= prev_op;
                end
            end
            CLEAR    : begin
                SPR <= 7'h7f;
                DAR <= 7'h00;
                DVR <= 8'h00;
                cs_reg <= 1'b0;
                we_reg <= 1'b0;
                addr_reg <= 7'h00;
                bus_reg <= 8'h00;
                counter <= 2'b00;
                op_1 <= 8'h00;
                op_2 <= 8'h00;
                prev_op <= prev_op;           
            end
            TOP      :begin
                DAR <= SPR + 1;
                addr_reg <= SPR + 1;
                we_reg <= 1;
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR; 
                prev_op <= prev_op;           
            end
            TOP_READ:
                if (counter >= 1) begin
                    counter <= 0;
                    DVR <= data_in;
                    we_reg <= 0;
                    cs_reg <= cs_reg;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    prev_op <= prev_op;
                end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    prev_op = prev_op;
                end          
            DEC      :begin
                DAR <= DAR - 1;
                addr_reg <= DAR - 1;
                we_reg <= 1; 
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;           
            end
            DEC_READ:
                if (counter >= 1) begin
                    counter <= 0;
                    DVR <= data_in;
                    we_reg <= 0;
                    cs_reg <= cs_reg;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    prev_op <= prev_op;
                end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    prev_op = prev_op;
                end          
            INC      :begin
                DAR <= DAR + 1;
                addr_reg <= DAR + 1;
                we_reg <= 1; 
                cs_reg <= cs_reg;
                bus_reg <= bus_reg;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                prev_op <= prev_op;          
            end
            INC_READ :
                if (counter >= 1) begin
                    counter <= 0;
                    DVR <= data_in;
                    we_reg <= 0;
                    cs_reg <= cs_reg;
                    addr_reg <= addr_reg;
                    bus_reg <= bus_reg;
                    DAR <= DAR;
                    SPR <= SPR;
                    op_1 <= op_1;
                    op_2 <= op_2;
                    prev_op <= prev_op;
               end else begin
                    counter = counter + 1;
                    cs_reg = cs_reg;
                    we_reg = we_reg;
                    addr_reg = addr_reg;
                    bus_reg = bus_reg;
                    DAR = DAR;
                    SPR = SPR;
                    op_1 = op_1;
                    op_2 = op_2;
                    DVR = DVR;
                    prev_op = prev_op;
                end
            CLEAN    : begin
            
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;              
                /*if (prev_op != next_operation) 
                    NS <= START;
                else 
                    NS <= CLEAN;  */                               
            end    
            WAIT_ONE_CYCLE: begin
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
            end
            default: begin
                cs_reg <= cs_reg;
                we_reg <= we_reg;
                addr_reg <= addr_reg;
                bus_reg <= bus_reg;
                DAR <= DAR;
                SPR <= SPR;
                counter <= counter;
                op_1 <= op_1;
                op_2 <= op_2;
                DVR <= DVR;
                //NS <= START;
            end
        endcase 
    end
     
endmodule

