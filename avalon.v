module avalon (
    input  wire clk,
    input  wire resetn,
    input  wire ready,
    output reg  valid,
    output reg [7:0] data
);

    // Estados
    localparam IDLE = 2'd0,
               D4   = 2'd1,
               D5   = 2'd2,
               D6   = 2'd3;

    reg [1:0] state, next_state;
    reg ready_d;
    reg valid_hold;

    // Sequencial
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state       <= IDLE;
            ready_d     <= 0;
            valid_hold  <= 0;
        end else begin
            state       <= next_state;
            ready_d     <= ready;
            valid_hold  <= ready | valid_hold; // mantém valid 1 por 1 ciclo mesmo se ready caiu
            if (ready) valid_hold <= 0; // reset valid_hold se ready voltou a 1
        end
    end

    // Próximo estado
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (ready) next_state = D4;
            D4:   if (ready) next_state = D5;
            D5:   if (ready) next_state = D6;
            D6:   if (ready) next_state = IDLE;
        endcase
    end

    // Saídas
    always @(*) begin
        valid = 0;
        data = 8'd0;
        case (state)
            D4: begin valid = ready_d | valid_hold; data = 8'd4; end
            D5: begin valid = ready_d | valid_hold; data = 8'd5; end
            D6: begin valid = ready_d | valid_hold; data = 8'd6; end
        endcase
    end

endmodule
