module spi_bridge (
    input clk,
    input rst_n,
    input sclk,
    input cs_n,
    
    input miso,      
    output reg mosi, 

    output reg byte_sync,
    output reg[7:0] data_in,
    input [7:0] data_out
);

    reg[7:0] r_master;
    reg[7:0] r_slave;
    reg[2:0] counter;

    // logica de receptie slave pe frontul pozitiv al sclk
    always@(posedge sclk or negedge rst_n) begin
        if (rst_n == 0) begin
            counter <= 3'b000;
            byte_sync <= 1'b0;
            r_slave <= 8'b0;
            data_in <= 8'b0;
        end else if (cs_n == 0) begin
            counter <= counter + 1'b1;
            // shiftam datele primite in registrul slave
            r_slave <= {r_slave[6:0], miso}; 
            if (counter == 3'b111) begin
                // transferam octetul complet in data_in si generam sync
                data_in <= {r_slave[6:0], miso};
                byte_sync <= 1'b1;
            end else begin
                byte_sync <= 1'b0;
            end
        end else begin
            counter <= 3'b000;
            byte_sync <= 1'b0;
        end
    end

    // logica de transmisie master pe frontul negativ al sclk
    always@(negedge sclk or negedge rst_n) begin
        if (rst_n == 0) begin
            mosi <= 1'b0;
            r_master <= 8'b0;
        end else if (cs_n == 0) begin
            // incarcam noul octet de date imediat dupa semnalul byte_sync
            if (byte_sync) begin
                mosi <= data_out[7];
                r_master <= {data_out[6:0], 1'b0};
            end else begin
                // shiftam datele catre iesirea mosi
                mosi <= r_master[7];
                r_master <= {r_master[6:0], 1'b0};
            end
        end else begin 
            mosi <= 1'b0;
            // pregatim datele initiale
            r_master <= data_out; 
        end
    end
endmodule