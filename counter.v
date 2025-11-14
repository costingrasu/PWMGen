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
    // contor intern care numara ciclurile de clk
    reg [15:0] prescale_counter;
    // valoarea tinta pe care prescale_counter trebuie sa o atinga(2^prescale)
    wire [15:0] prescale_target;
    // puls de 1 ciclu clk generat cand prescaler-ul termina de numarat (enable pentru contorul principal)
    wire prescale_tick;

    // calculam 2^prescale folosind un shift la stanga
    assign prescale_target = (16'd1 << prescale);
    
    // generam tick-ul doar daca contorul este pornit (en == 1) si contorul intern a atins valoarea tinta - 1 (numara de la 0 la tinta-1)
    assign prescale_tick = (en == 1'b1) && (prescale_counter == (prescale_target - 1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescale_counter <= 16'd0;
        end 
        //asigura ca un nou ciclu de prescale incepe mereu de la 0 daca modulul e oprit (en=0) sau daca primeste reset sincron
        else if (en == 1'b0 || count_reset == 1'b1) begin
            prescale_counter <= 16'd0;
        end 
        else begin
            // daca am atins tinta resetam la 0, altfel incrementam
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
        // reset sincron
        else if (count_reset == 1'b1) begin
            count_val <= 16'd0;
        end 
        // actualizam count_val doar daca am primit un prescale_tick
        // daca prescale_tick e 0, count_val isi pastreaza valoarea
        else if (prescale_tick == 1'b1) begin
            if (upnotdown == 1'b1) begin
                // crescator
                if (count_val == period) begin
                    count_val <= 16'd0;
                end else begin
                    count_val <= count_val + 1;
                end
            end 
            else begin
                // descrescator
                if (count_val == 16'd0) begin
                    count_val <= period;
                end else begin
                    count_val <= count_val - 1;
                end
            end
        end
    end

endmodule
