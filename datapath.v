module datapath (clk,
                // register operand fetch stage
                readnum,
                vsel, // Need to change this to 4 bits
                loada,
                loadb,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,
                sximm5, // New input for the b sel mux

                // set when "writing back" to register file
                writenum,
                write,  
                datapath_in,
                mdata, // New input for the v sel mux
                PC, // New input for the v sel mux

                // outputs
                status,
                datapath_out);
    input [15:0] datapath_in, sximm5, mdata; // New input for the vsel mux and bsel mux
    input [7:0] PC; // New input for vsel mux
    input [3:0] vsel; // Changed vsel to 4 bits
    input [2:0] writenum, readnum;
    input [1:0] ALUop, shift;
    input write, clk, loada, loadb, asel, bsel, loads, loadc;
    output [2:0] status;
    output [15:0] datapath_out;

    // Internal Signals
    wire [15:0] data_out, loada_out, loadb_out, sout, Ain, Bin, out;
    reg [15:0] data_in;
    wire zout, nout, oout;

    // Vector select mux
    always @(*) begin
        if (vsel[3] == 1'b1) begin
            data_in = mdata;
        end else if (vsel[2] == 1'b1) begin
            data_in = datapath_in;
        end else if (vsel[1] == 1'b1) begin
            data_in = {8'b0, PC};
        end else if (vsel[0] == 1'b1) begin
            data_in = datapath_out;
        end else begin
            data_in = {16{1'bx}};
        end
    end

    // Register File
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

    // Load enable A and B
    vDFFE #(16) load_a(clk, loada, data_out, loada_out);
    vDFFE #(16) load_b(clk, loadb, data_out, loadb_out);

    // Shifter for loadb
    shifter shift_op(loadb_out, shift, sout);

    // Mux for A select and B selet
    assign Ain = asel ? {16{1'b0}} : loada_out;
    assign Bin = bsel ? sximm5 : sout; // Modified bsel to have sximm5

    // ALU operation
    ALU alu_op(Ain, Bin, ALUop, out, zout, nout, oout);

    // Load enable registers
    vDFFE #(16) vDFFE_c(clk, loadc, out, datapath_out);
    vDFFE #(3) vDFFE_s(clk, loads, {zout, nout, oout}, status);
endmodule