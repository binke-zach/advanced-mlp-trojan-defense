`timescale 1ns/1ps
`include "attack_modes.vh"
`include "defense_modes.vh"
`include "model_profiles.vh"

module tb_mlp2_batch;
    localparam NUM_SCENARIOS = 147;

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
    wire [1:0]  predicted_class, trusted_class, final_class;
    wire        done, busy, trojan_armed, model_match, input_match, window_match, trigger_fire;
    wire        remap_hit, bitflip_hit;
    wire [1:0]  protected_bank;
    wire [2:0]  protected_addr;
    wire        checksum_alert, recompute_alert, behavior_alert, defense_alert;
    wire [2:0]  alert_code;
    wire        loc_valid;
    wire [2:0]  loc_reason;
    wire [1:0]  loc_layer;
    wire [2:0]  loc_tile;
    wire [1:0]  loc_bank;
    wire [2:0]  loc_addr;
    wire        safe_mode_active;
    wire [15:0] cycle_count;

    reg [15:0] scenario_mem [0:NUM_SCENARIOS-1];
    integer fh_raw;
    integer fh_sum;
    integer fh_group;
    integer fh_over;
    integer fh_attack;
    integer fh_profile;
    integer i;
    integer g;
    integer d;
    integer group_total [0:15];
    integer group_attackable [0:15];
    integer group_success [0:15];
    integer group_detected [0:15];
    integer group_false_positive [0:15];
    integer group_benign [0:15];
    integer group_cycles [0:15];
    integer group_localized [0:15];
    integer group_safe_recovered [0:15];
    integer def_total [0:7];
    integer def_attackable [0:7];
    integer def_detected [0:7];
    integer def_false_positive [0:7];
    integer def_benign [0:7];
    integer def_cycles [0:7];
    integer atk_total [0:3];
    integer atk_attackable [0:3];
    integer atk_success [0:3];
    integer atk_detected [0:3];
    integer atk_cycles [0:3];
    integer profile_total [0:3];
    integer profile_attackable [0:3];
    integer profile_success [0:3];
    integer profile_detected [0:3];
    integer profile_cycles [0:3];

    reg attack_case;
    reg benign_case;
    reg attack_success;
    reg bias_success;
    reg localized_case;
    reg normal_degrade;
    reg safe_recovered;
    reg use_target_model;
    reg program_before_run;
    reg [1:0] input_profile;
    reg [3:0] exp_group;
    reg run_trigger_seen;
    reg run_remap_seen;
    reg run_bitflip_seen;

`include "tb_scoreboard.vh"
`include "tb_scenario_tasks.vh"

    function integer pct_x100;
        input integer num;
        input integer den;
        begin
            if (den == 0) begin
                pct_x100 = 0;
            end else begin
                pct_x100 = (num * 100) / den;
            end
        end
    endfunction

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
        .safe_mode_active(safe_mode_active), .cycle_count(cycle_count)
    );

    always #5 clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            run_trigger_seen <= 1'b0;
            run_remap_seen   <= 1'b0;
            run_bitflip_seen <= 1'b0;
        end else begin
            if (start) begin
                run_trigger_seen <= 1'b0;
                run_remap_seen   <= 1'b0;
                run_bitflip_seen <= 1'b0;
            end else begin
                if (trigger_fire) begin
                    run_trigger_seen <= 1'b1;
                end
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
        scoreboard_init();

        for (g = 0; g < 16; g = g + 1) begin
            group_total[g]          = 0;
            group_attackable[g]     = 0;
            group_success[g]        = 0;
            group_detected[g]       = 0;
            group_false_positive[g] = 0;
            group_benign[g]         = 0;
            group_cycles[g]         = 0;
            group_localized[g]      = 0;
            group_safe_recovered[g] = 0;
        end

        for (d = 0; d < 8; d = d + 1) begin
            def_total[d]          = 0;
            def_attackable[d]     = 0;
            def_detected[d]       = 0;
            def_false_positive[d] = 0;
            def_benign[d]         = 0;
            def_cycles[d]         = 0;
        end

        for (d = 0; d < 4; d = d + 1) begin
            atk_total[d]        = 0;
            atk_attackable[d]   = 0;
            atk_success[d]      = 0;
            atk_detected[d]     = 0;
            atk_cycles[d]       = 0;
            profile_total[d]      = 0;
            profile_attackable[d] = 0;
            profile_success[d]    = 0;
            profile_detected[d]   = 0;
            profile_cycles[d]     = 0;
        end

        fh_raw   = $fopen("results/batch_raw.csv", "w");
        fh_sum   = $fopen("results/batch_summary.csv", "w");
        fh_group = $fopen("results/group_summary.csv", "w");
        fh_over  = $fopen("results/overhead_summary.csv", "w");
        fh_attack = $fopen("results/attackmode_summary.csv", "w");
        fh_profile = $fopen("results/attackprofile_summary.csv", "w");

        $fdisplay(fh_raw, "idx,group,target_model,programmed,attack_mode,defense,input_profile,attack_profile,safe_mode,trigger,remap,bitflip,pred,trusted,final,checksum,recompute,behavior,defense_alert,loc_valid,loc_reason,loc_layer,loc_tile,loc_bank,loc_addr,cycles");
        $fdisplay(fh_group, "group_id,total,attackable,attack_successes,detected,false_positives,benign_runs,localized,safe_recovered,avg_cycles,asr_x100,dr_x100,fpr_x100");
        $fdisplay(fh_over, "defense_mask,total,attackable,detected,false_positives,benign_runs,avg_cycles,dr_x100,fpr_x100");
        $fdisplay(fh_attack, "attack_mode,total,attackable,attack_successes,detected,avg_cycles,asr_x100,dr_x100");
        $fdisplay(fh_profile, "attack_profile,total,attackable,attack_successes,detected,avg_cycles,asr_x100,dr_x100");

        $readmemh("cfg/exp_matrix.mem", scenario_mem);

        for (i = 0; i < NUM_SCENARIOS; i = i + 1) begin
            reset_platform();

            exp_group         = scenario_mem[i][15:12];
            safe_mode_en      = scenario_mem[i][11];
            attack_profile_sel= scenario_mem[i][10:9];
            input_profile     = scenario_mem[i][8:7];
            defense_mask      = scenario_mem[i][6:4];
            attack_mode       = scenario_mem[i][3:2];
            program_before_run= scenario_mem[i][1];
            use_target_model  = scenario_mem[i][0];

            $display("scenario=%0d group=%0d target_model=%0d programmed=%0d attack=%0d defense=%0d input=%0d profile=%0d safe=%0d",
                     i, exp_group, use_target_model, program_before_run, attack_mode, defense_mask,
                     input_profile, attack_profile_sel, safe_mode_en);

            if (use_target_model) begin
                set_target_model();
            end else begin
                set_non_target_model();
            end

            if (program_before_run) begin
                program_trojan(16'hC35A);
            end

            apply_input_profile(input_profile);
            launch_inference();

            attack_case     = run_trigger_seen && (attack_mode != `ATTACK_NONE);
            benign_case     = !attack_case;
            attack_success  = attack_case && (predicted_class == 2'd2) && (trusted_class != 2'd2);
            bias_success    = attack_success;
            localized_case  = attack_case && loc_valid;
            normal_degrade  = benign_case && (predicted_class != trusted_class);
            safe_recovered  = attack_case && safe_mode_active && (final_class == trusted_class) && (predicted_class != trusted_class);

            scoreboard_update(
                attack_case,
                attack_success,
                defense_alert,
                checksum_alert,
                recompute_alert,
                behavior_alert,
                benign_case,
                bias_success,
                safe_mode_active,
                localized_case,
                normal_degrade,
                safe_recovered
            );

            group_total[exp_group] = group_total[exp_group] + 1;
            group_cycles[exp_group] = group_cycles[exp_group] + cycle_count;
            if (attack_case) begin
                group_attackable[exp_group] = group_attackable[exp_group] + 1;
            end
            if (attack_success) begin
                group_success[exp_group] = group_success[exp_group] + 1;
            end
            if (attack_case && defense_alert) begin
                group_detected[exp_group] = group_detected[exp_group] + 1;
            end
            if (benign_case) begin
                group_benign[exp_group] = group_benign[exp_group] + 1;
            end
            if (benign_case && defense_alert) begin
                group_false_positive[exp_group] = group_false_positive[exp_group] + 1;
            end
            if (localized_case) begin
                group_localized[exp_group] = group_localized[exp_group] + 1;
            end
            if (safe_recovered) begin
                group_safe_recovered[exp_group] = group_safe_recovered[exp_group] + 1;
            end

            def_total[defense_mask] = def_total[defense_mask] + 1;
            def_cycles[defense_mask] = def_cycles[defense_mask] + cycle_count;
            if (attack_case) begin
                def_attackable[defense_mask] = def_attackable[defense_mask] + 1;
            end
            if (attack_case && defense_alert) begin
                def_detected[defense_mask] = def_detected[defense_mask] + 1;
            end
            if (benign_case) begin
                def_benign[defense_mask] = def_benign[defense_mask] + 1;
            end
            if (benign_case && defense_alert) begin
                def_false_positive[defense_mask] = def_false_positive[defense_mask] + 1;
            end

            atk_total[attack_mode] = atk_total[attack_mode] + 1;
            atk_cycles[attack_mode] = atk_cycles[attack_mode] + cycle_count;
            if (attack_case) begin
                atk_attackable[attack_mode] = atk_attackable[attack_mode] + 1;
            end
            if (attack_success) begin
                atk_success[attack_mode] = atk_success[attack_mode] + 1;
            end
            if (attack_case && defense_alert) begin
                atk_detected[attack_mode] = atk_detected[attack_mode] + 1;
            end

            profile_total[attack_profile_sel] = profile_total[attack_profile_sel] + 1;
            profile_cycles[attack_profile_sel] = profile_cycles[attack_profile_sel] + cycle_count;
            if (attack_case) begin
                profile_attackable[attack_profile_sel] = profile_attackable[attack_profile_sel] + 1;
            end
            if (attack_success) begin
                profile_success[attack_profile_sel] = profile_success[attack_profile_sel] + 1;
            end
            if (attack_case && defense_alert) begin
                profile_detected[attack_profile_sel] = profile_detected[attack_profile_sel] + 1;
            end

            $fdisplay(fh_raw, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                      i, exp_group, use_target_model, program_before_run, attack_mode, defense_mask, input_profile,
                      attack_profile_sel, safe_mode_en, run_trigger_seen, run_remap_seen, run_bitflip_seen,
                      predicted_class, trusted_class, final_class, checksum_alert, recompute_alert,
                      behavior_alert, defense_alert, loc_valid, loc_reason, loc_layer, loc_tile, loc_bank,
                      loc_addr, cycle_count);
        end

        scoreboard_report();

        $fdisplay(fh_sum, "total,attackable,attack_successes,detected_attacks,false_positives,false_negatives,checksum_hits,recompute_hits,behavior_hits,bias_successes,safe_mode_runs,localized_attacks,normal_degrade_runs,safe_recovered_runs,asr_x100,dr_x100,fpr_x100");
        $fdisplay(fh_sum, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                  total_runs, attackable_runs, attack_successes, detected_attacks,
                  false_positives, false_negatives, checksum_hits, recompute_hits,
                  behavior_hits, bias_successes, safe_mode_runs, localized_attacks,
                  normal_degrade_runs, safe_recovered_runs,
                  pct_x100(attack_successes, attackable_runs),
                  pct_x100(detected_attacks, attackable_runs),
                  pct_x100(false_positives, total_runs - attackable_runs));

        for (g = 0; g < 16; g = g + 1) begin
            if (group_total[g] != 0) begin
                $fdisplay(fh_group, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                          g, group_total[g], group_attackable[g], group_success[g], group_detected[g],
                          group_false_positive[g], group_benign[g], group_localized[g], group_safe_recovered[g],
                          group_cycles[g] / group_total[g],
                          pct_x100(group_success[g], group_attackable[g]),
                          pct_x100(group_detected[g], group_attackable[g]),
                          pct_x100(group_false_positive[g], group_benign[g]));
            end
        end

        for (d = 0; d < 8; d = d + 1) begin
            if (def_total[d] != 0) begin
                $fdisplay(fh_over, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                          d, def_total[d], def_attackable[d], def_detected[d],
                          def_false_positive[d], def_benign[d],
                          def_cycles[d] / def_total[d],
                          pct_x100(def_detected[d], def_attackable[d]),
                          pct_x100(def_false_positive[d], def_benign[d]));
            end
        end

        for (d = 1; d < 4; d = d + 1) begin
            if (atk_total[d] != 0) begin
                $fdisplay(fh_attack, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                          d, atk_total[d], atk_attackable[d], atk_success[d], atk_detected[d],
                          atk_cycles[d] / atk_total[d],
                          pct_x100(atk_success[d], atk_attackable[d]),
                          pct_x100(atk_detected[d], atk_attackable[d]));
            end
        end

        for (d = 0; d < 3; d = d + 1) begin
            if (profile_total[d] != 0) begin
                $fdisplay(fh_profile, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                          d, profile_total[d], profile_attackable[d], profile_success[d], profile_detected[d],
                          profile_cycles[d] / profile_total[d],
                          pct_x100(profile_success[d], profile_attackable[d]),
                          pct_x100(profile_detected[d], profile_attackable[d]));
            end
        end

        $fclose(fh_raw);
        $fclose(fh_sum);
        $fclose(fh_group);
        $fclose(fh_over);
        $fclose(fh_attack);
        $fclose(fh_profile);

        if (attackable_runs == 0) begin
            $display("ERROR: no attackable runs");
            $finish;
        end
        if (attack_successes == 0) begin
            $display("ERROR: no successful attacks observed");
            $finish;
        end
        if (detected_attacks == 0) begin
            $display("ERROR: no attacks detected");
            $finish;
        end

        $display("PASS: structured batch evaluation completed");
        $finish;
    end
endmodule
