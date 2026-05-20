module lfsr16 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [15:0] seed,
    output reg  [15:0] value
);
    wire feedback;

    assign feedback = value[15] ^ value[13] ^ value[12] ^ value[10];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value <= seed;
        end else if (en) begin
            value <= {value[14:0], feedback};
        end
    end
endmodule
