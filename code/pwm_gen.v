module pwm_gen (
    input clk,
    input rst_n,
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    output reg pwm_out
);

    reg pwm_logic_out;

    always @(*) begin
        pwm_logic_out = 1'b0;
        
        if (pwm_en) begin
            // daca valorile de comparare sunt egale fortam iesirea in 0
            if (compare1 == compare2) begin
                pwm_logic_out = 1'b0;
            end 
            else begin
                case (functions[1:0])
                    2'b00: begin 
                        // aliniere stanga: activ cat timp contorul este mai mic decat compare1
                        if ((count_val <= compare1) && (compare1 != 16'd0)) 
                            pwm_logic_out = 1'b1;
                    end

                    2'b01: begin 
                        // aliniere dreapta: activ cand contorul este mai mare decat compare1
                        if (count_val >= compare1)
                            pwm_logic_out = 1'b1;
                    end

                    2'b10: begin 
                        // interval: activ intre compare1 si compare2
                        if ((count_val >= compare1) && (count_val < compare2))
                            pwm_logic_out = 1'b1;
                    end
                    
                    default: pwm_logic_out = 1'b0;
                endcase
            end
        end
    end

    // registru de iesire pentru sincronizarea semnalului pwm cu ceasul
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            pwm_out <= 1'b0;
        else 
            pwm_out <= pwm_logic_out;
    end

endmodule