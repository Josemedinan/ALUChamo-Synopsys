`timescale 1ns/1ps

module tb_alu_core #(
    parameter integer WIDTH = 8
);

    reg [WIDTH-1:0] a, b;
    reg [2:0] alu_control;

    wire [WIDTH-1:0] result;
    wire n, z, c, v, div_by_zero;

    reg [WIDTH-1:0] expected_result;
    reg expected_c, expected_v, expected_divzero;
    reg [WIDTH:0] extended;

    integer tests, errors, i, op;

    alu_core #(.WIDTH(WIDTH)) dut (
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

    task automatic check_case(
        input reg [WIDTH-1:0] x,
        input reg [WIDTH-1:0] y,
        input reg [2:0] control
    );
        begin
            a = x;
            b = y;
            alu_control = control;

            expected_result = 0;
            expected_c = 0;
            expected_v = 0;
            expected_divzero = 0;
            extended = 0;

            case (control)
                3'b000: begin
                    extended = {1'b0,x} + {1'b0,y};
                    expected_result = extended[WIDTH-1:0];
                    expected_c = extended[WIDTH];
                    expected_v =
                        (~(x[WIDTH-1] ^ y[WIDTH-1])) &
                        (x[WIDTH-1] ^ expected_result[WIDTH-1]);
                end

                3'b001: begin
                    extended = {1'b0,x} + {1'b0,~y} + 1'b1;
                    expected_result = extended[WIDTH-1:0];
                    expected_c = extended[WIDTH];
                    expected_v =
                        (x[WIDTH-1] ^ y[WIDTH-1]) &
                        (x[WIDTH-1] ^ expected_result[WIDTH-1]);
                end

                3'b010: expected_result = x & y;
                3'b011: expected_result = x | y;
                3'b100: expected_result = 0;

                3'b101: begin
                    expected_divzero = (y == 0);
                    expected_result = (y == 0) ? 0 : x / y;
                end

                3'b110: begin
                    expected_divzero = (y == 0);
                    expected_result = (y == 0) ? 0 : x % y;
                end

                3'b111: expected_result = 0;
            endcase

            #1;

            if (result !== expected_result ||
                n !== expected_result[WIDTH-1] ||
                z !== (expected_result == 0) ||
                c !== expected_c ||
                v !== expected_v ||
                div_by_zero !== expected_divzero) begin

                $display(
                    "FAIL WIDTH=%0d CASE=%0d OP=%0d",
                    WIDTH, tests, control
                );
                errors = errors + 1;
            end

            tests = tests + 1;
        end
    endtask

    initial begin
        tests = 0;
        errors = 0;
        a = 0;
        b = 0;
        alu_control = 0;

        for (op = 0; op < 8; op = op + 1) begin
            check_case(0, 0, op);
            check_case(1, 1, op);
            check_case({WIDTH{1'b1}}, 1, op);
            check_case({WIDTH{1'b1}}, 0, op);
            check_case({WIDTH{1'b1}}, {WIDTH{1'b1}}, op);
            check_case({1'b1, {(WIDTH-1){1'b0}}}, 1, op);

            for (i = 0; i < 3000; i = i + 1)
                check_case($urandom, $urandom, op);
        end

        if (errors != 0)
            $fatal(1, "ALU_CORE_FAILED WIDTH=%0d ERRORS=%0d",
                   WIDTH, errors);

        $display(
            "ALU_CORE_PASS WIDTH=%0d TESTS=%0d ERRORS=0",
            WIDTH, tests
        );

        $finish;
    end

endmodule
