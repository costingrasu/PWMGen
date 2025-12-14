module regs (
    // semnale de ceas si reset
    input clk,
    input rst_n,
    // semnale interfata decodor
    input read,
    input write,
    input[5:0] addr,
    output [7:0] data_read,
    input[7:0] data_write,
    // semnale programare contor
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // semnale programare pwm
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

    // definire registri interni
    reg[15:0] period_reg;           // 0x00, 0x01 - perioada semnalului
    reg counter_en_reg;             // 0x02 - activare contor
    reg[15:0] compare1_reg;         // 0x03, 0x04 - prima valoare de comparare
    reg[15:0] compare2_reg;         // 0x05, 0x06 - a doua valoare de comparare
    reg counter_reset_reg;          // 0x07 - resetare contor (se sterge automat)
    
    // counter_val la 0x08, 0x09 este read-only si vine din intrarea counter_val
    
    reg[7:0] prescale_reg;          // 0x0A - divizor de frecventa
    reg upnotdown_reg;              // 0x0B - directie numarare (1=up, 0=down)
    reg pwm_en_reg;                 // 0x0C - activare iesire pwm
    reg[7:0] functions_reg;         // 0x0D - configurare mod functionare pwm

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            // la reset punem toti registrii pe 0
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
            // logica pentru bitul de reset care se sterge singur dupa un ciclu
            if(counter_reset_reg == 1'b1)begin
                counter_reset_reg <= 1'b0;
            end
            
            // logica de scriere in registri
            if(write) begin
                case(addr)
                    6'h00: period_reg[7:0] <= data_write;       // octetul inferior perioada
                    6'h01: period_reg[15:8] <= data_write;      // octetul superior perioada
                    6'h02: counter_en_reg <= data_write[0];     // activare contor
                    6'h03: compare1_reg[7:0] <= data_write;     // octetul inferior compare1
                    6'h04: compare1_reg[15:8] <= data_write;    // octetul superior compare1
                    6'h05: compare2_reg[7:0] <= data_write;     // octetul inferior compare2
                    6'h06: compare2_reg[15:8] <= data_write;    // octetul superior compare2
                    6'h07: counter_reset_reg <= data_write[0];  // comanda reset contor
                    6'h0A: prescale_reg <= data_write;          // valoare prescaler
                    6'h0B: upnotdown_reg <= data_write[0];      // directie
                    6'h0C: pwm_en_reg <= data_write[0];         // activare pwm
                    6'h0D: functions_reg <= data_write;         // functii pwm
                    default: begin
                        // nu facem nimic pentru adrese invalide
                    end  
                endcase
            end
        end
    end

    // multiplexor pentru citirea datelor din registri
    // selecteaza valoarea corecta pe baza adresei cand semnalul read este activ
    assign data_read =
        (!read) ? 8'h00 :
        (addr == 6'h00) ? period_reg[7:0] :
        (addr == 6'h01) ? period_reg[15:8] :
        (addr == 6'h02) ? {7'b0, counter_en_reg} :
        (addr == 6'h03) ? compare1_reg[7:0] :
        (addr == 6'h04) ? compare1_reg[15:8] :
        (addr == 6'h05) ? compare2_reg[7:0] :
        (addr == 6'h06) ? compare2_reg[15:8] :
        (addr == 6'h08) ? counter_val[7:0] :      // citire valoare curenta contor low
        (addr == 6'h09) ? counter_val[15:8] :     // citire valoare curenta contor high
        (addr == 6'h0A) ? prescale_reg :
        (addr == 6'h0B) ? {7'b0, upnotdown_reg} :
        (addr == 6'h0C) ? {7'b0, pwm_en_reg} :
        (addr == 6'h0D) ? functions_reg :
        8'h00;

    // conectare registri interni la iesirile modulului
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