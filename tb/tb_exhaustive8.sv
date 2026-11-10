`timescale 1ns/1ps

module tb_exhaustive8;

    reg [7:0] a, b;
    reg cin;

    wire [7:0] sum, quotient, remainder;
    wire cout, div_by_zero;

    reg [8:0] expected;
    integer x, y, errors, tests;

    alu_cla #(.WIDTH(8)) cla (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    alu_divider #(.WIDTH(8)) div_unit (
        .dividend(a), .divisor(b),
        .quotient(quotient),
        .remainder(remainder),
        .div_by_zero(div_by_zero)
    );

    initial begin
        errors = 0;
        tests = 0;

        for (x = 0; x < 256; x = x + 1) begin
            for (y = 0; y < 256; y = y + 1) begin
                for (integer c = 0; c < 2; c = c + 1) begin
                    a = x;
                    b = y;
                    cin = c;
                    #1;

                    expected = {1'b0,a} + {1'b0,b} + cin;

                    if ({cout,sum} !== expected)
                        errors = errors + 1;

                    if (b == 0) begin
                        if (!div_by_zero ||
                            quotient !== 0 ||
                            remainder !== 0)
                            errors = errors + 1;
                    end else begin
                        if (div_by_zero ||
                            quotient !== (a / b) ||
                            remainder !== (a % b))
                            errors = errors + 1;
                    end

                    tests = tests + 1;
                end
            end
        end

        if (errors != 0)
            $fatal(1, "EXHAUSTIVE8_FAIL ERRORS=%0d", errors);

        $display("EXHAUSTIVE8_PASS TESTS=%0d ERRORS=0", tests);
        $finish;
    end

endmodule
