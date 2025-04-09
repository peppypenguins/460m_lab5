`timescale 1ns / 1ps

module debounce2(
    input clk,    
    input reset, 
    input button, 
    output reg out
);

    parameter DEBOUNCE_TIME = 20'd1000000; 

    reg [19:0] counter; 
    reg button_sync_1 = 1'b0, button_sync_2 = 1'b0; 

    always @(posedge clk) begin
            button_sync_1 <= button;
            button_sync_2 <= button_sync_1;
    end

always @(posedge clk) begin
    if (button_sync_2 == button_sync_1) begin
        if (counter < DEBOUNCE_TIME)
            counter <= counter + 1;
        else begin
            counter <= 0;
            out <= button_sync_2; // Update the output only after debounce time
        end
    end else begin
        counter <= 0;  // Reset counter when there is a state change
    end
end
    
    
endmodule

