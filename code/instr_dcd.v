module instr_dcd (
    input clk,
    input rst_n,
    input byte_sync,
    input[7:0] data_in,
    
    output reg [7:0] data_out,
    output reg read,
    output reg write,
    output reg [5:0] addr,
    input [7:0] data_read,
    output reg [7:0] data_write,

    output reg high_low
);
    
    reg faza; 
    reg rw_bit; 
    reg[5:0] saved_addr; 
    reg hl_bit; 

    // registre pentru sincronizarea semnalului byte_sync
    reg byte_sync_d1;
    reg byte_sync_d2;
    wire byte_sync_clk;

    // detectare front pozitiv pentru byte_sync
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_sync_d1 <= 1'b0;
            byte_sync_d2 <= 1'b0;
        end else begin
            byte_sync_d1 <= byte_sync;
            byte_sync_d2 <= byte_sync_d1;
        end
    end
    assign byte_sync_clk = byte_sync_d1 & ~byte_sync_d2;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            faza <= 0;
            read <= 0;
            write <= 0;
            addr <= 6'h00;
            data_write <= 8'h00;
            data_out <= 8'h00;
            rw_bit <= 0;
            saved_addr <= 6'h00;
            hl_bit <= 0;
            high_low <= 0;
        end
        else if(byte_sync_clk) begin
            if(faza == 0) begin
                // faza de setup: salvam bitul de read/write si adresa
                rw_bit <= data_in[7];
                saved_addr <= data_in[5:0];
                hl_bit <= data_in[6];
                faza <= 1;

                write <= 0;
                
                // daca este operatie de citire activam semnalul read anticipat
                // pentru a avea datele disponibile in ciclul urmator
                if (data_in[7] == 1'b0) begin 
                    read <= 1'b1; 
                    addr <= data_in[5:0];
                end else begin
                    read <= 0;
                end
            end
            else begin
                // faza de date: folosim adresa salvata pentru a accesa registrul
                addr <= saved_addr;

                if (rw_bit == 1) begin
                    // operatie de scriere
                    write <= 1;
                    data_write <= data_in;
                    read <= 0;
                end
                else begin
                    // operatie de citire
                    read <= 1; 
                    data_out <= data_read;
                    write <= 0;
                end
                // revenim la faza de setup pentru urmatoarea tranzactie
                faza <= 0;
            end
        end
        else begin
            // resetam semnalele de control cand nu avem byte_sync
            read <= 0;
            write <= 0;
        end
    end
endmodule