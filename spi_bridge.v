module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk, //ceasul folosit de master pt sincronizare transfer
    //cpol = 0, cpha = 0 => scris pe front descrescator, citit pe crescator
    input cs_n, // = 0 se activeaza transfer de date
    input  mosi,  //master scrie slave citeste 
    output reg miso, //master citeste slave scrie

    // internal facing 
    output reg byte_sync, //semnal de control
    output reg[7:0] data_in,  //pt decodor input,
    input [7:0] data_out  //primit de la decodor

);
                        //
//ca logica ma gandesc in felul urmator
// master si slave functioneaza fieecare pe shiftare dintr un registru in altu
//master pe frontul descrescator pune bit ul pe linie
//slave citeste pe front crescator bitu
// la fiecare front crescator sclk , cat timp cs_n este 0, mosi este shiftat in slave,
//se trimite mai intai msb deci avem shiftare stanga, bitul nou intra in lsb
//in final lsb e msb practic
//dupa 8 cicluri registru final adica data_in contine de la master
//data out este primit de la decodor si pus in master

 //vom pune si registrii pentru master si pt slave
 reg[7:0] r_master;
 reg[7:0] r_slave;
 reg[2:0] counter; //facem un counter care creste pe masura 
 // ce se face cate o shiftare, cand ajunge la 7 setam cs pe 1 si punem in data_in
 // registru din master

//rst_ne activ pe 0 si inactiv pe 1

//deci pe front activ, slave citeste
always@(posedge sclk or negedge rst_n) begin
    if (rst_n == 0) begin
        counter <= 3'b000;
        byte_sync <= 1'b0;
        r_slave <= 8'b0;
        data_in <= 8'b0;
    end else if (cs_n == 0) begin
        counter <= counter + 1'b1;
        //ex am slave = [a b c d e f g h]
            // devine [b c d e f g h mosi]
        r_slave <= {r_slave[6:0], mosi};

        if (counter == 3'b111) begin
            data_in <= {r_slave[6:0], mosi};
            byte_sync <= 1'b1;
        end else begin
            byte_sync <= 1'b0;
        end
    end else begin  //cs_n e 1 
        counter <= 3'b000;
        byte_sync <= 1'b0;
    end
        
end

always@(negedge sclk or negedge rst_n) begin
    if (rst_n == 0) begin
        miso <= 1'b0;
        r_master <= 8'b0;
    end else if (cs_n == 0) begin
        miso <= r_master[7];
        r_master <= {r_master[6:0], 1'b0};
    end else begin 
        miso <= 1'b0;
        r_master <= data_out;
    end
    
end

endmodule