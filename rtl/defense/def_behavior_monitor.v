module def_behavior_monitor (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        load_en,
    input  wire [1:0]  layer_id,
    input  wire [2:0]  tile_id,
    input  wire [1:0]  actual_bank,
    input  wire [2:0]  actual_addr,
    input  wire        done,
    output reg         seq_alert,
    output reg         latency_alert,
    output reg         addr_alert_ext,
    output wire        behavior_alert
);
    localparam [1:0] EXPECTED_LAYER = 2'd1;
    localparam [2:0] EXPECTED_TILE  = 3'd2;
    localparam [1:0] EXPECTED_BANK  = 2'd0;
    localparam [2:0] EXPECTED_ADDR  = 3'd2;
    localparam [15:0] MAX_CYCLES    = 16'd40;

    reg [1:0] expected_layer;
    reg [2:0] expected_tile;
    reg [15:0] cycle_ctr;

    assign behavior_alert = seq_alert || latency_alert || addr_alert_ext;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            expected_layer <= 2'd0;
            expected_tile  <= 3'd0;
            cycle_ctr      <= 16'd0;
            seq_alert      <= 1'b0;
            latency_alert  <= 1'b0;
            addr_alert_ext <= 1'b0;
        end else begin
            if (start) begin
                expected_layer <= 2'd0;
                expected_tile  <= 3'd0;
                cycle_ctr      <= 16'd0;
                seq_alert      <= 1'b0;
                latency_alert  <= 1'b0;
                addr_alert_ext <= 1'b0;
            end

            if (load_en || !done) begin
                cycle_ctr <= cycle_ctr + 16'd1;
            end

            if (load_en) begin
                if ((layer_id == EXPECTED_LAYER) && (tile_id == EXPECTED_TILE)) begin
                    if ((actual_bank != EXPECTED_BANK) || (actual_addr != EXPECTED_ADDR)) begin
                        addr_alert_ext <= 1'b1;
                    end
                end

                if (expected_tile == 3'd3) begin
                    expected_tile  <= 3'd0;
                    expected_layer <= expected_layer + 2'd1;
                end else begin
                    expected_tile <= expected_tile + 3'd1;
                end
            end

            if (done && (cycle_ctr > MAX_CYCLES)) begin
                latency_alert <= 1'b1;
            end
        end
    end
endmodule
