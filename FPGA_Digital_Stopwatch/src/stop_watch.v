module stopwatch_professional (
    input clk,
    input start,
    input stop,
    input reset,
    output [3:0] sec_ones,
    output [3:0] sec_tens,
    output [3:0] min_ones,
    output [3:0] min_tens,
    output [3:0] hr_ones,
    output [3:0] hr_tens
);

    // FSM State Definitions
    parameter IDLE    = 2'b00;
    parameter RUNNING = 2'b01;
    parameter STOPPED = 2'b10;

    reg [1:0] state, next_state;

    // Counter Registers
    reg [3:0] s_ones, s_tens;
    reg [3:0] m_ones, m_tens;
    reg [3:0] h_ones, h_tens;

    // Clock divider for 1Hz tick from 100MHz clock
    reg [26:0] clk_divider_count;
    localparam CLOCK_DIVIDER_VALUE = 100_000_000;
    
    // The 1-second tick is generated when the divider reaches its max value
    wire tick = (clk_divider_count == CLOCK_DIVIDER_VALUE - 1);
    
    always @(*) begin
        case(state)
            IDLE:    next_state = start ? RUNNING : IDLE;
            RUNNING: next_state = reset ? IDLE : (stop ? STOPPED : RUNNING);
            STOPPED: next_state = reset ? IDLE : (start ? RUNNING : STOPPED);
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset || state == IDLE) begin
            clk_divider_count <= 0;
        end else if (state == RUNNING) begin
            if (tick)
                clk_divider_count <= 0;
            else
                clk_divider_count <= clk_divider_count + 1;
        end
        // In the STOPPED state, nothing happens, so the count is held.
    end

    // Create clear, explicit enable signals for each counter stage
    wire inc_s_tens = tick && (s_ones == 9);
    wire inc_m_ones = inc_s_tens && (s_tens == 5); // When 59s -> 00s
    wire inc_m_tens = inc_m_ones && (m_ones == 9);
    wire inc_h_ones = inc_m_tens && (m_tens == 5); // When 59m -> 00m
    wire inc_h_tens = inc_h_ones && (h_ones == 9);

    // Sequential Logic for FSM state and Counters
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            s_ones <= 0; s_tens <= 0;
            m_ones <= 0; m_tens <= 0;
            h_ones <= 0; h_tens <= 0;
        end else begin
            state <= next_state;
            
            if (state == IDLE) begin
                s_ones <= 0; s_tens <= 0;
                m_ones <= 0; m_tens <= 0;
                h_ones <= 0; h_tens <= 0;
            end else if (state == RUNNING) begin
                // Each counter updates independently based on its own enable signal
                if (tick)       s_ones <= (s_ones == 9) ? 0 : s_ones + 1;
                if (inc_s_tens) s_tens <= (s_tens == 5) ? 0 : s_tens + 1;
                if (inc_m_ones) m_ones <= (m_ones == 9) ? 0 : m_ones + 1;
                if (inc_m_tens) m_tens <= (m_tens == 5) ? 0 : m_tens + 1;
                if (inc_h_ones) h_ones <= (h_ones == 9) ? 0 : h_ones + 1;
                if (inc_h_tens) h_tens <= (h_tens == 9) ? 0 : h_tens + 1;
            end
        end
    end

    // Assign internal registers to outputs
    assign sec_ones = s_ones; assign sec_tens = s_tens;
    assign min_ones = m_ones; assign min_tens = m_tens;
    assign hr_ones  = h_ones; assign hr_tens  = h_tens;

endmodule