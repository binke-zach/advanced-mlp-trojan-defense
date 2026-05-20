module attack_mux (
    input  wire [1:0] attack_mode,
    input  wire       remap_hit,
    input  wire       bitflip_hit,
    input  wire [7:0] legal0,
    input  wire [7:0] legal1,
    input  wire [7:0] legal2,
    input  wire [7:0] legal3,
    input  wire [7:0] shadow0,
    input  wire [7:0] shadow1,
    input  wire [7:0] shadow2,
    input  wire [7:0] shadow3,
    input  wire [7:0] flip0,
    input  wire [7:0] flip1,
    input  wire [7:0] flip2,
    input  wire [7:0] flip3,
    output reg  [7:0] out0,
    output reg  [7:0] out1,
    output reg  [7:0] out2,
    output reg  [7:0] out3,
    output wire       attack_applied
);
    localparam [1:0] ATTACK_ADDR_REMAP = 2'd1;
    localparam [1:0] ATTACK_BITFLIP    = 2'd2;
    localparam [1:0] ATTACK_BOTH       = 2'd3;

    assign attack_applied = remap_hit || bitflip_hit;

    always @(*) begin
        out0 = legal0;
        out1 = legal1;
        out2 = legal2;
        out3 = legal3;

        case (attack_mode)
            ATTACK_ADDR_REMAP: begin
                if (remap_hit) begin
                    out0 = shadow0;
                    out1 = shadow1;
                    out2 = shadow2;
                    out3 = shadow3;
                end
            end
            ATTACK_BITFLIP: begin
                if (bitflip_hit) begin
                    out0 = flip0;
                    out1 = flip1;
                    out2 = flip2;
                    out3 = flip3;
                end
            end
            ATTACK_BOTH: begin
                if (remap_hit) begin
                    out0 = shadow0;
                    out1 = shadow1;
                    out2 = shadow2;
                    out3 = shadow3;
                end
                if (bitflip_hit) begin
                    if (remap_hit) begin
                        out0 = shadow0 ^ (legal0 ^ flip0);
                        out1 = shadow1 ^ (legal1 ^ flip1);
                        out2 = shadow2 ^ (legal2 ^ flip2);
                        out3 = shadow3 ^ (legal3 ^ flip3);
                    end else begin
                        out0 = flip0;
                        out1 = flip1;
                        out2 = flip2;
                        out3 = flip3;
                    end
                end
            end
            default: begin
                out0 = legal0;
                out1 = legal1;
                out2 = legal2;
                out3 = legal3;
            end
        endcase
    end
endmodule
