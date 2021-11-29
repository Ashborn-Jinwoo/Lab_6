module instruction_decoder(instruction, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] instruction;
    input [2:0] nsel; // 1 hot
    output [15:0] sximm5, sximm8;
    output [2:0] opcode, readnum, writenum;
    output [1:0] op, ALUop, shift;

    // Making regs
    reg[2:0] readnum, writenum;

    // Wires for local variables
    wire [2:0] Rn = instruction[10:8];
    wire [2:0] Rd = instruction[7:5];
    wire [2:0] Rm = instruction[2:0];

    // Outputs to controller FSM
    assign opcode = instruction[15:13];
    assign op = instruction [12:11];

    //Outputs to Datapath
    assign ALUop = instruction[12:11];
    assign shift = instruction[4:3];

    // Mux outputs to datapath
    always @(*) begin
        if (nsel[2] == 1'b1) begin
            readnum = Rn;
            writenum = Rn;
        end else if (nsel[1] == 1'b1) begin
            readnum = Rd;
            writenum = Rd;
        end else if (nsel[0] == 1'b1) begin
            readnum = Rm;
            writenum = Rm;
        end else begin
            readnum = 3'bxxx;
            writenum = 3'bxxx;
        end
    end

    // Sign extending the imm5 and imm8
    assign sximm5 = instruction[4] ? {{11{1'b1}}, instruction[4:0]} : {{11{1'b0}}, instruction[4:0]};
    assign sximm8 = instruction[7] ? {{8{1'b1}}, instruction[7:0]} : {{8{1'b0}}, instruction[7:0]};

endmodule