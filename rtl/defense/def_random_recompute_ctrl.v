module def_random_recompute_ctrl (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        compare_en,
    input  wire        defense_enable,
    input  wire [19:0] observed_y2,
    input  wire [19:0] trusted_y2,
    input  wire [1:0]  observed_class,
    input  wire [1:0]  trusted_class,
    output reg         sample_hit,
    output reg         recompute_alert,
    output wire [15:0] lfsr_state
);
    wire [15:0] lfsr_value;

    lfsr16 lfsr_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(compare_en),
        .seed(16'h1ACE),
        .value(lfsr_value)
    );

    assign lfsr_state = lfsr_value;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_hit       <= 1'b0;
            recompute_alert  <= 1'b0;
        end else if (compare_en) begin
            sample_hit      <= defense_enable && (lfsr_value[1] || lfsr_value[0]);
            recompute_alert <= defense_enable && (lfsr_value[1] || lfsr_value[0]) &&
                               ((observed_y2 != trusted_y2) || (observed_class != trusted_class));
        end else begin
            sample_hit      <= 1'b0;
            recompute_alert <= 1'b0;
        end
    end
endmodule
