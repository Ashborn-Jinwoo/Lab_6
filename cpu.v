module cpu(clk, reset, s, load, in, out, N, V, Z, w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    // Internal signals
    wire [15:0] currentInstruction, sximm5, sximm8;
    wire [10:0] control_signal;
    wire [2:0] nsel, opcode, readnum, writenum;
    wire [1:0] op, ALUop, shift;

    // Load enable register for instruction 
    vDFFE #(16) vDFFE_instruction(.clk(clk), .en(load), .in(in), .out(currentInstruction));

    // Instruction decoder
    instruction_decoder decoder(.instruction(currentInstruction), .nsel(nsel), .opcode(opcode),
    .op(op), .ALUop(ALUop), .sximm5(sximm5), .sximm8(sximm8), .shift(shift),
    .readnum(readnum), .writenum(writenum));

    // Finite State Machine Controller
    FSM_controller controller(.clk(clk), .s(s), .reset(reset), .opcode(opcode), .op(op), .w(w), .nsel(nsel), .control(control_signal));

    // Datapath
    datapath DP(.clk(clk), .readnum(readnum), .vsel(control_signal[3:0]), .loada(control_signal[9]),
                .loadb(control_signal[8]), .shift(shift), .asel(control_signal[7]), .bsel(control_signal[6]),
                .ALUop(ALUop), .loadc(control_signal[4]), .loads(control_signal[5]), .sximm5(sximm5), .writenum(writenum),
                .write(control_signal[10]), .datapath_in(sximm8), .mdata({16{1'b0}}),
                .PC({8{1'b0}}), .status({Z, N, V}), .datapath_out(out));
endmodule