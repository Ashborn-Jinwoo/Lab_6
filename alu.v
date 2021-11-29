module ALU(Ain, Bin, ALUop, out, Z, N, O);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    reg [15:0] out;
    output Z, N, O;
    reg Z, N, O;

    `define ADD_S 2'b00
    `define CMP_S 2'b01
    `define AND_S 2'b10
    `define MVN_S 2'b11

    //First git hub push test

    // second commit test


    // Determining which operation we are to perform
    // and it's corresponding output
    always @(*) begin
        {Z, N, O} = 3'b000;
        if (ALUop == `ADD_S) begin
            out = Ain + Bin;
        end else if (ALUop == `CMP_S) begin
            out = Ain - Bin;
            Z = (out == 16'd0) ? 1'b1 : 1'b0;
            N = (out[15] == 1'b1) ? 1'b1 : 1'b0;
            O = (out [15] != out[7]) ? 1'b1 : 1'b0;
        end else if (ALUop == `AND_S) begin
            out = Ain & Bin;
        end else if (ALUop == `MVN_S) begin
            out = ~Bin;
        end else begin
            out = {16{1'bx}};
        end
    end

endmodule