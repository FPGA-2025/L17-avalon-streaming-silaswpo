module avalon (
    input wire clk,
    input wire resetn,
    output reg valid,
    input wire ready,
    output reg [7:0] data
);

    // Codificação dos estados
    parameter S_IDLE        = 3'd0;
    parameter S_VALID_4     = 3'd1;
    parameter S_VALID_5     = 3'd2;
    parameter S_VALID_6     = 3'd3;
    parameter S_HOLD_5      = 3'd4;
    parameter S_HOLD_6      = 3'd5;
    parameter S_DONE        = 3'd6;

    reg [2:0] state, next_state;

    // Lógica sequencial
always @(posedge clk or negedge resetn) begin
    if (!resetn)
        state <= S_IDLE;
    else
        state <= next_state;
end

    // Lógica de transição de estado
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (ready)
                    next_state = S_VALID_4;
            end
            S_VALID_4: begin
                if (ready)
                    next_state = S_VALID_5;
                else
                    next_state = S_HOLD_5;
            end
            S_VALID_5: begin
                if (ready)
                    next_state = S_VALID_6;
                else
                    next_state = S_HOLD_6;
            end
            S_VALID_6: begin           
                next_state = S_DONE;
            end
            S_HOLD_5: begin
                if (ready)
                    next_state = S_VALID_5;
                else
                    next_state = S_HOLD_5; // um ciclo
            end
            S_HOLD_6: begin
                if (ready)
                    next_state = S_VALID_6;
                else
                    next_state = S_HOLD_6; // um ciclo
            end
            S_DONE: begin
                next_state = S_DONE;
            end
        endcase
    end

    // Saída: Moore 
    always @(*) begin
            valid = 0;
            case (state)
                S_VALID_4: begin
                    valid = 1;
                    data = 4;
                end
                S_VALID_5: begin
                    valid = 1;
                    data = 5;
                end
                S_VALID_6: begin
                    valid = 1;
                    data = 6;
                end
                default: begin
                    valid = 0;
                end
            endcase
        end

endmodule
