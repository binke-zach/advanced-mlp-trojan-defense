module mlp2_accel_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
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
    output reg         busy,
    output reg         done,
    output wire [19:0] y0,
    output wire [19:0] y1,
    output wire [19:0] y2,
    output wire [19:0] y3,
    output wire [7:0]  h0,
    output wire [7:0]  h1,
    output wire [7:0]  h2,
    output wire [7:0]  h3
);
    localparam S_IDLE   = 2'd0;
    localparam S_RUN_L1 = 2'd1;
    localparam S_RUN_L2 = 2'd2;

    reg [1:0] state;
    reg start_l1;
    reg start_l2;

    wire [19:0] l1_y0, l1_y1, l1_y2, l1_y3;
    wire [19:0] l2_y0, l2_y1, l2_y2, l2_y3;
    wire l1_done, l2_done;
    wire [7:0] l1_q0, l1_q1, l1_q2, l1_q3;

    fc_tile_compute fc_l1 (
        .clk(clk), .rst_n(rst_n), .start(start_l1),
        .in0(x0), .in1(x1), .in2(x2), .in3(x3),
        .w00(l1_w00), .w01(l1_w01), .w02(l1_w02), .w03(l1_w03),
        .w10(l1_w10), .w11(l1_w11), .w12(l1_w12), .w13(l1_w13),
        .w20(l1_w20), .w21(l1_w21), .w22(l1_w22), .w23(l1_w23),
        .w30(l1_w30), .w31(l1_w31), .w32(l1_w32), .w33(l1_w33),
        .busy(), .done(l1_done), .y0(l1_y0), .y1(l1_y1), .y2(l1_y2), .y3(l1_y3)
    );

    quant_clip clip0 (.value_in(l1_y0), .value_out(l1_q0));
    quant_clip clip1 (.value_in(l1_y1), .value_out(l1_q1));
    quant_clip clip2 (.value_in(l1_y2), .value_out(l1_q2));
    quant_clip clip3 (.value_in(l1_y3), .value_out(l1_q3));

    activation_buffer hidden_buf (
        .clk(clk), .rst_n(rst_n), .clear(1'b0), .write_en(l1_done),
        .in0(l1_q0), .in1(l1_q1), .in2(l1_q2), .in3(l1_q3),
        .out0(h0), .out1(h1), .out2(h2), .out3(h3)
    );

    fc_tile_compute fc_l2 (
        .clk(clk), .rst_n(rst_n), .start(start_l2),
        .in0(h0), .in1(h1), .in2(h2), .in3(h3),
        .w00(l2_w00), .w01(l2_w01), .w02(l2_w02), .w03(l2_w03),
        .w10(l2_w10), .w11(l2_w11), .w12(l2_w12), .w13(l2_w13),
        .w20(l2_w20), .w21(l2_w21), .w22(l2_w22), .w23(l2_w23),
        .w30(l2_w30), .w31(l2_w31), .w32(l2_w32), .w33(l2_w33),
        .busy(), .done(l2_done), .y0(l2_y0), .y1(l2_y1), .y2(l2_y2), .y3(l2_y3)
    );

    assign y0 = l2_y0;
    assign y1 = l2_y1;
    assign y2 = l2_y2;
    assign y3 = l2_y3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            busy     <= 1'b0;
            done     <= 1'b0;
            start_l1 <= 1'b0;
            start_l2 <= 1'b0;
        end else begin
            done     <= 1'b0;
            start_l1 <= 1'b0;
            start_l2 <= 1'b0;

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy     <= 1'b1;
                        start_l1 <= 1'b1;
                        state    <= S_RUN_L1;
                    end
                end
                S_RUN_L1: begin
                    busy <= 1'b1;
                    if (l1_done) begin
                        start_l2 <= 1'b1;
                        state    <= S_RUN_L2;
                    end
                end
                S_RUN_L2: begin
                    busy <= 1'b1;
                    if (l2_done) begin
                        busy  <= 1'b0;
                        done  <= 1'b1;
                        state <= S_IDLE;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
