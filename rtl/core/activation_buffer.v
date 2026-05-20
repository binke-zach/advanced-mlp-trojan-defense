module activation_buffer (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       clear,
    input  wire       write_en,
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire [7:0] in2,
    input  wire [7:0] in3,
    output reg  [7:0] out0,
    output reg  [7:0] out1,
    output reg  [7:0] out2,
    output reg  [7:0] out3
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out0 <= 8'd0;
            out1 <= 8'd0;
            out2 <= 8'd0;
            out3 <= 8'd0;
        end else if (clear) begin
            out0 <= 8'd0;
            out1 <= 8'd0;
            out2 <= 8'd0;
            out3 <= 8'd0;
        end else if (write_en) begin
            out0 <= in0;
            out1 <= in1;
            out2 <= in2;
            out3 <= in3;
        end
    end
endmodule
