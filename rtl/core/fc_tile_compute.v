module fc_tile_compute (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  in0,
    input  wire [7:0]  in1,
    input  wire [7:0]  in2,
    input  wire [7:0]  in3,
    input  wire [7:0]  w00, input wire [7:0] w01, input wire [7:0] w02, input wire [7:0] w03,
    input  wire [7:0]  w10, input wire [7:0] w11, input wire [7:0] w12, input wire [7:0] w13,
    input  wire [7:0]  w20, input wire [7:0] w21, input wire [7:0] w22, input wire [7:0] w23,
    input  wire [7:0]  w30, input wire [7:0] w31, input wire [7:0] w32, input wire [7:0] w33,
    output reg         busy,
    output reg         done,
    output wire [19:0] y0,
    output wire [19:0] y1,
    output wire [19:0] y2,
    output wire [19:0] y3
);
    reg [1:0] col_idx;
    reg [1:0] state;
    reg [7:0] current_data;
    reg [7:0] current_w0;
    reg [7:0] current_w1;
    reg [7:0] current_w2;
    reg [7:0] current_w3;

    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_OUT  = 2'd2;

    wire clear_pe;
    wire en_pe;

    assign clear_pe = (state == S_IDLE) && start;
    assign en_pe    = (state == S_RUN);

    pe_mac pe0 (
        .clk(clk), .rst_n(rst_n), .clear(clear_pe), .en(en_pe),
        .data_in(current_data), .weight_in(current_w0), .acc_out(y0)
    );
    pe_mac pe1 (
        .clk(clk), .rst_n(rst_n), .clear(clear_pe), .en(en_pe),
        .data_in(current_data), .weight_in(current_w1), .acc_out(y1)
    );
    pe_mac pe2 (
        .clk(clk), .rst_n(rst_n), .clear(clear_pe), .en(en_pe),
        .data_in(current_data), .weight_in(current_w2), .acc_out(y2)
    );
    pe_mac pe3 (
        .clk(clk), .rst_n(rst_n), .clear(clear_pe), .en(en_pe),
        .data_in(current_data), .weight_in(current_w3), .acc_out(y3)
    );

    always @(*) begin
        current_data = 8'd0;
        current_w0   = 8'd0;
        current_w1   = 8'd0;
        current_w2   = 8'd0;
        current_w3   = 8'd0;

        case (col_idx)
            2'd0: begin
                current_data = in0;
                current_w0   = w00; current_w1 = w10; current_w2 = w20; current_w3 = w30;
            end
            2'd1: begin
                current_data = in1;
                current_w0   = w01; current_w1 = w11; current_w2 = w21; current_w3 = w31;
            end
            2'd2: begin
                current_data = in2;
                current_w0   = w02; current_w1 = w12; current_w2 = w22; current_w3 = w32;
            end
            default: begin
                current_data = in3;
                current_w0   = w03; current_w1 = w13; current_w2 = w23; current_w3 = w33;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_idx <= 2'd0;
            state   <= S_IDLE;
            busy    <= 1'b0;
            done    <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy    <= 1'b1;
                        col_idx <= 2'd0;
                        state   <= S_RUN;
                    end
                end
                S_RUN: begin
                    busy <= 1'b1;
                    if (col_idx == 2'd3) begin
                        state <= S_OUT;
                    end else begin
                        col_idx <= col_idx + 2'd1;
                    end
                end
                S_OUT: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
