module mlp2_secure_accel_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        program_en,
    input  wire [15:0] program_key,
    input  wire [1:0]  attack_mode,
    input  wire [2:0]  defense_mask,
    input  wire        safe_mode_en,
    input  wire [1:0]  attack_profile_sel,
    input  wire [7:0]  x0,
    input  wire [7:0]  x1,
    input  wire [7:0]  x2,
    input  wire [7:0]  x3,
    input  wire [7:0]  l1_w00, input wire [7:0] l1_w01, input wire [7:0] l1_w02, input wire [7:0] l1_w03,
    input  wire [7:0]  l1_w10, input wire [7:0] l1_w11, input wire [7:0] l1_w12, input wire [7:0] l1_w13,
    input  wire [7:0]  l1_w20, input wire [7:0] l1_w21, input wire [7:0] l1_w22, input wire [7:0] l1_w23,
    input  wire [7:0]  l1_w30, input wire [7:0] l1_w31, input wire [7:0] l1_w32, input wire [7:0] l1_w33,
    input  wire [7:0]  l2_w00, input wire [7:0] l2_w01, input wire [7:0] l2_w02, input wire [7:0] l2_w03,
    input  wire [7:0]  l2_w10, input wire [7:0] l2_w11, input wire [7:0] l2_w12, input wire [7:0] l2_w13,
    input  wire [7:0]  l2_w20, input wire [7:0] l2_w21, input wire [7:0] l2_w22, input wire [7:0] l2_w23,
    input  wire [7:0]  l2_w30, input wire [7:0] l2_w31, input wire [7:0] l2_w32, input wire [7:0] l2_w33,
    output wire [19:0] y0,
    output wire [19:0] y1,
    output wire [19:0] y2,
    output wire [19:0] y3,
    output wire [1:0]  predicted_class,
    output wire [1:0]  trusted_class,
    output wire [1:0]  final_class,
    output wire        done,
    output wire        busy,
    output wire        trojan_armed,
    output wire        model_match,
    output wire        input_match,
    output wire        window_match,
    output wire        trigger_fire,
    output wire        remap_hit,
    output wire        bitflip_hit,
    output wire [1:0]  protected_bank,
    output wire [2:0]  protected_addr,
    output wire        checksum_alert,
    output wire        recompute_alert,
    output wire        behavior_alert,
    output wire        defense_alert,
    output wire [2:0]  alert_code,
    output wire        loc_valid,
    output wire [2:0]  loc_reason,
    output wire [1:0]  loc_layer,
    output wire [2:0]  loc_tile,
    output wire [1:0]  loc_bank,
    output wire [2:0]  loc_addr,
    output wire        safe_mode_active,
    output wire [15:0] cycle_count
);
    reg [15:0] model_fingerprint;
    wire [15:0] input_signature;
    wire clear_buffers;
    wire load_en;
    wire [1:0] load_layer_id;
    wire [2:0] load_tile_id;
    wire core_start;
    wire output_valid;
    wire write_valid;
    wire [1:0] legal_bank;
    wire [2:0] legal_addr;
    wire [1:0] shadow_bank;
    wire [2:0] shadow_addr;
    wire [1:0] actual_bank;
    wire [2:0] actual_addr;
    wire [7:0] load_d0, load_d1, load_d2, load_d3;
    wire shadow_access_flag;
    wire [7:0] h0, h1, h2, h3;
    wire [15:0] lfsr_state;
    wire [11:0] expected_checksum;
    wire [11:0] checksum_actual;
    wire [1:0] mismatch_layer;
    wire [2:0] mismatch_tile;
    wire sample_hit;
    wire seq_alert;
    wire latency_alert;
    wire addr_alert_ext;
    wire [1:0] predicted_class_w;
    wire [1:0] trusted_class_w;
    reg  [1:0] suspicious_layer;
    reg  [2:0] suspicious_tile;
    reg  [1:0] suspicious_bank;
    reg  [2:0] suspicious_addr;

    wire [7:0] l1_t0_w0, l1_t0_w1, l1_t0_w2, l1_t0_w3;
    wire [7:0] l1_t1_w0, l1_t1_w1, l1_t1_w2, l1_t1_w3;
    wire [7:0] l1_t2_w0, l1_t2_w1, l1_t2_w2, l1_t2_w3;
    wire [7:0] l1_t3_w0, l1_t3_w1, l1_t3_w2, l1_t3_w3;
    wire [7:0] l2_t0_w0, l2_t0_w1, l2_t0_w2, l2_t0_w3;
    wire [7:0] l2_t1_w0, l2_t1_w1, l2_t1_w2, l2_t1_w3;
    wire [7:0] l2_t2_w0, l2_t2_w1, l2_t2_w2, l2_t2_w3;
    wire [7:0] l2_t3_w0, l2_t3_w1, l2_t3_w2, l2_t3_w3;

    wire [19:0] trusted_y0, trusted_y1, trusted_y2, trusted_y3;

    function [15:0] fingerprint4x4;
        input [7:0] a00;
        input [7:0] a01;
        input [7:0] a02;
        input [7:0] a03;
        input [7:0] a10;
        input [7:0] a11;
        input [7:0] a12;
        input [7:0] a13;
        input [7:0] a20;
        input [7:0] a21;
        input [7:0] a22;
        input [7:0] a23;
        input [7:0] a30;
        input [7:0] a31;
        input [7:0] a32;
        input [7:0] a33;
        begin
            fingerprint4x4 =
                (a00 * 1)  + (a01 * 2)  + (a02 * 3)  + (a03 * 4)  +
                (a10 * 5)  + (a11 * 6)  + (a12 * 7)  + (a13 * 8)  +
                (a20 * 9)  + (a21 * 10) + (a22 * 11) + (a23 * 12) +
                (a30 * 13) + (a31 * 14) + (a32 * 15) + (a33 * 16);
        end
    endfunction

    assign input_signature   = {x0, x3};
    assign expected_checksum = l2_w20 + (l2_w21 * 3) + (l2_w22 * 5) + (l2_w23 * 7);
    assign protected_bank    = actual_bank;
    assign protected_addr    = actual_addr;

    assign trusted_y0 = h0 * l2_w00 + h1 * l2_w01 + h2 * l2_w02 + h3 * l2_w03;
    assign trusted_y1 = h0 * l2_w10 + h1 * l2_w11 + h2 * l2_w12 + h3 * l2_w13;
    assign trusted_y2 = h0 * l2_w20 + h1 * l2_w21 + h2 * l2_w22 + h3 * l2_w23;
    assign trusted_y3 = h0 * l2_w30 + h1 * l2_w31 + h2 * l2_w32 + h3 * l2_w33;

    always @(*) begin
        model_fingerprint = fingerprint4x4(
            l2_w00, l2_w01, l2_w02, l2_w03,
            l2_w10, l2_w11, l2_w12, l2_w13,
            l2_w20, l2_w21, l2_w22, l2_w23,
            l2_w30, l2_w31, l2_w32, l2_w33
        );
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            suspicious_layer <= 2'd0;
            suspicious_tile  <= 3'd0;
            suspicious_bank  <= 2'd0;
            suspicious_addr  <= 3'd0;
        end else if (start) begin
            suspicious_layer <= 2'd0;
            suspicious_tile  <= 3'd0;
            suspicious_bank  <= 2'd0;
            suspicious_addr  <= 3'd0;
        end else if (write_valid && (load_layer_id == 2'd1) && (load_tile_id == 3'd2)) begin
            suspicious_layer <= load_layer_id;
            suspicious_tile  <= load_tile_id;
            suspicious_bank  <= actual_bank;
            suspicious_addr  <= actual_addr;
        end
    end

    trojan_trigger_fsm trigger_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .program_en(program_en),
        .program_key(program_key),
        .model_fingerprint(model_fingerprint),
        .input_signature(input_signature),
        .attack_mode(attack_mode),
        .trojan_armed(trojan_armed),
        .model_match(model_match),
        .input_match(input_match),
        .window_match(window_match),
        .trigger_fire(trigger_fire),
        .infer_count()
    );

    mlp2_ctrl ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .load_done(write_valid),
        .core_done(done),
        .clear_buffers(clear_buffers),
        .load_en(load_en),
        .load_layer_id(load_layer_id),
        .load_tile_id(load_tile_id),
        .core_start(core_start),
        .output_valid(output_valid),
        .busy(busy),
        .cycle_count(cycle_count)
    );

    weight_addr_gen addr_gen (
        .layer_id(load_layer_id),
        .tile_id(load_tile_id),
        .legal_bank(legal_bank),
        .legal_addr(legal_addr),
        .shadow_bank(shadow_bank),
        .shadow_addr(shadow_addr)
    );

    weight_loader_dma loader (
        .load_en(load_en),
        .layer_id(load_layer_id),
        .tile_id(load_tile_id),
        .attack_mode(attack_mode),
        .trigger_fire(trigger_fire),
        .legal_bank(legal_bank),
        .legal_addr(legal_addr),
        .shadow_bank(shadow_bank),
        .shadow_addr(shadow_addr),
        .attack_profile_sel(attack_profile_sel),
        .l1_w00(l1_w00), .l1_w01(l1_w01), .l1_w02(l1_w02), .l1_w03(l1_w03),
        .l1_w10(l1_w10), .l1_w11(l1_w11), .l1_w12(l1_w12), .l1_w13(l1_w13),
        .l1_w20(l1_w20), .l1_w21(l1_w21), .l1_w22(l1_w22), .l1_w23(l1_w23),
        .l1_w30(l1_w30), .l1_w31(l1_w31), .l1_w32(l1_w32), .l1_w33(l1_w33),
        .l2_w00(l2_w00), .l2_w01(l2_w01), .l2_w02(l2_w02), .l2_w03(l2_w03),
        .l2_w10(l2_w10), .l2_w11(l2_w11), .l2_w12(l2_w12), .l2_w13(l2_w13),
        .l2_w20(l2_w20), .l2_w21(l2_w21), .l2_w22(l2_w22), .l2_w23(l2_w23),
        .l2_w30(l2_w30), .l2_w31(l2_w31), .l2_w32(l2_w32), .l2_w33(l2_w33),
        .write_valid(write_valid),
        .actual_bank(actual_bank),
        .actual_addr(actual_addr),
        .write_d0(load_d0), .write_d1(load_d1), .write_d2(load_d2), .write_d3(load_d3),
        .remap_hit(remap_hit),
        .bitflip_hit(bitflip_hit),
        .shadow_access_flag(shadow_access_flag)
    );

    banked_weight_buffer weight_buf (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear_buffers),
        .write_valid(write_valid),
        .layer_id(load_layer_id),
        .tile_id(load_tile_id),
        .bank_id(actual_bank),
        .d0(load_d0), .d1(load_d1), .d2(load_d2), .d3(load_d3),
        .l1_t0_w0(l1_t0_w0), .l1_t0_w1(l1_t0_w1), .l1_t0_w2(l1_t0_w2), .l1_t0_w3(l1_t0_w3),
        .l1_t1_w0(l1_t1_w0), .l1_t1_w1(l1_t1_w1), .l1_t1_w2(l1_t1_w2), .l1_t1_w3(l1_t1_w3),
        .l1_t2_w0(l1_t2_w0), .l1_t2_w1(l1_t2_w1), .l1_t2_w2(l1_t2_w2), .l1_t2_w3(l1_t2_w3),
        .l1_t3_w0(l1_t3_w0), .l1_t3_w1(l1_t3_w1), .l1_t3_w2(l1_t3_w2), .l1_t3_w3(l1_t3_w3),
        .l2_t0_w0(l2_t0_w0), .l2_t0_w1(l2_t0_w1), .l2_t0_w2(l2_t0_w2), .l2_t0_w3(l2_t0_w3),
        .l2_t1_w0(l2_t1_w0), .l2_t1_w1(l2_t1_w1), .l2_t1_w2(l2_t1_w2), .l2_t1_w3(l2_t1_w3),
        .l2_t2_w0(l2_t2_w0), .l2_t2_w1(l2_t2_w1), .l2_t2_w2(l2_t2_w2), .l2_t2_w3(l2_t2_w3),
        .l2_t3_w0(l2_t3_w0), .l2_t3_w1(l2_t3_w1), .l2_t3_w2(l2_t3_w2), .l2_t3_w3(l2_t3_w3)
    );

    mlp2_accel_core core (
        .clk(clk),
        .rst_n(rst_n),
        .start(core_start),
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .l1_w00(l1_t0_w0), .l1_w01(l1_t0_w1), .l1_w02(l1_t0_w2), .l1_w03(l1_t0_w3),
        .l1_w10(l1_t1_w0), .l1_w11(l1_t1_w1), .l1_w12(l1_t1_w2), .l1_w13(l1_t1_w3),
        .l1_w20(l1_t2_w0), .l1_w21(l1_t2_w1), .l1_w22(l1_t2_w2), .l1_w23(l1_t2_w3),
        .l1_w30(l1_t3_w0), .l1_w31(l1_t3_w1), .l1_w32(l1_t3_w2), .l1_w33(l1_t3_w3),
        .l2_w00(l2_t0_w0), .l2_w01(l2_t0_w1), .l2_w02(l2_t0_w2), .l2_w03(l2_t0_w3),
        .l2_w10(l2_t1_w0), .l2_w11(l2_t1_w1), .l2_w12(l2_t1_w2), .l2_w13(l2_t1_w3),
        .l2_w20(l2_t2_w0), .l2_w21(l2_t2_w1), .l2_w22(l2_t2_w2), .l2_w23(l2_t2_w3),
        .l2_w30(l2_t3_w0), .l2_w31(l2_t3_w1), .l2_w32(l2_t3_w2), .l2_w33(l2_t3_w3),
        .busy(),
        .done(done),
        .y0(y0), .y1(y1), .y2(y2), .y3(y3),
        .h0(h0), .h1(h1), .h2(h2), .h3(h3)
    );

    argmax4 pred_argmax (
        .a0(y0), .a1(y1), .a2(y2), .a3(y3), .cls(predicted_class_w)
    );
    argmax4 trusted_argmax (
        .a0(trusted_y0), .a1(trusted_y1), .a2(trusted_y2), .a3(trusted_y3), .cls(trusted_class_w)
    );

    assign predicted_class = predicted_class_w;
    assign trusted_class   = trusted_class_w;

    def_block_checksum_guard checksum_guard (
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear_buffers),
        .check_en(write_valid && (load_layer_id == 2'd1) && (load_tile_id == 3'd2)),
        .layer_id(load_layer_id),
        .tile_id(load_tile_id),
        .d0(load_d0), .d1(load_d1), .d2(load_d2), .d3(load_d3),
        .expected_checksum(expected_checksum),
        .actual_checksum(checksum_actual),
        .checksum_alert(checksum_alert),
        .mismatch_layer(mismatch_layer),
        .mismatch_tile(mismatch_tile)
    );

    def_random_recompute_ctrl recompute_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .compare_en(output_valid),
        .defense_enable(defense_mask[1]),
        .observed_y2(y2),
        .trusted_y2(trusted_y2),
        .observed_class(predicted_class_w),
        .trusted_class(trusted_class_w),
        .sample_hit(sample_hit),
        .recompute_alert(recompute_alert),
        .lfsr_state(lfsr_state)
    );

    def_behavior_monitor behavior_mon (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .load_en(write_valid),
        .layer_id(load_layer_id),
        .tile_id(load_tile_id),
        .actual_bank(actual_bank),
        .actual_addr(actual_addr),
        .done(output_valid),
        .seq_alert(seq_alert),
        .latency_alert(latency_alert),
        .addr_alert_ext(addr_alert_ext),
        .behavior_alert(behavior_alert)
    );

    def_alert_fusion alert_fusion (
        .defense_mask(defense_mask),
        .checksum_alert(checksum_alert),
        .recompute_alert(recompute_alert),
        .behavior_alert(behavior_alert),
        .defense_alert(defense_alert),
        .alert_code(alert_code)
    );

    def_attack_locator attack_locator (
        .checksum_alert(checksum_alert),
        .recompute_alert(recompute_alert),
        .behavior_alert(behavior_alert),
        .mismatch_layer(mismatch_layer),
        .mismatch_tile(mismatch_tile),
        .observed_layer(suspicious_layer),
        .observed_tile(suspicious_tile),
        .observed_bank(suspicious_bank),
        .observed_addr(suspicious_addr),
        .loc_valid(loc_valid),
        .loc_reason(loc_reason),
        .loc_layer(loc_layer),
        .loc_tile(loc_tile),
        .loc_bank(loc_bank),
        .loc_addr(loc_addr)
    );

    def_response_ctrl response_ctrl (
        .defense_alert(defense_alert),
        .safe_mode_en(safe_mode_en),
        .predicted_class(predicted_class_w),
        .trusted_class(trusted_class_w),
        .final_class(final_class),
        .safe_mode_active(safe_mode_active)
    );
endmodule
