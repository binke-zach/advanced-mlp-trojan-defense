module pe_mac (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        clear,
    input  wire        en,
    input  wire [7:0]  data_in,
    input  wire [7:0]  weight_in,
    output reg  [19:0] acc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out <= 20'd0;
        end else if (clear) begin
            acc_out <= 20'd0;
        end else if (en) begin
            acc_out <= acc_out + data_in * weight_in;
        end
    end
endmodule
