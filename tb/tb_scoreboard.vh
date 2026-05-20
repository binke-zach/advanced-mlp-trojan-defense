    integer total_runs;
    integer attackable_runs;
    integer attack_successes;
    integer detected_attacks;
    integer false_positives;
    integer false_negatives;
    integer checksum_hits;
    integer recompute_hits;
    integer behavior_hits;
    integer bias_successes;
    integer safe_mode_runs;
    integer localized_attacks;
    integer normal_degrade_runs;
    integer safe_recovered_runs;

    task scoreboard_init;
    begin
        total_runs        = 0;
        attackable_runs   = 0;
        attack_successes  = 0;
        detected_attacks  = 0;
        false_positives   = 0;
        false_negatives   = 0;
        checksum_hits     = 0;
        recompute_hits    = 0;
        behavior_hits     = 0;
        bias_successes    = 0;
        safe_mode_runs    = 0;
        localized_attacks = 0;
        normal_degrade_runs = 0;
        safe_recovered_runs = 0;
    end
    endtask

    task scoreboard_update;
        input attack_case;
        input attack_success;
        input detected;
        input checksum_hit;
        input recompute_hit;
        input behavior_hit;
        input benign_case;
        input bias_success;
        input safe_active;
        input localized_case;
        input normal_degrade;
        input safe_recovered;
    begin
        total_runs = total_runs + 1;
        if (attack_case) begin
            attackable_runs = attackable_runs + 1;
        end
        if (attack_success) begin
            attack_successes = attack_successes + 1;
        end
        if (detected && attack_case) begin
            detected_attacks = detected_attacks + 1;
        end
        if (attack_case && !detected) begin
            false_negatives = false_negatives + 1;
        end
        if (benign_case && detected) begin
            false_positives = false_positives + 1;
        end
        if (attack_case && checksum_hit) begin
            checksum_hits = checksum_hits + 1;
        end
        if (attack_case && recompute_hit) begin
            recompute_hits = recompute_hits + 1;
        end
        if (attack_case && behavior_hit) begin
            behavior_hits = behavior_hits + 1;
        end
        if (bias_success) begin
            bias_successes = bias_successes + 1;
        end
        if (safe_active) begin
            safe_mode_runs = safe_mode_runs + 1;
        end
        if (localized_case) begin
            localized_attacks = localized_attacks + 1;
        end
        if (normal_degrade) begin
            normal_degrade_runs = normal_degrade_runs + 1;
        end
        if (safe_recovered) begin
            safe_recovered_runs = safe_recovered_runs + 1;
        end
    end
    endtask

    task scoreboard_report;
    begin
        $display("");
        $display("===== Structured Batch Summary =====");
        $display("Total runs         : %0d", total_runs);
        $display("Attackable runs    : %0d", attackable_runs);
        $display("Attack successes   : %0d", attack_successes);
        $display("Detected attacks   : %0d", detected_attacks);
        $display("False positives    : %0d", false_positives);
        $display("False negatives    : %0d", false_negatives);
        $display("Checksum hits      : %0d", checksum_hits);
        $display("Recompute hits     : %0d", recompute_hits);
        $display("Behavior hits      : %0d", behavior_hits);
        $display("Bias successes     : %0d", bias_successes);
        $display("Safe mode runs     : %0d", safe_mode_runs);
        $display("Localized attacks  : %0d", localized_attacks);
        $display("Normal degrade     : %0d", normal_degrade_runs);
        $display("Safe recoveries    : %0d", safe_recovered_runs);
    end
    endtask
