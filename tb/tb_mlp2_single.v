`timescale 1ns/1ps
`include "attack_modes.vh"
`include "defense_modes.vh"
`include "model_profiles.vh"

module tb_mlp2_single;
    reg         clk;
    reg         rst_n;
    reg         start;
    reg         program_en;
    reg  [15:0] program_key;
    reg  [1:0]  attack_mode;
    reg  [2:0]  defense_mask;
    reg         safe_mode_en;
    reg  [1:0]  attack_profile_sel;
    reg  [7:0]  x0, x1, x2, x3;
    reg  [7:0]  l1_w00, l1_w01, l1_w02, l1_w03;
    reg  [7:0]  l1_w10, l1_w11, l1_w12, l1_w13;
    reg  [7:0]  l1_w20, l1_w21, l1_w22, l1_w23;
    reg  [7:0]  l1_w30, l1_w31, l1_w32, l1_w33;
    reg  [7:0]  l2_w00, l2_w01, l2_w02, l2_w03;
    reg  [7:0]  l2_w10, l2_w11, l2_w12, l2_w13;
    reg  [7:0]  l2_w20, l2_w21, l2_w22, l2_w23;
    reg  [7:0]  l2_w30, l2_w31, l2_w32, l2_w33;

    wire [19:0] y0, y1, y2, y3;
    wire [1:0] predicted_class, trusted_class, final_class;
    wire done, busy, trojan_armed, model_match, input_match, window_match, trigger_fire;
    wire remap_hit, bitflip_hit;
    wire [1:0] protected_bank;
    wire [2:0] protected_addr;
    wire checksum_alert, recompute_alert, behavior_alert, defense_alert;
    wire [2:0] alert_code;
    wire       loc_valid;
    wire [2:0] loc_reason;
    wire [1:0] loc_layer;
    wire [2:0] loc_tile;
    wire [1:0] loc_bank;
    wire [2:0] loc_addr;
    wire safe_mode_active;
    wire [15:0] cycle_count;
    reg  run_remap_seen;
    reg  run_bitflip_seen;

`include "tb_scenario_tasks.vh"

    mlp2_secure_accel_top dut (
        .clk(clk), .rst_n(rst_n), .start(start), .program_en(program_en), .program_key(program_key),
        .attack_mode(attack_mode), .defense_mask(defense_mask), .safe_mode_en(safe_mode_en),
        .attack_profile_sel(attack_profile_sel),
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .l1_w00(l1_w00), .l1_w01(l1_w01), .l1_w02(l1_w02), .l1_w03(l1_w03),
        .l1_w10(l1_w10), .l1_w11(l1_w11), .l1_w12(l1_w12), .l1_w13(l1_w13),
        .l1_w20(l1_w20), .l1_w21(l1_w21), .l1_w22(l1_w22), .l1_w23(l1_w23),
        .l1_w30(l1_w30), .l1_w31(l1_w31), .l1_w32(l1_w32), .l1_w33(l1_w33),
        .l2_w00(l2_w00), .l2_w01(l2_w01), .l2_w02(l2_w02), .l2_w03(l2_w03),
        .l2_w10(l2_w10), .l2_w11(l2_w11), .l2_w12(l2_w12), .l2_w13(l2_w13),
        .l2_w20(l2_w20), .l2_w21(l2_w21), .l2_w22(l2_w22), .l2_w23(l2_w23),
        .l2_w30(l2_w30), .l2_w31(l2_w31), .l2_w32(l2_w32), .l2_w33(l2_w33),
        .y0(y0), .y1(y1), .y2(y2), .y3(y3),
        .predicted_class(predicted_class), .trusted_class(trusted_class), .final_class(final_class),
        .done(done), .busy(busy), .trojan_armed(trojan_armed), .model_match(model_match),
        .input_match(input_match), .window_match(window_match), .trigger_fire(trigger_fire),
        .remap_hit(remap_hit), .bitflip_hit(bitflip_hit),
        .protected_bank(protected_bank), .protected_addr(protected_addr),
        .checksum_alert(checksum_alert), .recompute_alert(recompute_alert), .behavior_alert(behavior_alert),
        .defense_alert(defense_alert), .alert_code(alert_code),
        .loc_valid(loc_valid), .loc_reason(loc_reason), .loc_layer(loc_layer), .loc_tile(loc_tile),
        .loc_bank(loc_bank), .loc_addr(loc_addr),
        .safe_mode_active(safe_mode_active),
        .cycle_count(cycle_count)
    );

    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            run_remap_seen   <= 1'b0;
            run_bitflip_seen <= 1'b0;
        end else begin
            if (start) begin
                run_remap_seen   <= 1'b0;
                run_bitflip_seen <= 1'b0;
            end else begin
                if (remap_hit) begin
                    run_remap_seen <= 1'b1;
                end
                if (bitflip_hit) begin
                    run_bitflip_seen <= 1'b1;
                end
            end
        end
    end

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        program_en = 1'b0;
        program_key = 16'd0;
        attack_mode = `ATTACK_NONE;
        defense_mask = `DEF_NONE;
        safe_mode_en = 1'b0;
        attack_profile_sel = 2'd0;
        x0 = 8'd0; x1 = 8'd0; x2 = 8'd0; x3 = 8'd0;

        #12;
        rst_n = 1'b1;

        set_target_model();
        apply_input_profile(2'd0);
        launch_inference();
        $display("single-baseline pred=%0d trusted=%0d defense=%b cycles=%0d", predicted_class, trusted_class, defense_alert, cycle_count);

        program_trojan(16'hC35A);
        attack_mode  = `ATTACK_ADDR_REMAP;
        defense_mask = `DEF_ALL;
        safe_mode_en = 1'b1;
        apply_input_profile(2'd2);
        launch_inference();
        $display("single-attack pred=%0d final=%0d trusted=%0d remap=%b bitflip=%b defense=%b safe=%b code=%b loc_valid=%b layer=%0d tile=%0d bank=%0d addr=%0d cycles=%0d",
                 predicted_class, final_class, trusted_class, run_remap_seen, run_bitflip_seen,
                 defense_alert, safe_mode_active, alert_code, loc_valid, loc_layer, loc_tile, loc_bank, loc_addr, cycle_count);

        $finish;
    end
endmodule
