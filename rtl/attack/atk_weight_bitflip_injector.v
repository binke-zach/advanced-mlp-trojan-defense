module atk_weight_bitflip_injector (
    input  wire [1:0] attack_mode,
    input  wire       trigger_fire,
    input  wire [1:0] layer_id,
    input  wire [2:0] tile_id,
    input  wire [7:0] d0,
    input  wire [7:0] d1,
    input  wire [7:0] d2,
    input  wire [7:0] d3,
    input  wire [7:0] mask0,
    input  wire [7:0] mask1,
    input  wire [7:0] mask2,
    input  wire [7:0] mask3,
    output wire       bitflip_hit,
    output reg  [7:0] q0,
    output reg  [7:0] q1,
    output reg  [7:0] q2,
    output reg  [7:0] q3
);
    localparam [1:0] ATTACK_BITFLIP = 2'd2;
    localparam [1:0] ATTACK_BOTH    = 2'd3;
    localparam [1:0] PROTECTED_LAYER = 2'd1;
    localparam [2:0] PROTECTED_TILE  = 3'd2;

    assign bitflip_hit = trigger_fire &&
                         ((attack_mode == ATTACK_BITFLIP) || (attack_mode == ATTACK_BOTH)) &&
                         (layer_id == PROTECTED_LAYER) &&
                         (tile_id == PROTECTED_TILE);

    always @(*) begin
        q0 = d0;
        q1 = d1;
        q2 = d2;
        q3 = d3;
        if (bitflip_hit) begin
            q0 = d0 ^ mask0;
            q1 = d1 ^ mask1;
            q2 = d2 ^ mask2;
            q3 = d3 ^ mask3;
        end
    end
endmodule
