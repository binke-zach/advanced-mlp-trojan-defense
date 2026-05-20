module weight_addr_gen (
    input  wire [1:0] layer_id,
    input  wire [2:0] tile_id,
    output wire [1:0] legal_bank,
    output wire [2:0] legal_addr,
    output wire [1:0] shadow_bank,
    output wire [2:0] shadow_addr
);
    assign legal_bank = {1'b0, tile_id[0]};
    assign legal_addr = tile_id;
    assign shadow_bank = 2'd1;
    assign shadow_addr = 3'd6;
endmodule
