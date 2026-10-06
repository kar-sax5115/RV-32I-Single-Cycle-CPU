`timescale 1ns / 1ps

// Testbench for the single-cycle RISC-V CPU (top.v)
// Files read at time 0 (add them as Simulation Sources in Vivado):
//   program.mem : instructions, one 32-bit hex word per line (word 0 = address 0x0)
//   data.mem    : initial data memory, one 32-bit hex word per line
//   target.mem  : expected data memory after the program finishes
// Optional (see check_RB below):
//   target_reg.mem : expected register file, 32 words (x0..x31)

module tb_top;

    parameter IM_WORDS = 1024;   // must match inst_reg.v
    parameter DM_WORDS = 1024;   // must match DataMem.v
    parameter CHECK_WORDS = 1024;  // how many data words to compare against target.mem
    parameter RUN_NS = 5000;     // 500 clock cycles at a 10 ns period

    reg clk, rst;

    top uut (.clk(clk), .rst(rst));

    // Handy signals to watch in the waveform
    wire [31:0] PCOut  = uut.pc;
    wire [31:0] Instr  = uut.instr;
    wire        PCjump = uut.pc_funct;

    initial begin
        clk = 0;
        rst = 1;
    end

    always #5 clk = ~clk;

    // The memories and registers have no reset, so clear them first
    // (otherwise unused locations stay X).
    task clear_all;
        integer i;
        begin
            for (i = 0; i < IM_WORDS; i = i + 1) uut.inst_reg_mod.mem[i] = 32'd0;
            for (i = 0; i < DM_WORDS; i = i + 1) uut.datamem_mod.mem[i]  = 32'd0;
            for (i = 0; i < 32;       i = i + 1) uut.reg_mod.register[i] = 32'd0;
        end
    endtask

    task write_program;
        reg [31:0] prog [0:IM_WORDS-1];
        integer i;
        begin
            for (i = 0; i < IM_WORDS; i = i + 1) prog[i] = 32'd0;
            $readmemh("program.mem", prog);
            for (i = 0; i < IM_WORDS; i = i + 1)
                uut.inst_reg_mod.mem[i] = prog[i];
        end
    endtask

    task write_data;
        reg [31:0] data [0:DM_WORDS-1];
        integer i;
        begin
            for (i = 0; i < DM_WORDS; i = i + 1) data[i] = 32'd0;
            $readmemh("data.mem", data);
            for (i = 0; i < DM_WORDS; i = i + 1)
                uut.datamem_mod.mem[i] = data[i];
        end
    endtask

    task reset_PC_RB;
        begin
            @(negedge clk) rst = 1;
            repeat (2) @(negedge clk);
        end
    endtask

    task drop_reset_PC_RB;
        begin
            @(negedge clk) rst = 0;
        end
    endtask

    // Optional: compare the register file with target_reg.mem.
    // To use it, add a target_reg.mem file and call check_RB() before $finish.
    task check_RB;
        reg [31:0] target [0:31];
        integer i, pass, fail;
        begin
            pass = 0;
            fail = 0;
            for (i = 0; i < 32; i = i + 1) target[i] = 32'd0;
            $readmemh("target_reg.mem", target);
            for (i = 0; i < 32; i = i + 1) begin
                if (uut.reg_mod.register[i] === target[i]) begin
                    $display("PASS x%0d = %h       |       Expected = %h", i, uut.reg_mod.register[i], target[i]);
                    pass = pass + 1;
                end else begin
                    $display("FAIL x%0d = %h       |       Expected = %h", i, uut.reg_mod.register[i], target[i]);
                    fail = fail + 1;
                end
            end
            $display("======================================================");
            $display("REGISTERS:  PASS = %0d                  |       FAIL = %0d", pass, fail);
            $display("======================================================");
        end
    endtask

    // Compare data memory with target.mem (=== so an X counts as a failure)
    task check_DM;
        reg [31:0] target [0:CHECK_WORDS-1];
        integer i, pass, fail;
        begin
            pass = 0;
            fail = 0;
            for (i = 0; i < CHECK_WORDS; i = i + 1) target[i] = 32'd0;
            $readmemh("target.mem", target);
            for (i = 0; i < CHECK_WORDS; i = i + 1) begin
                if (uut.datamem_mod.mem[i] === target[i]) begin
                    $display("PASS WA%0d = %h       |       Expected = %h", i, uut.datamem_mod.mem[i], target[i]);
                    pass = pass + 1;
                end else begin
                    $display("FAIL WA%0d = %h       |       Expected = %h", i, uut.datamem_mod.mem[i], target[i]);
                    fail = fail + 1;
                end
            end
            $display("======================================================");
            $display("DATA MEM:  PASS = %0d                  |       FAIL = %0d", pass, fail);
            $display("======================================================");
        end
    endtask

    initial begin
        clear_all();
        write_data();
        write_program();      // LIGHTS!
        reset_PC_RB();        // CAMERA!!
        drop_reset_PC_RB();   // ACTION!!!
        #(RUN_NS);
        check_DM();
        // check_RB();        // uncomment if you have target_reg.mem
        $finish;
    end

endmodule