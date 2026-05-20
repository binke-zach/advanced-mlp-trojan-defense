module mlp2_ctrl (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire       load_done,
    input  wire       core_done,
    output reg        clear_buffers,
    output reg        load_en,
    output reg  [1:0] load_layer_id,
    output reg  [2:0] load_tile_id,
    output reg        core_start,
    output reg        output_valid,
    output reg        busy,
    output reg  [15:0] cycle_count
);
    localparam S_IDLE   = 3'd0;
    localparam S_LOAD1  = 3'd1;
    localparam S_LOAD2  = 3'd2;
    localparam S_START  = 3'd3;
    localparam S_WAIT   = 3'd4;
    localparam S_OUTP   = 3'd5;

    reg [2:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= S_IDLE;
            clear_buffers <= 1'b0;
            load_en       <= 1'b0;
            load_layer_id <= 2'd0;
            load_tile_id  <= 3'd0;
            core_start    <= 1'b0;
            output_valid  <= 1'b0;
            busy          <= 1'b0;
            cycle_count   <= 16'd0;
        end else begin
            clear_buffers <= 1'b0;
            load_en       <= 1'b0;
            core_start    <= 1'b0;
            output_valid  <= 1'b0;

            if (busy) begin
                cycle_count <= cycle_count + 16'd1;
            end

            case (state)
                S_IDLE: begin
                    busy        <= 1'b0;
                    if (start) begin
                        busy          <= 1'b1;
                        cycle_count   <= 16'd0;
                        clear_buffers <= 1'b1;
                        load_layer_id <= 2'd0;
                        load_tile_id  <= 3'd0;
                        state         <= S_LOAD1;
                    end
                end
                S_LOAD1: begin
                    load_en <= 1'b1;
                    if (load_done) begin
                        if (load_tile_id == 3'd3) begin
                            load_layer_id <= 2'd1;
                            load_tile_id  <= 3'd0;
                            state         <= S_LOAD2;
                        end else begin
                            load_tile_id <= load_tile_id + 3'd1;
                        end
                    end
                end
                S_LOAD2: begin
                    load_en <= 1'b1;
                    if (load_done) begin
                        if (load_tile_id == 3'd3) begin
                            state <= S_START;
                        end else begin
                            load_tile_id <= load_tile_id + 3'd1;
                        end
                    end
                end
                S_START: begin
                    core_start <= 1'b1;
                    state      <= S_WAIT;
                end
                S_WAIT: begin
                    if (core_done) begin
                        state <= S_OUTP;
                    end
                end
                S_OUTP: begin
                    busy         <= 1'b0;
                    output_valid <= 1'b1;
                    state        <= S_IDLE;
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
