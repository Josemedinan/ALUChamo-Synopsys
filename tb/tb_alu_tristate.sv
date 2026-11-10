`timescale 1ns/1ps

module tb_alu_tristate;

    reg [15:0] data_a, data_b;
    reg enable_a, enable_b;

    tri [15:0] shared_bus;
    integer errors;

    alu_tristate_demo dut (
        .data_a(data_a),
        .data_b(data_b),
        .enable_a(enable_a),
        .enable_b(enable_b),
        .shared_bus(shared_bus)
    );

    initial begin
        errors = 0;
        data_a = 16'hA55A;
        data_b = 16'h5AA5;

        enable_a = 0;
        enable_b = 0;
        #1;
        if (shared_bus !== 16'hzzzz)
            errors = errors + 1;

        enable_a = 1;
        enable_b = 0;
        #1;
        if (shared_bus !== data_a)
            errors = errors + 1;

        enable_a = 0;
        enable_b = 1;
        #1;
        if (shared_bus !== data_b)
            errors = errors + 1;

        enable_a = 1;
        enable_b = 1;
        #1;
        if (shared_bus !== 16'hxxxx)
            errors = errors + 1;

        enable_a = 0;
        enable_b = 0;
        #1;
        if (shared_bus !== 16'hzzzz)
            errors = errors + 1;

        if (errors != 0)
            $fatal(1, "TRISTATE_FAILED ERRORS=%0d", errors);

        $display("TRISTATE_PASS TESTS=5 ERRORS=0");
        $finish;
    end

endmodule
