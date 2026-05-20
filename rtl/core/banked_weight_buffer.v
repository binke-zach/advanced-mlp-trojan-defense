module banked_weight_buffer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clear,
    input  wire        write_valid,
    input  wire [1:0]  layer_id,
    input  wire [2:0]  tile_id,
    input  wire [1:0]  bank_id,
    input  wire [7:0]  d0,
    input  wire [7:0]  d1,
    input  wire [7:0]  d2,
    input  wire [7:0]  d3,
    output reg  [7:0]  l1_t0_w0, output reg [7:0] l1_t0_w1, output reg [7:0] l1_t0_w2, output reg [7:0] l1_t0_w3,
    output reg  [7:0]  l1_t1_w0, output reg [7:0] l1_t1_w1, output reg [7:0] l1_t1_w2, output reg [7:0] l1_t1_w3,
    output reg  [7:0]  l1_t2_w0, output reg [7:0] l1_t2_w1, output reg [7:0] l1_t2_w2, output reg [7:0] l1_t2_w3,
    output reg  [7:0]  l1_t3_w0, output reg [7:0] l1_t3_w1, output reg [7:0] l1_t3_w2, output reg [7:0] l1_t3_w3,
    output reg  [7:0]  l2_t0_w0, output reg [7:0] l2_t0_w1, output reg [7:0] l2_t0_w2, output reg [7:0] l2_t0_w3,
    output reg  [7:0]  l2_t1_w0, output reg [7:0] l2_t1_w1, output reg [7:0] l2_t1_w2, output reg [7:0] l2_t1_w3,
    output reg  [7:0]  l2_t2_w0, output reg [7:0] l2_t2_w1, output reg [7:0] l2_t2_w2, output reg [7:0] l2_t2_w3,
    output reg  [7:0]  l2_t3_w0, output reg [7:0] l2_t3_w1, output reg [7:0] l2_t3_w2, output reg [7:0] l2_t3_w3
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            l1_t0_w0 <= 8'd0; l1_t0_w1 <= 8'd0; l1_t0_w2 <= 8'd0; l1_t0_w3 <= 8'd0;
            l1_t1_w0 <= 8'd0; l1_t1_w1 <= 8'd0; l1_t1_w2 <= 8'd0; l1_t1_w3 <= 8'd0;
            l1_t2_w0 <= 8'd0; l1_t2_w1 <= 8'd0; l1_t2_w2 <= 8'd0; l1_t2_w3 <= 8'd0;
            l1_t3_w0 <= 8'd0; l1_t3_w1 <= 8'd0; l1_t3_w2 <= 8'd0; l1_t3_w3 <= 8'd0;
            l2_t0_w0 <= 8'd0; l2_t0_w1 <= 8'd0; l2_t0_w2 <= 8'd0; l2_t0_w3 <= 8'd0;
            l2_t1_w0 <= 8'd0; l2_t1_w1 <= 8'd0; l2_t1_w2 <= 8'd0; l2_t1_w3 <= 8'd0;
            l2_t2_w0 <= 8'd0; l2_t2_w1 <= 8'd0; l2_t2_w2 <= 8'd0; l2_t2_w3 <= 8'd0;
            l2_t3_w0 <= 8'd0; l2_t3_w1 <= 8'd0; l2_t3_w2 <= 8'd0; l2_t3_w3 <= 8'd0;
        end else if (clear) begin
            l1_t0_w0 <= 8'd0; l1_t0_w1 <= 8'd0; l1_t0_w2 <= 8'd0; l1_t0_w3 <= 8'd0;
            l1_t1_w0 <= 8'd0; l1_t1_w1 <= 8'd0; l1_t1_w2 <= 8'd0; l1_t1_w3 <= 8'd0;
            l1_t2_w0 <= 8'd0; l1_t2_w1 <= 8'd0; l1_t2_w2 <= 8'd0; l1_t2_w3 <= 8'd0;
            l1_t3_w0 <= 8'd0; l1_t3_w1 <= 8'd0; l1_t3_w2 <= 8'd0; l1_t3_w3 <= 8'd0;
            l2_t0_w0 <= 8'd0; l2_t0_w1 <= 8'd0; l2_t0_w2 <= 8'd0; l2_t0_w3 <= 8'd0;
            l2_t1_w0 <= 8'd0; l2_t1_w1 <= 8'd0; l2_t1_w2 <= 8'd0; l2_t1_w3 <= 8'd0;
            l2_t2_w0 <= 8'd0; l2_t2_w1 <= 8'd0; l2_t2_w2 <= 8'd0; l2_t2_w3 <= 8'd0;
            l2_t3_w0 <= 8'd0; l2_t3_w1 <= 8'd0; l2_t3_w2 <= 8'd0; l2_t3_w3 <= 8'd0;
        end else if (write_valid) begin
            if (layer_id == 2'd0) begin
                case (tile_id)
                    3'd0: begin l1_t0_w0 <= d0; l1_t0_w1 <= d1; l1_t0_w2 <= d2; l1_t0_w3 <= d3; end
                    3'd1: begin l1_t1_w0 <= d0; l1_t1_w1 <= d1; l1_t1_w2 <= d2; l1_t1_w3 <= d3; end
                    3'd2: begin l1_t2_w0 <= d0; l1_t2_w1 <= d1; l1_t2_w2 <= d2; l1_t2_w3 <= d3; end
                    default: begin l1_t3_w0 <= d0; l1_t3_w1 <= d1; l1_t3_w2 <= d2; l1_t3_w3 <= d3; end
                endcase
            end else begin
                case (tile_id)
                    3'd0: begin l2_t0_w0 <= d0; l2_t0_w1 <= d1; l2_t0_w2 <= d2; l2_t0_w3 <= d3; end
                    3'd1: begin l2_t1_w0 <= d0; l2_t1_w1 <= d1; l2_t1_w2 <= d2; l2_t1_w3 <= d3; end
                    3'd2: begin l2_t2_w0 <= d0; l2_t2_w1 <= d1; l2_t2_w2 <= d2; l2_t2_w3 <= d3; end
                    default: begin l2_t3_w0 <= d0; l2_t3_w1 <= d1; l2_t3_w2 <= d2; l2_t3_w3 <= d3; end
                endcase
            end
        end
    end
endmodule
