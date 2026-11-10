`timescale 1ns/1ps

module alu_logic_tristate #(
    parameter integer WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       alu_control,
    output wire [WIDTH-1:0] logic_result,
    output wire             logic_active
);

    wire select_and = (alu_control == 3'b010);
    wire select_or  = (alu_control == 3'b011);

    // Aislamiento de operandos antes de las compuertas.
    wire [WIDTH-1:0] and_a = select_and ? a : {WIDTH{1'b0}};
    wire [WIDTH-1:0] and_b = select_and ? b : {WIDTH{1'b0}};

    wire [WIDTH-1:0] or_a = select_or ? a : {WIDTH{1'b0}};
    wire [WIDTH-1:0] or_b = select_or ? b : {WIDTH{1'b0}};

    wire [WIDTH-1:0] and_result = and_a & and_b;
    wire [WIDTH-1:0] or_result  = or_a | or_b;

    tri [WIDTH-1:0] shared_bus;

    // Conductores triestado: solo uno se habilita.
    assign shared_bus = select_and ? and_result : {WIDTH{1'bz}};
    assign shared_bus = select_or  ? or_result  : {WIDTH{1'bz}};

    assign logic_active = select_and | select_or;
    assign logic_result = shared_bus;

endmodule
