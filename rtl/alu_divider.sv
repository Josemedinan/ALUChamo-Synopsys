`timescale 1ns/1ps
module alu_divider #(
    parameter integer WIDTH = 8
)(
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    output reg  [WIDTH-1:0] quotient,
    output reg  [WIDTH-1:0] remainder,
    output wire             div_by_zero
);

    reg [WIDTH:0] partial;
    integer i;

    assign div_by_zero = (divisor == {WIDTH{1'b0}});

    always @(*) begin
        quotient = {WIDTH{1'b0}};
        remainder = {WIDTH{1'b0}};
        partial = {(WIDTH+1){1'b0}};

        if (!div_by_zero) begin
            for (i = WIDTH-1; i >= 0; i = i-1) begin
                partial = {partial[WIDTH-1:0], dividend[i]};

                if (partial >= {1'b0, divisor}) begin
                    partial = partial - {1'b0, divisor};
                    quotient[i] = 1'b1;
                end
            end

            remainder = partial[WIDTH-1:0];
        end
    end

endmodule
