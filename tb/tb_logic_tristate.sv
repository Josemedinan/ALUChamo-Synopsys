`timescale 1ns/1ps

module tb_logic_tristate;

    reg [7:0] a, b;
    reg [2:0] alu_control;

    wire [7:0] result;
    wire active;

    integer errors, tests, op;

    alu_logic_tristate #(.WIDTH(8)) dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .logic_result(result),
        .logic_active(active)
    );

    initial begin
        errors = 0;
        tests = 0;

        a = 8'hA5;
        b = 8'h3C;

        for (op = 0; op < 8; op = op + 1) begin
            alu_control = op;
            #1;

            case (op)
                2: begin
                    if (result !== (a & b) || active !== 1'b1)
                        errors = errors + 1;
                end

                3: begin
                    if (result !== (a | b) || active !== 1'b1)
                        errors = errors + 1;
                end

                default: begin
                    if (result !== 8'hzz || active !== 1'b0)
                        errors = errors + 1;
                end
            endcase

            tests = tests + 1;
        end

        if (errors != 0)
            $fatal(1, "LOGIC_TRISTATE_FAIL ERRORS=%0d", errors);

        $display(
            "LOGIC_TRISTATE_PASS TESTS=%0d ERRORS=0",
            tests
        );

        $finish;
    end

endmodule
