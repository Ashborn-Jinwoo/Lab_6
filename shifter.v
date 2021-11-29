module shifter (in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    reg [15:0] sout;

    always @(*) begin
        if (shift == 2'b00) begin
            sout = in; // No shift
        end else if (shift == 2'b01) begin
            sout = {in[14:0], 1'b0}; // LSL
        end else if (shift == 2'b10) begin
            sout = {1'b0, in[15:1]}; // RSL
        end else if (shift == 2'b11) begin
            sout = {in[15], in[15:1]}; // RSL MSB is B[15]
        end else begin
            sout = {16{1'bx}};
        end
    end
endmodule