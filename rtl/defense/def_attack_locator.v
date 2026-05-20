module def_attack_locator (
    input  wire       checksum_alert,
    input  wire       recompute_alert,
    input  wire       behavior_alert,
    input  wire [1:0] mismatch_layer,
    input  wire [2:0] mismatch_tile,
    input  wire [1:0] observed_layer,
    input  wire [2:0] observed_tile,
    input  wire [1:0] observed_bank,
    input  wire [2:0] observed_addr,
    output reg        loc_valid,
    output reg  [2:0] loc_reason,
    output reg  [1:0] loc_layer,
    output reg  [2:0] loc_tile,
    output reg  [1:0] loc_bank,
    output reg  [2:0] loc_addr
);
    always @(*) begin
        loc_valid  = 1'b0;
        loc_reason = 3'b000;
        loc_layer  = 2'd0;
        loc_tile   = 3'd0;
        loc_bank   = 2'd0;
        loc_addr   = 3'd0;

        if (checksum_alert) begin
            loc_valid  = 1'b1;
            loc_reason = 3'b001;
            loc_layer  = mismatch_layer;
            loc_tile   = mismatch_tile;
            loc_bank   = observed_bank;
            loc_addr   = observed_addr;
        end else if (recompute_alert) begin
            loc_valid  = 1'b1;
            loc_reason = 3'b010;
            loc_layer  = mismatch_layer;
            loc_tile   = mismatch_tile;
            loc_bank   = observed_bank;
            loc_addr   = observed_addr;
        end else if (behavior_alert) begin
            loc_valid  = 1'b1;
            loc_reason = 3'b100;
            loc_layer  = observed_layer;
            loc_tile   = observed_tile;
            loc_bank   = observed_bank;
            loc_addr   = observed_addr;
        end
    end
endmodule
