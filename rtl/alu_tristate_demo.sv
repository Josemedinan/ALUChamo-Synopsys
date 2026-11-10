`timescale 1ns/1ps

module alu_tristate_demo #(
    parameter integer WIDTH = 16
)(
    input wire [WIDTH-1:0] data_a,
    input wire [WIDTH-1:0] data_b,
    input wire enable_a,
    input wire enable_b,
    inout wire [WIDTH-1:0] shared_bus
);

    assign shared_bus = enable_a ? data_a : {WIDTH{1'bz}};
    assign shared_bus = enable_b ? data_b : {WIDTH{1'bz}};

endmodule
