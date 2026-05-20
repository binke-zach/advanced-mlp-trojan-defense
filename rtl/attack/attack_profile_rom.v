module attack_profile_rom (
    input  wire [1:0] profile_sel,
    output reg  [7:0] shadow_w0,
    output reg  [7:0] shadow_w1,
    output reg  [7:0] shadow_w2,
    output reg  [7:0] shadow_w3,
    output reg  [7:0] bitmask0,
    output reg  [7:0] bitmask1,
    output reg  [7:0] bitmask2,
    output reg  [7:0] bitmask3
);
    always @(*) begin
        shadow_w0 = 8'd8;
        shadow_w1 = 8'd8;
        shadow_w2 = 8'd8;
        shadow_w3 = 8'd8;
        bitmask0  = 8'h03;
        bitmask1  = 8'h01;
        bitmask2  = 8'h03;
        bitmask3  = 8'h01;

        case (profile_sel)
            2'd1: begin
                shadow_w0 = 8'd10;
                shadow_w1 = 8'd9;
                shadow_w2 = 8'd10;
                shadow_w3 = 8'd9;
                bitmask0  = 8'h07;
                bitmask1  = 8'h03;
                bitmask2  = 8'h07;
                bitmask3  = 8'h03;
            end
            2'd2: begin
                shadow_w0 = 8'd12;
                shadow_w1 = 8'd12;
                shadow_w2 = 8'd11;
                shadow_w3 = 8'd11;
                bitmask0  = 8'h0F;
                bitmask1  = 8'h07;
                bitmask2  = 8'h0F;
                bitmask3  = 8'h07;
            end
            default: begin
                shadow_w0 = 8'd8;
                shadow_w1 = 8'd8;
                shadow_w2 = 8'd8;
                shadow_w3 = 8'd8;
                bitmask0  = 8'h03;
                bitmask1  = 8'h01;
                bitmask2  = 8'h03;
                bitmask3  = 8'h01;
            end
        endcase
    end
endmodule
