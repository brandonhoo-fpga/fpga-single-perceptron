// ============================================================================
// File Name   : Single_Perceptron.sv
// Author      : Brandon Hoo
// Description : Parameterized hardware implementation of a single perceptron,
//               the building block of a neural network. Computes a weighted
//               sum of signed inputs plus a bias, then applies a Heaviside
//               step activation (output high when sum is positive).
// ============================================================================

module Single_Perceptron #(
    parameter DATA_WIDTH = 4,   // Bit width of each input, weight, and bias
    parameter NUM_INPUTS = 2    // Number of input/weight pairs
)
(
    input  logic i_Clk,                                                 // System clock
    input  logic signed [NUM_INPUTS-1:0][DATA_WIDTH-1:0] i_Inputs,      // Packed array of signed inputs
    input  logic signed [NUM_INPUTS-1:0][DATA_WIDTH-1:0] i_Weights,     // Packed array of signed weights
    input  logic signed [DATA_WIDTH-1:0] i_Bias,                        // Signed bias term

    output logic o_Activation                                           // Step-function output (1 when sum > 0)
);

// Products are double-width to avoid signed-multiply overflow
logic signed [NUM_INPUTS-1:0][(DATA_WIDTH*2)-1:0] w_Products;
logic signed [(DATA_WIDTH*2)-1:0] w_Next_Sum;
logic signed [(DATA_WIDTH*2)-1:0] r_Current_Sum;

// Multiply-accumulate: sum = bias + Σ(input[i] * weight[i])
always_comb
begin
    w_Next_Sum = i_Bias;

    for (int i = 0; i < NUM_INPUTS; i++)
    begin
        w_Products[i] = i_Inputs[i] * i_Weights[i];
        w_Next_Sum = w_Next_Sum + w_Products[i];
    end
end

// Latch sum, apply step activation
always_ff @(posedge i_Clk)
begin
    r_Current_Sum <= w_Next_Sum;

    if (w_Next_Sum > 0)
        o_Activation <= 1'b1;
    else
        o_Activation <= 1'b0;
end

endmodule
