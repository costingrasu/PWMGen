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
    // registrul de stare curenta
    reg pwm_out_reg;
    // starea viitoare
    reg pwm_out_next;
    // conectam iesirea modulului la registrul de stare
    assign pwm_out = pwm_out_reg;
    // registru pentru a stoca valoarea count_val din ciclul de ceas anterior
    reg [15:0] count_val_prev;

    // in functie de daca valoarea counterului anterioara este period si curenta este 0 sau invers deducem daca este overflow sau underflow
    wire is_overflow = (count_val_prev == period) && (count_val == 16'd0) && (period != 16'd0);
    wire is_underflow = (count_val_prev == 16'd0) && (count_val == period) && (period != 16'd0);
    wire cycle_start_event = is_overflow || is_underflow;

    // evenimentele in care valoare counterului atinge unul din compare-uri
    wire compare1_event = (count_val == compare1);
    wire compare2_event = (count_val == compare2);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_val_prev <= 16'd0;
        end else begin
            // la fiecare ceas, salvam valoarea curenta pentru a o folosi in ciclul urmator
            count_val_prev <= count_val;
        end
    end

    always @(*) begin
        pwm_out_next = pwm_out_reg;

        // executam logica doar daca pwm-ul este activat
        if (pwm_en == 1'b1) begin
            
            // logica pentru inceputul unui nou ciclu
            if (cycle_start_event) begin
                case (functions[1:0])
                    2'b00: pwm_out_next = 1'b1; // aliniere stanga, cerinta: incepe pe 1
                    2'b01: pwm_out_next = 1'b0; // aliniere dreapta, cerinta: incepe pe 0
                    default: pwm_out_next = 1'b0; // mod nealiniat, cerinta: incepe pe 0
                endcase
            end
            else begin
                case (functions[1:0])
                    2'b00: begin // stanga
                        if (compare1_event) pwm_out_next = 1'b0; // a inceput pe 1, deci trece pe 0 la compare1
                    end
                    2'b01: begin // dreapta
                        if (compare1_event) pwm_out_next = 1'b1; // a inceput pe 0, deci trece pe 1 la compare1
                    end
                    default: begin // nealiniat
                        // incepe pe 0, trece pe 1 la compare1 si inapoi pe 0 la compare2
                        if (compare1_event) pwm_out_next = 1'b1;
                        else if (compare2_event) pwm_out_next = 1'b0;
                    end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // la reset, iesirea este 0
            pwm_out_reg <= 1'b0;
        end else begin
            // la fiecare ceas, starea curenta este actualizata cu starea viitoare calculata
            pwm_out_reg <= pwm_out_next;
        end
    end
    
endmodule