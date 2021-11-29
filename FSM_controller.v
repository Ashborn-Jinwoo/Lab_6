module FSM_controller(clk, s, reset, opcode, op, w, nsel, control);
    input clk;
    input s, reset;
    input [1:0] op;
    input [2:0] opcode;
    output w;
    reg w;
    output [2:0] nsel;
    reg [2:0] nsel;
    output [10:0] control;

    // States encoding
    `define wait        9'b000_000_001
    `define decode      9'b000_000_010
    `define writeImm    9'b000_000_100
    `define getA        9'b000_001_000
    `define getB        9'b000_010_000
    `define shift       9'b000_100_000
    `define execute     9'b001_000_000
    `define writeReg    9'b010_000_000
    `define writeStatus 9'b100_000_000

    // Decoding Signals
    `define MOV_IMM 5'b110_10
    `define MOV_SHIFT 5'b110_00
    `define ADD 5'b101_00
    `define CMP 5'b101_01
    `define AND 5'b101_10
    `define MVN 5'b101_11

    //Internal Signals
    reg write, loada, loadb, asel, bsel, loads, loadc;
    reg [3:0] vsel;
    reg [8:0] next_state, present_state;

    // Assigning the control signal output
    assign control = {write, loada, loadb, asel, bsel, loads, loadc, vsel};

    // Finite state machine time
    always @(posedge clk) begin
        present_state = reset ? `wait : next_state;
    end

    always @(*) begin
        {write, loada, loadb, asel, bsel, loads, loadc, vsel} = {11{1'b0}};
        nsel = 3'b000;
        w = 1'b0;
        case(present_state)
            `wait: if(s == 1'b1) begin
                    next_state = `decode;
                    w = 1'b1;
                end else begin
                    next_state = `wait;
                    w = 1'b1;
                end
            `decode: if({opcode, op} == `MOV_IMM) begin
                    next_state = `writeImm;
                end else if ({opcode, op} == `MOV_SHIFT || {opcode, op} == `MVN) begin
                    next_state = `getB;
                end else if ({opcode, op} == `ADD || {opcode, op} == `CMP || {opcode, op} == `AND) begin
                    next_state = `getA;
                end else begin
                    next_state = `wait;
                end
            `writeImm: begin
                    next_state = `wait;
                    nsel = 3'b100;
                    write = 1'b1;
                    vsel = 4'b0100;
                end
            `getA: begin
                    next_state = `getB;
                    nsel = 3'b100;
                    loada = 1'b1;
                end
            `getB: begin
                    if ({opcode, op} == `MOV_SHIFT || {opcode, op} == `MVN) begin
                        next_state = `shift;
                    end else begin
                        next_state = `execute;
                    end
                    nsel = 3'b001;
                    loadb = 1'b1;
                end
            `execute: begin
                    if ({opcode, op} == `CMP) begin
                        next_state = `writeStatus;
                        loadc= 1'b0;
                    end else begin
                        next_state = `writeReg;
                        loadc= 1'b1;
                    end
                    asel = 1'b0;
                    bsel = 1'b0;
                end
            `shift: begin
                    next_state = `writeReg;
                    asel = 1'b1;
                    bsel = 1'b0;
                    loadc = 1'b1;
                end
            `writeReg: begin
                    next_state = `wait;
                    nsel = 3'b010;
                    vsel = 4'b0001;
                    write = 1'b1;
                end
            `writeStatus: begin
                    next_state = `wait;
                    loads = 1'b1;
                end
        endcase
    end
endmodule