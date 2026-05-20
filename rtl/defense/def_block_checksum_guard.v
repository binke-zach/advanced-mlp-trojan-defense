module def_block_checksum_guard (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clear,
    input  wire        check_en,
    input  wire [1:0]  layer_id,
    input  wire [2:0]  tile_id,
    input  wire [7:0]  d0,
    input  wire [7:0]  d1,
    input  wire [7:0]  d2,
    input  wire [7:0]  d3,
    input  wire [11:0] expected_checksum,
    output reg  [11:0] actual_checksum,
    output reg         checksum_alert,
    output reg  [1:0]  mismatch_layer,
    output reg  [2:0]  mismatch_tile
);
    wire [11:0] checksum_next;

    checksum_tile checksum_calc (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3), .checksum(checksum_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            actual_checksum <= 12'd0;
            checksum_alert  <= 1'b0;
            mismatch_layer  <= 2'd0;
            mismatch_tile   <= 3'd0;
        end else if (clear) begin
            actual_checksum <= 12'd0;
            checksum_alert  <= 1'b0;
            mismatch_layer  <= 2'd0;
            mismatch_tile   <= 3'd0;
        end else if (check_en) begin
            actual_checksum <= checksum_next;
            checksum_alert  <= (checksum_next != expected_checksum);
            mismatch_layer  <= layer_id;
            mismatch_tile   <= tile_id;
        end
    end
endmodule
