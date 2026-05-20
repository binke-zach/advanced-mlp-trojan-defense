module weight_loader_dma (
    input  wire        load_en,
    input  wire [1:0]  layer_id,
    input  wire [2:0]  tile_id,
    input  wire [1:0]  attack_mode,
    input  wire        trigger_fire,
    input  wire [1:0]  legal_bank,
    input  wire [2:0]  legal_addr,
    input  wire [1:0]  shadow_bank,
    input  wire [2:0]  shadow_addr,
    input  wire [1:0]  attack_profile_sel,
    input  wire [7:0]  l1_w00, input wire [7:0] l1_w01, input wire [7:0] l1_w02, input wire [7:0] l1_w03,
    input  wire [7:0]  l1_w10, input wire [7:0] l1_w11, input wire [7:0] l1_w12, input wire [7:0] l1_w13,
    input  wire [7:0]  l1_w20, input wire [7:0] l1_w21, input wire [7:0] l1_w22, input wire [7:0] l1_w23,
    input  wire [7:0]  l1_w30, input wire [7:0] l1_w31, input wire [7:0] l1_w32, input wire [7:0] l1_w33,
    input  wire [7:0]  l2_w00, input wire [7:0] l2_w01, input wire [7:0] l2_w02, input wire [7:0] l2_w03,
    input  wire [7:0]  l2_w10, input wire [7:0] l2_w11, input wire [7:0] l2_w12, input wire [7:0] l2_w13,
    input  wire [7:0]  l2_w20, input wire [7:0] l2_w21, input wire [7:0] l2_w22, input wire [7:0] l2_w23,
    input  wire [7:0]  l2_w30, input wire [7:0] l2_w31, input wire [7:0] l2_w32, input wire [7:0] l2_w33,
    output wire        write_valid,
    output wire [1:0]  actual_bank,
    output wire [2:0]  actual_addr,
    output wire [7:0]  write_d0,
    output wire [7:0]  write_d1,
    output wire [7:0]  write_d2,
    output wire [7:0]  write_d3,
    output wire        remap_hit,
    output wire        bitflip_hit,
    output wire        shadow_access_flag
);
    reg [7:0] legal0;
    reg [7:0] legal1;
    reg [7:0] legal2;
    reg [7:0] legal3;

    wire [7:0] shadow0;
    wire [7:0] shadow1;
    wire [7:0] shadow2;
    wire [7:0] shadow3;
    wire [7:0] mask0;
    wire [7:0] mask1;
    wire [7:0] mask2;
    wire [7:0] mask3;
    wire [7:0] flip0;
    wire [7:0] flip1;
    wire [7:0] flip2;
    wire [7:0] flip3;
    wire       attack_applied;

    assign write_valid = load_en;

    always @(*) begin
        legal0 = 8'd0;
        legal1 = 8'd0;
        legal2 = 8'd0;
        legal3 = 8'd0;

        if (layer_id == 2'd0) begin
            case (tile_id)
                3'd0: begin legal0 = l1_w00; legal1 = l1_w01; legal2 = l1_w02; legal3 = l1_w03; end
                3'd1: begin legal0 = l1_w10; legal1 = l1_w11; legal2 = l1_w12; legal3 = l1_w13; end
                3'd2: begin legal0 = l1_w20; legal1 = l1_w21; legal2 = l1_w22; legal3 = l1_w23; end
                default: begin legal0 = l1_w30; legal1 = l1_w31; legal2 = l1_w32; legal3 = l1_w33; end
            endcase
        end else begin
            case (tile_id)
                3'd0: begin legal0 = l2_w00; legal1 = l2_w01; legal2 = l2_w02; legal3 = l2_w03; end
                3'd1: begin legal0 = l2_w10; legal1 = l2_w11; legal2 = l2_w12; legal3 = l2_w13; end
                3'd2: begin legal0 = l2_w20; legal1 = l2_w21; legal2 = l2_w22; legal3 = l2_w23; end
                default: begin legal0 = l2_w30; legal1 = l2_w31; legal2 = l2_w32; legal3 = l2_w33; end
            endcase
        end
    end

    attack_profile_rom profile_rom (
        .profile_sel(attack_profile_sel),
        .shadow_w0(shadow0),
        .shadow_w1(shadow1),
        .shadow_w2(shadow2),
        .shadow_w3(shadow3),
        .bitmask0(mask0),
        .bitmask1(mask1),
        .bitmask2(mask2),
        .bitmask3(mask3)
    );

    atk_addr_remap_ctrl remap_ctrl (
        .attack_mode(attack_mode),
        .trigger_fire(trigger_fire),
        .layer_id(layer_id),
        .tile_id(tile_id),
        .legal_bank(legal_bank),
        .legal_addr(legal_addr),
        .shadow_bank(shadow_bank),
        .shadow_addr(shadow_addr),
        .remap_hit(remap_hit),
        .actual_bank(actual_bank),
        .actual_addr(actual_addr),
        .shadow_access_flag(shadow_access_flag)
    );

    atk_weight_bitflip_injector bitflip_injector (
        .attack_mode(attack_mode),
        .trigger_fire(trigger_fire),
        .layer_id(layer_id),
        .tile_id(tile_id),
        .d0(legal0),
        .d1(legal1),
        .d2(legal2),
        .d3(legal3),
        .mask0(mask0),
        .mask1(mask1),
        .mask2(mask2),
        .mask3(mask3),
        .bitflip_hit(bitflip_hit),
        .q0(flip0),
        .q1(flip1),
        .q2(flip2),
        .q3(flip3)
    );

    attack_mux attack_select (
        .attack_mode(attack_mode),
        .remap_hit(remap_hit),
        .bitflip_hit(bitflip_hit),
        .legal0(legal0),
        .legal1(legal1),
        .legal2(legal2),
        .legal3(legal3),
        .shadow0(shadow0),
        .shadow1(shadow1),
        .shadow2(shadow2),
        .shadow3(shadow3),
        .flip0(flip0),
        .flip1(flip1),
        .flip2(flip2),
        .flip3(flip3),
        .out0(write_d0),
        .out1(write_d1),
        .out2(write_d2),
        .out3(write_d3),
        .attack_applied(attack_applied)
    );
endmodule
