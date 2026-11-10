`timescale 1ns/1ps

module alu_sync16 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  alu_control,
    output reg  [15:0] result,
    output reg         n,
    output reg         z,
    output reg         c,
    output reg         v,
    output reg         div_by_zero
);

    reg [15:0] a_reg, b_reg;
    reg [2:0] control_reg;

    wire [15:0] core_result;
    wire core_n, core_z, core_c, core_v, core_divzero;

    alu_core #(.WIDTH(16)) u_core (
        .a(a_reg),
        .b(b_reg),
        .alu_control(control_reg),
        .result(core_result),
        .n(core_n),
        .z(core_z),
        .c(core_c),
        .v(core_v),
        .div_by_zero(core_divzero)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 16'b0;
            b_reg <= 16'b0;
            control_reg <= 3'b0;

            result <= 16'b0;
            n <= 1'b0;
            z <= 1'b0;
            c <= 1'b0;
            v <= 1'b0;
            div_by_zero <= 1'b0;
        end else begin
            a_reg <= a;
            b_reg <= b;
            control_reg <= alu_control;

            result <= core_result;
            n <= core_n;
            z <= core_z;
            c <= core_c;
            v <= core_v;
            div_by_zero <= core_divzero;
        end
    end

endmodule
