module checksum_tile (
    input  wire [7:0] d0,
    input  wire [7:0] d1,
    input  wire [7:0] d2,
    input  wire [7:0] d3,
    output wire [11:0] checksum
);
    assign checksum = d0 + (d1 * 3) + (d2 * 5) + (d3 * 7);
endmodule
