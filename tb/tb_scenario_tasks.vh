    task reset_platform;
    begin
        start <= 1'b0;
        program_en <= 1'b0;
        program_key <= 16'd0;
        attack_mode <= `ATTACK_NONE;
        defense_mask <= `DEF_NONE;
        safe_mode_en <= 1'b0;
        attack_profile_sel <= 2'd0;
        @(negedge clk);
        rst_n <= 1'b0;
        @(negedge clk);
        @(negedge clk);
        rst_n <= 1'b1;
        @(negedge clk);
    end
    endtask

    task program_trojan;
        input [15:0] key;
        begin
            @(negedge clk);
            program_key <= key;
            program_en  <= 1'b1;
            @(negedge clk);
            program_en  <= 1'b0;
            program_key <= 16'd0;
        end
    endtask

    task set_target_model;
        begin
            l1_w00 <= 8'd1; l1_w01 <= 8'd2; l1_w02 <= 8'd3; l1_w03 <= 8'd4;
            l1_w10 <= 8'd2; l1_w11 <= 8'd1; l1_w12 <= 8'd0; l1_w13 <= 8'd1;
            l1_w20 <= 8'd1; l1_w21 <= 8'd1; l1_w22 <= 8'd1; l1_w23 <= 8'd1;
            l1_w30 <= 8'd4; l1_w31 <= 8'd3; l1_w32 <= 8'd2; l1_w33 <= 8'd1;

            l2_w00 <= 8'd1; l2_w01 <= 8'd2; l2_w02 <= 8'd3; l2_w03 <= 8'd4;
            l2_w10 <= 8'd2; l2_w11 <= 8'd1; l2_w12 <= 8'd0; l2_w13 <= 8'd1;
            l2_w20 <= 8'd1; l2_w21 <= 8'd1; l2_w22 <= 8'd1; l2_w23 <= 8'd1;
            l2_w30 <= 8'd4; l2_w31 <= 8'd3; l2_w32 <= 8'd2; l2_w33 <= `TARGET_MODEL_W33;
        end
    endtask

    task set_non_target_model;
        begin
            set_target_model();
            l2_w33 <= `NONTARGET_MODEL_W33;
        end
    endtask

    task apply_input_profile;
        input [1:0] profile;
        begin
            case (profile)
                2'd0: begin
                    x0 <= 8'd1; x1 <= 8'd2; x2 <= 8'd3; x3 <= 8'd4;
                end
                2'd1: begin
                    x0 <= `TARGET_INPUT_X0; x1 <= 8'd2; x2 <= 8'd3; x3 <= 8'd1;
                end
                2'd2: begin
                    x0 <= `TARGET_INPUT_X0; x1 <= 8'd1; x2 <= 8'd2; x3 <= `TARGET_INPUT_X3;
                end
                default: begin
                    x0 <= `TARGET_INPUT_X0; x1 <= 8'd4; x2 <= 8'd0; x3 <= `TARGET_INPUT_X3;
                end
            endcase
        end
    endtask

    task launch_inference;
        integer timeout_ctr;
    begin
        @(negedge clk);
        start <= 1'b1;
        @(negedge clk);
        start <= 1'b0;
        timeout_ctr = 0;
        while ((done !== 1'b1) && (timeout_ctr < 200)) begin
            @(negedge clk);
            timeout_ctr = timeout_ctr + 1;
        end
        if (done !== 1'b1) begin
            $display("ERROR: inference timeout at time=%0t", $time);
            $finish;
        end
        while (busy !== 1'b0) begin
            @(negedge clk);
        end
        @(negedge clk);
    end
    endtask
