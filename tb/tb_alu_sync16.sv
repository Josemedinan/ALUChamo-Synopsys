`timescale 1ns/1ps

module tb_alu_sync16;

    reg clk = 0;
    always #5 clk = ~clk;

    reg rst_n;
    reg [15:0] a, b;
    reg [2:0] alu_control;

    wire [15:0] result;
    wire n, z, c, v, div_by_zero;

    wire [15:0] ref_result;
    wire ref_n, ref_z, ref_c, ref_v, ref_divzero;

    reg [20:0] expected_previous;
    reg valid_previous;

    integer tests, errors, op, i;

    alu_sync16 dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .n(n),
        .z(z),
        .c(c),
        .v(v),
        .div_by_zero(div_by_zero)
    );

    alu_core #(.WIDTH(16)) reference_core (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(ref_result),
        .n(ref_n),
        .z(ref_z),
        .c(ref_c),
        .v(ref_v),
        .div_by_zero(ref_divzero)
    );

    task automatic step(
        input reg [15:0] x,
        input reg [15:0] y,
        input reg [2:0] op_code
    );
        reg [20:0] sampled_expected;
        begin
            @(negedge clk);
            a = x;
            b = y;
            alu_control = op_code;

            #1;
            sampled_expected = {
                ref_result, ref_n, ref_z,
                ref_c, ref_v, ref_divzero
            };

            @(posedge clk);
            #1;

            if (valid_previous &&
                {result, n, z, c, v, div_by_zero}
                !== expected_previous) begin
                $display(
                    "SYNC16_FAIL CASE=%0d OP=%0d",
                    tests, op_code
                );
                errors = errors + 1;
            end

            expected_previous = sampled_expected;
            valid_previous = 1'b1;
            tests = tests + 1;
        end
    endtask

    initial begin
        rst_n = 0;
        a = 0;
        b = 0;
        alu_control = 0;
        expected_previous = 0;
        valid_previous = 0;
        tests = 0;
        errors = 0;

        repeat (2) @(negedge clk);

        if ({result, n, z, c, v, div_by_zero} !== 0)
            errors = errors + 1;

        rst_n = 1;

        for (op = 0; op < 8; op = op + 1) begin
            step(0, 0, op);
            step(16'hFFFF, 16'h0001, op);
            step(16'h8000, 16'h0001, op);
            step(16'hFFFF, 0, op);
            step(16'h7FFF, 16'h7FFF, op);

            for (i = 0; i < 500; i = i + 1)
                step($urandom, $urandom, op);
        end

        step(16'h1234, 16'h0003, 3'b101);

        if (errors != 0)
            $fatal(1, "SYNC16_FAILED ERRORS=%0d", errors);

        $display(
            "SYNC16_PASS TESTS=%0d ERRORS=0",
            tests
        );

        $finish;
    end

endmodule
