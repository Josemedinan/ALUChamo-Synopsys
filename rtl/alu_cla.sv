`timescale 1ns/1ps
module alu_cla #(
    parameter integer WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    localparam integer GROUPS = WIDTH / 4;

    wire [WIDTH-1:0] p, g;
    wire [GROUPS:0] c;
    wire [GROUPS-1:0] pg, gg;

    assign p = a ^ b;
    assign g = a & b;
    assign c[0] = cin;

    genvar k;

    generate
        for (k = 0; k < GROUPS; k = k + 1) begin : cla_group
            wire [3:0] bp = p[4*k +: 4];
            wire [3:0] bg = g[4*k +: 4];
            wire [4:0] bc;

            assign bc[0] = c[k];

            assign bc[1] = bg[0] |
                           (bp[0] & bc[0]);

            assign bc[2] = bg[1] |
                           (bp[1] & bg[0]) |
                           (bp[1] & bp[0] & bc[0]);

            assign bc[3] = bg[2] |
                           (bp[2] & bg[1]) |
                           (bp[2] & bp[1] & bg[0]) |
                           (bp[2] & bp[1] & bp[0] & bc[0]);

            assign pg[k] = &bp;

            assign gg[k] = bg[3] |
                           (bp[3] & bg[2]) |
                           (bp[3] & bp[2] & bg[1]) |
                           (bp[3] & bp[2] & bp[1] & bg[0]);

            assign c[k+1] = gg[k] | (pg[k] & c[k]);

            assign bc[4] = c[k+1];

            assign sum[4*k +: 4] = bp ^ bc[3:0];
        end
    endgenerate

    assign cout = c[GROUPS];

`ifndef SYNTHESIS
    initial begin
        if (WIDTH < 4 || WIDTH % 4 != 0)
            $fatal(1, "WIDTH must be a multiple of 4");
    end
`endif

endmodule
