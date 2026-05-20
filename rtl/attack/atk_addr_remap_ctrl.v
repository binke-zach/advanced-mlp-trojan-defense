module atk_addr_remap_ctrl (
    input  wire [1:0] attack_mode,
    input  wire       trigger_fire,
    input  wire [1:0] layer_id,
    input  wire [2:0] tile_id,
    input  wire [1:0] legal_bank,
    input  wire [2:0] legal_addr,
    input  wire [1:0] shadow_bank,
    input  wire [2:0] shadow_addr,
    output wire       remap_hit,
    output reg  [1:0] actual_bank,
    output reg  [2:0] actual_addr,
    output wire       shadow_access_flag
);
    localparam [1:0] ATTACK_ADDR_REMAP = 2'd1;
    localparam [1:0] ATTACK_BOTH       = 2'd3;
    localparam [1:0] PROTECTED_LAYER   = 2'd1;
    localparam [2:0] PROTECTED_TILE    = 3'd2;

    assign remap_hit = trigger_fire &&
                       ((attack_mode == ATTACK_ADDR_REMAP) || (attack_mode == ATTACK_BOTH)) &&
                       (layer_id == PROTECTED_LAYER) &&
                       (tile_id == PROTECTED_TILE);

    assign shadow_access_flag = remap_hit;

    always @(*) begin
        actual_bank = legal_bank;
        actual_addr = legal_addr;
        if (remap_hit) begin
            actual_bank = shadow_bank;
            actual_addr = shadow_addr;
        end
    end
endmodule
