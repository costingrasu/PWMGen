module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,

    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output[7:0] data_out,
    // register access signals

    output read,
    output write,
    output[5:0] addr,
    input[7:0] data_read,
    output[7:0] data_write,

    //high_low
    output reg high_low
);
// Internal store
reg faza; // faza 0 = setup ; faza 1 = date
reg rw_bit; // 1 = write ; 0 = read
reg[5:0] saved_addr; // remembered address
reg hl_bit; // remembered high_low bit

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // cand se reseteaza
        faza <= 0;
        read <= 0;
        write <= 0;
        addr <= 6'h00;
        data_write <= 8'h00;
        data_out <= 8'h00;
        
        rw_bit <= 0;
        saved_addr <= 6'h00;
        hl_bit <= 0;
    end
    else if(byte_sync)begin
        if(faza == 0) begin
            // faza de setup

            rw_bit <= data_in[7];  // se salveaza r/w bit
            saved_addr <= data_in[5:0];  // se salveaza addr
            hl_bit <= data_in[6]; // se salveaza high_low bit
            faza <= 1; // urmatoarea faza va fi de date

            //clear outputs
            read <= 0;
            write <= 0;
        end
        else begin
            // faza de date
            if (hl_bit == 0)
                addr <= saved_addr;          // LOW byte
            else
                addr <= saved_addr + 6'd1;   // HIGH byte
            // se face operatia de read sau write
            if (rw_bit == 1) begin
                // WRITE operation
                write <= 1;
                data_write <= data_in;
                read <= 0;
            end
            else begin
                // READ operation
                read <= 1;
                data_out <= data_read;
                write <= 0;
            end
            faza <= 0; // urmatoarea faza va fi de setup
        end
    end
    else begin
        // byte_sync  e 0 ,clear ctrl signals
        read <= 0;
        write <= 0;
    end

end

endmodule