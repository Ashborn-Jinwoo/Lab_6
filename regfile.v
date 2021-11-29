module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    reg [15:0] data_out;

    wire [7:0] onehot_writenum, onehot_readnum, load_enable;
    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

    // 3 to 8 decoder for the top and bottom decoder
    three_to_eight_decoder top(writenum, onehot_writenum);
    three_to_eight_decoder bot(readnum, onehot_readnum);
    
    // Bitwise and between 1 hot representation of write num and write
    assign load_enable = onehot_writenum & {8{write}};

    // Determining the values for register 0 to 7
    vDFFE #(16) R0_out(clk, load_enable[0], data_in, R0);
    vDFFE #(16) R1_out(clk, load_enable[1], data_in, R1);
    vDFFE #(16) R2_out(clk, load_enable[2], data_in, R2);
    vDFFE #(16) R3_out(clk, load_enable[3], data_in, R3);
    vDFFE #(16) R4_out(clk, load_enable[4], data_in, R4);
    vDFFE #(16) R5_out(clk, load_enable[5], data_in, R5);
    vDFFE #(16) R6_out(clk, load_enable[6], data_in, R6);
    vDFFE #(16) R7_out(clk, load_enable[7], data_in, R7);

    // Multiplexer to determing which register is to be read
    always @(*) begin
        if (onehot_readnum[0] == 1'b1) begin
            data_out = R0;
        end else if (onehot_readnum[1] == 1'b1) begin
            data_out = R1;          
        end else if (onehot_readnum[2] == 1'b1) begin
            data_out = R2;
        end else if (onehot_readnum[3] == 1'b1) begin
            data_out = R3;
        end else if (onehot_readnum[4] == 1'b1) begin
            data_out = R4;
        end else if (onehot_readnum[5] == 1'b1) begin
            data_out = R5;
        end else if (onehot_readnum[6] == 1'b1) begin
            data_out = R6;
        end else if (onehot_readnum[7] == 1'b1) begin
            data_out = R7;
        end else begin
            data_out = {16{1'bx}};
        end
    end
endmodule

module three_to_eight_decoder(in, out);
    input [2:0] in;
    output [7:0] out;
    reg [7:0] out;

    always @(*) begin
        if (in == 3'b000) begin
            out = 8'b0000001;
        end else if (in == 3'b001) begin
            out = 8'b00000010;
        end else if (in == 3'b010) begin
            out = 8'b00000100;
        end else if (in == 3'b011) begin
            out = 8'b00001000;
        end else if (in == 3'b100) begin
            out = 8'b00010000;
        end else if (in == 3'b101) begin
            out = 8'b00100000;
        end else if (in == 3'b110) begin
            out = 8'b01000000;
        end else if (in == 3'b111) begin
            out = 8'b10000000;
        end else begin
            out = 8'bxxxxxxxx;
        end
    end
endmodule

module vDFFE(clk, en, in, out);
    parameter n = 1; // Width
    input clk, en;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    wire [n-1:0] next_out;

    assign next_out = en ? in: out;

    always @(posedge clk) begin
        out = next_out;
    end
endmodule