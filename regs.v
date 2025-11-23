module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output[7:0] data_read,
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

// ALL REGS HERE
reg[15:0] period_reg;           // 0x00, 0x01 - Period
reg counter_en_reg;             // 0x02 - Counter enable
reg[15:0] compare1_reg;         // 0x03, 0x04 - Compare value 1
reg[15:0] compare2_reg;         // 0x05, 0x06 - Compare value 2
reg counter_reset_reg;          // 0x07 - Counter reset (self-clearing)
// COUNTER_VAL at 0x08, 0x09 is read-only from counter_val input
reg[7:0] prescale_reg;          // 0x0A - Prescaler
reg upnotdown_reg;              // 0x0B - Count direction
reg pwm_en_reg;                 // 0x0C - PWM enable
reg[7:0] functions_reg;         // 0x0D - PWM functions


reg[15:0] period;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // reset la toti registrii
        period_reg <= 16'h0000;
        counter_en_reg <= 1'b0;
        compare1_reg <= 16'h0000;
        compare2_reg <= 16'h0000;
        counter_reset_reg <= 1'b0;
        prescale_reg <= 8'h00;
        upnotdown_reg <= 1'b0;
        pwm_en_reg <= 1'b0;
        functions_reg <= 8'h00;
    end
    else begin
        if(counter_reset_reg == 1'b1)begin
            counter_reset_reg <= 1'b0; // self-clearing bit
        end
        if(write) begin
            case(addr)
                6'h00: period_reg[7:0] <= data_write;         // LOW byte
                6'h01: period_reg[15:8] <= data_write;        // HIGH byte
                6'h02: counter_en_reg <= data_write[0];
                6'h03: compare1_reg[7:0] <= data_write;       // LOW byte
                6'h04: compare1_reg[15:8] <= data_write;      // HIGH byte
                6'h05: compare2_reg[7:0] <= data_write;       // LOW byte
                6'h06: compare2_reg[15:8] <= data_write;      // HIGH byte
                6'h07: counter_reset_reg <= data_write[0];
                6'h0A: prescale_reg <= data_write;
                6'h0B: upnotdown_reg <= data_write[0];
                6'h0C: pwm_en_reg <= data_write[0];
                6'h0D: functions_reg <= data_write;
                default: begin
                    // do nothing for undefined addresses
                end  
            endcase
        end
    end

end

always @(*) begin
    data_read = 8'h00; // default value
    if(read) begin
        case(addr)
            6'h00: data_read = period_reg[7:0];          // LOW byte
            6'h01: data_read = period_reg[15:8];         // HIGH byte
            6'h02: data_read = {7'b0, counter_en_reg};
            6'h03: data_read = compare1_reg[7:0];        // LOW byte
            6'h04: data_read = compare1_reg[15:8];       // HIGH byte
            6'h05: data_read = compare2_reg[7:0];        // LOW byte
            6'h06: data_read = compare2_reg[15:8];       // HIGH byte
            6'h08: data_read = counter_val[7:0];         // LOW byte
            6'h09: data_read = counter_val[15:8];        // HIGH byte
            6'h0A: data_read = prescale_reg;
            6'h0B: data_read = {7'b0, upnotdown_reg};
            6'h0C: data_read = {7'b0, pwm_en_reg};
            6'h0D: data_read = functions_reg;
            default: begin
                data_read = 8'h00; // undefined addresses return 0
            end  
        endcase
    end
end

assign period = period_reg;
assign en = counter_en_reg;
assign count_reset = counter_reset_reg;
assign upnotdown = upnotdown_reg;
assign prescale = prescale_reg;
assign pwm_en = pwm_en_reg;
assign functions = functions_reg;
assign compare1 = compare1_reg;
assign compare2 = compare2_reg;


endmodule