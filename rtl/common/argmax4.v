module argmax4 (
    input  wire [19:0] a0,
    input  wire [19:0] a1,
    input  wire [19:0] a2,
    input  wire [19:0] a3,
    output reg  [1:0]  cls
);
    reg [19:0] best;

    always @(*) begin
        best = a0;
        cls  = 2'd0;
        if (a1 > best) begin
            best = a1;
            cls  = 2'd1;
        end
        if (a2 > best) begin
            best = a2;
            cls  = 2'd2;
        end
        if (a3 > best) begin
            cls = 2'd3;
        end
    end
endmodule
