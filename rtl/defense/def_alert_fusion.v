module def_alert_fusion (
    input  wire [2:0] defense_mask,
    input  wire       checksum_alert,
    input  wire       recompute_alert,
    input  wire       behavior_alert,
    output wire       defense_alert,
    output reg  [2:0] alert_code
);
    assign defense_alert =
        (defense_mask[0] && checksum_alert) ||
        (defense_mask[1] && recompute_alert) ||
        (defense_mask[2] && behavior_alert);

    always @(*) begin
        alert_code = 3'b000;
        if (checksum_alert) begin
            alert_code = 3'b001;
        end
        if (recompute_alert) begin
            alert_code = 3'b010;
        end
        if (behavior_alert) begin
            alert_code = 3'b100;
        end
    end
endmodule
