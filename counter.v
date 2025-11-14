module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output reg [15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);
    
    reg [15:0] prescale_counter;
    wire [15:0] prescale_target;
    wire prescale_tick;

    assign prescale_target = (16'd1 << prescale);
    
    assign prescale_tick = (en == 1'b1) && (prescale_counter == (prescale_target - 1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescale_counter <= 16'd0;
        end 
        else if (en == 1'b0 || count_reset == 1'b1) begin
            prescale_counter <= 16'd0;
        end 
        else begin
            if (prescale_counter == (prescale_target - 1)) begin
                prescale_counter <= 16'd0;
            end else begin
                prescale_counter <= prescale_counter + 1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_val <= 16'd0;
        end 
        else if (count_reset == 1'b1) begin
            count_val <= 16'd0;
        end 
        else if (prescale_tick == 1'b1) begin
            if (upnotdown == 1'b1) begin
                if (count_val == period) begin
                    count_val <= 16'd0;
                end else begin
                    count_val <= count_val + 1;
                end
            end 
            else begin
                if (count_val == 16'd0) begin
                    count_val <= period;
                end else begin
                    count_val <= count_val - 1;
                end
            end
        end
    end

endmodule
