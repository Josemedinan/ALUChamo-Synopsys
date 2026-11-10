`timescale 1ns/1ps
module tb_alu_arithmetic #(
    parameter integer WIDTH = 8
);

    reg  [WIDTH-1:0] a, b;
    reg              cin;

    wire [WIDTH-1:0] sum;
    wire             cout;
    wire [WIDTH-1:0] quotient, remainder;
    wire             div_by_zero;

    reg [WIDTH:0] expected_sum;
    reg [WIDTH-1:0] expected_q, expected_r;

    integer tests, errors, i;

    alu_cla #(.WIDTH(WIDTH)) u_cla (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    alu_divider #(.WIDTH(WIDTH)) u_divider (
        .dividend(a),
        .divisor(b),
        .quotient(quotient),
        .remainder(remainder),
        .div_by_zero(div_by_zero)
    );

    task automatic check_case(
        input reg [WIDTH-1:0] x,
        input reg [WIDTH-1:0] y,
        input reg carry
    );
        begin
            a = x;
            b = y;
            cin = carry;

            #1;

            expected_sum = {1'b0, x} + {1'b0, y} + carry;

            if ({cout, sum} !== expected_sum) begin
                $display("FAIL CLA WIDTH=%0d TEST=%0d", WIDTH, tests);
                errors = errors + 1;
            end

            if (y == 0) begin
                expected_q = 0;
                expected_r = 0;
            end else begin
                expected_q = x / y;
                expected_r = x % y;
            end

            if (quotient !== expected_q ||
                remainder !== expected_r ||
                div_by_zero !== (y == 0)) begin

                $display("FAIL DIV WIDTH=%0d TEST=%0d", WIDTH, tests);
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
        cin = 0;

        check_case(0, 0, 0);
        check_case(0, 0, 1);
        check_case(1, 1, 0);
        check_case(1, 1, 1);
        check_case({WIDTH{1'b1}}, 1, 0);
        check_case({WIDTH{1'b1}}, 1, 1);
        check_case({WIDTH{1'b1}}, {WIDTH{1'b1}}, 0);
        check_case({WIDTH{1'b1}}, {WIDTH{1'b1}}, 1);
        check_case({WIDTH{1'b1}}, 0, 0);
        check_case(0, {WIDTH{1'b1}}, 1);

        for (i = 0; i < 2000; i = i + 1) begin
            check_case($urandom, $urandom, $urandom_range(0, 1));
        end

        if (errors != 0) begin
            $fatal(1,
                "FAIL WIDTH=%0d TESTS=%0d ERRORS=%0d",
                WIDTH, tests, errors
            );
        end

        $display(
            "PASS WIDTH=%0d TESTS=%0d ERRORS=0",
            WIDTH, tests
        );

        $finish;
    end

endmodule
