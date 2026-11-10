`timescale 1ns/1ps

module alu_core #(
    parameter integer WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       alu_control,
    output reg  [WIDTH-1:0] result,
    output wire             n,
    output wire             z,
    output reg              c,
    output reg              v,
    output wire             div_by_zero
);

    wire subtract = (alu_control == 3'b001);
    wire [WIDTH-1:0] arithmetic_b = b ^ {WIDTH{subtract}};
    wire [WIDTH-1:0] arithmetic_result;
    wire arithmetic_carry;

    wire [WIDTH-1:0] quotient;
    wire [WIDTH-1:0] remainder;
    wire divider_zero;

    alu_cla #(.WIDTH(WIDTH)) u_cla (
        .a(a),
        .b(arithmetic_b),
        .cin(subtract),
        .sum(arithmetic_result),
        .cout(arithmetic_carry)
    );

    alu_divider #(.WIDTH(WIDTH)) u_divider (
        .dividend(a),
        .divisor(b),
        .quotient(quotient),
        .remainder(remainder),
        .div_by_zero(divider_zero)
    );

    wire select_and = (alu_control == 3'b010);
    wire select_or  = (alu_control == 3'b011);

    wire [WIDTH-1:0] and_a = select_and ? a : {WIDTH{1'b0}};
    wire [WIDTH-1:0] and_b = select_and ? b : {WIDTH{1'b0}};

    wire [WIDTH-1:0] or_a = select_or ? a : {WIDTH{1'b0}};
    wire [WIDTH-1:0] or_b = select_or ? b : {WIDTH{1'b0}};

    wire [WIDTH-1:0] gated_and = and_a & and_b;
    wire [WIDTH-1:0] gated_or  = or_a | or_b;

    always @(*) begin
        result = {WIDTH{1'b0}};
        c = 1'b0;
        v = 1'b0;

        case (alu_control)
            3'b000: begin
                result = arithmetic_result;
                c = arithmetic_carry;
                v = (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                    (a[WIDTH-1] ^ result[WIDTH-1]);
            end

            3'b001: begin
                result = arithmetic_result;
                c = arithmetic_carry;
                v = (a[WIDTH-1] ^ b[WIDTH-1]) &
                    (a[WIDTH-1] ^ result[WIDTH-1]);
            end

            3'b010: result = gated_and;
            3'b011: result = gated_or;

            3'b100: result = {WIDTH{1'b0}};

            3'b101: result = quotient;
            3'b110: result = remainder;

            3'b111: result = {WIDTH{1'b0}};

        endcase
    end

    assign n = result[WIDTH-1];
    assign z = (result == {WIDTH{1'b0}});

    assign div_by_zero =
        ((alu_control == 3'b101) ||
         (alu_control == 3'b110)) && divider_zero;

endmodule
