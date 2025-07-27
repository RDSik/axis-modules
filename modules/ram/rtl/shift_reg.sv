/* verilator lint_off TIMESCALEMOD */
module shift_reg #(
    parameter logic RESET_EN   = 1,
    parameter int   DATA_WIDTH = 16,
    parameter int   DELAY      = 16,
    parameter int   SEL_WIDTH  = $clog2(DELAY)
) (
    input  logic                  clk_i,
    input  logic                  rstn_i,
    input  logic                  en_i,
    input  logic [ SEL_WIDTH-1:0] sel_i,
    input  logic [DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH-1:0] data_o
);

    if (DELAY == 0) begin : g_delay_zero
        assign data_o = data_i;
    end else if (DELAY == 1) begin : g_delay_one
        if (RESET_EN) begin : g_reset
            always_ff @(posedge clk_i) begin
                if (~rstn_i) begin
                    data_o <= '0;
                end else if (en_i) begin
                    data_o <= data_i;
                end
            end
        end else begin : g_none_reset
            always_ff @(posedge clk_i) begin
                if (en_i) begin
                    data_o <= data_i;
                end
            end
        end
    end else begin : g_delay_many
        logic [DELAY-1:0] delay[DATA_WIDTH];

        for (genvar i = 0; i < DATA_WIDTH; i++) begin : g_shift_reg
            if (RESET_EN) begin : g_reset
                always_ff @(posedge clk_i) begin
                    if (~rstn_i) begin
                        delay[i] <= '0;
                    end else if (en_i) begin
                        delay[i] <= {delay[i][DELAY-2:0], data_i[i]};
                    end
                end
            end else begin : g_none_reset
                always_ff @(posedge clk_i) begin
                    if (en_i) begin
                        delay[i] <= {delay[i][DELAY-2:0], data_i[i]};
                    end
                end
            end

            assign data_o[i] = delay[i][sel_i];
        end
    end

endmodule
