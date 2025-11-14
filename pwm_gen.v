module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output pwm_out
);

    reg pwm_out_reg;
    reg pwm_out_next;
    
    assign pwm_out = pwm_out_reg;

    reg [15:0] count_val_prev;

    wire is_overflow = (count_val_prev == period) && (count_val == 16'd0) && (period != 16'd0);
    wire is_underflow = (count_val_prev == 16'd0) && (count_val == period) && (period != 16'd0);
    wire cycle_start_event = is_overflow || is_underflow;

    wire compare1_event = (count_val == compare1);
    wire compare2_event = (count_val == compare2);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_val_prev <= 16'd0;
        end else begin
            count_val_prev <= count_val;
        end
    end

    always @(*) begin
        pwm_out_next = pwm_out_reg;

        if (pwm_en == 1'b1) begin
            
            if (cycle_start_event) begin
                case (functions[1:0])
                    2'b00: pwm_out_next = 1'b1;
                    2'b01: pwm_out_next = 1'b0;
                    default: pwm_out_next = 1'b0;
                endcase
            end
            else begin
                case (functions[1:0])
                    2'b00: begin
                        if (compare1_event) pwm_out_next = 1'b0;
                    end
                    2'b01: begin
                        if (compare1_event) pwm_out_next = 1'b1;
                    end
                    default: begin
                        if (compare1_event) pwm_out_next = 1'b1;
                        else if (compare2_event) pwm_out_next = 1'b0;
                    end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out_reg <= 1'b0;
        end else begin
            pwm_out_reg <= pwm_out_next;
        end
    end
    
endmodule