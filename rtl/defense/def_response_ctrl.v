module def_response_ctrl (
    input  wire       defense_alert,
    input  wire       safe_mode_en,
    input  wire [1:0] predicted_class,
    input  wire [1:0] trusted_class,
    output wire [1:0] final_class,
    output wire       safe_mode_active
);
    assign safe_mode_active = safe_mode_en && defense_alert;
    assign final_class = safe_mode_active ? trusted_class : predicted_class;
endmodule
