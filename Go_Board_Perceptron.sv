// ============================================================================
// File Name   : Go_Board_Perceptron.sv
// Author      : Brandon Hoo
// Description : Top-level wrapper that maps the Single_Perceptron module onto
//               the Nandland Go Board hardware. Drives the perceptron with
//               two physical switches and a hardcoded weight/bias combination
//               that implements an OR gate, lighting LED 1 on activation.
// ============================================================================

module main (
    input  logic i_Clk,         // 25MHz system clock
    input  logic i_Switch_1,    // Physical switch input 1
    input  logic i_Switch_2,    // Physical switch input 2
    output logic o_LED_1        // LED driven by perceptron activation
);

localparam DATA_WIDTH = 4;
localparam NUM_INPUTS = 2;

logic signed [NUM_INPUTS-1:0][DATA_WIDTH-1:0] w_Inputs;
logic signed [NUM_INPUTS-1:0][DATA_WIDTH-1:0] w_Weights;
logic signed [DATA_WIDTH-1:0] w_Bias;

// Weights = 3, Bias = -2 -> OR gate truth table
always_comb
begin
    w_Inputs[0] = i_Switch_1 ? 4'sd1 : 4'sd0;
    w_Inputs[1] = i_Switch_2 ? 4'sd1 : 4'sd0;

    w_Weights[0] = 4'sd3;
    w_Weights[1] = 4'sd3;
    w_Bias       = -4'sd2;
end

// Instantiation of Single_Perceptron module
Single_Perceptron #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_INPUTS(NUM_INPUTS)
)
Perceptron_Inst (
    .i_Clk(i_Clk),
    .i_Inputs(w_Inputs),
    .i_Weights(w_Weights),
    .i_Bias(w_Bias),
    .o_Activation(o_LED_1)
);

endmodule
