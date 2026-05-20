module quant_clip (
    input  wire [19:0] value_in,
    output reg  [7:0]  value_out
);
    always @(*) begin
        if (value_in > 20'd255) begin
            value_out = 8'hFF;
        end else begin
            value_out = value_in[7:0];
        end
    end
endmodule
