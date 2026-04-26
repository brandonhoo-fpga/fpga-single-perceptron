# FPGA Single Perceptron (SystemVerilog)
A hardware-level implementation of a single perceptron, the basic computational unit of a neural network. Computes a signed weighted sum of inputs against a configurable bias, then applies a Heaviside step activation to drive a binary output. The current top-level configuration uses two switches and a fixed weight/bias combination to realize a logical OR gate purely in hardware.

**Note:** This project marked my transition from Verilog to **SystemVerilog**. It served as a focused exploration of parameterized modules, packed multidimensional arrays, signed arithmetic, and the syntactic differences between `always_ff` / `always_comb` and the older Verilog `always` blocks.

## 🎥 Hardware Demonstration
*(Demonstration video pending. The current top-level acts as an OR gate driven by Switch 1 and Switch 2, lighting LED 1 whenever the perceptron's weighted sum exceeds zero.)*

| SW1 | SW2 | Weighted Sum     | LED 1 |
|-----|-----|------------------|-------|
| 0   | 0   | -2 + 0 + 0 = -2  | OFF   |
| 0   | 1   | -2 + 0 + 3 =  1  | ON    |
| 1   | 0   | -2 + 3 + 0 =  1  | ON    |
| 1   | 1   | -2 + 3 + 3 =  4  | ON    |

## 🔄 Background & Motivation
After completing my first FPGA project (the Morse Code Decoder in Verilog), I wanted a smaller, focused exercise to learn **SystemVerilog** without the overhead of a full system. I also wanted to take a first step into hardware-accelerated machine learning primitives.

A single perceptron was the right fit. The math is short enough to fit in two modules, but it forces you to deal with signed arithmetic, parameterized data widths, and packed multidimensional arrays. It is also the building block of every neural network, so getting one right in hardware is a starting point for anything bigger later.

The end result is a parameterized module that can be reconfigured to any linearly separable function (OR, AND, NAND, NOR) by changing only the weights and bias, with no logic redesign required.

## ⚙️ How It Works (System Architecture)
The design is split into a generic compute core and a board-specific top-level wrapper.

### 1. Single_Perceptron Module (Compute Core)
* **Parameterized:** `DATA_WIDTH` controls the bit width of every input, weight, and bias. `NUM_INPUTS` controls the number of input/weight pairs. The current configuration is 4-bit signed values with two inputs.
* **Multiply-Accumulate:** A combinational `always_comb` block iterates over every input, multiplies it by its corresponding weight, and adds the running product to a sum that starts at the bias value. Products are sized to double width `(DATA_WIDTH*2)` to prevent overflow on signed multiplication.
* **Activation Function:** A clocked `always_ff` block latches the final sum into `r_Current_Sum` and drives `o_Activation` high whenever the sum is positive, implementing a Heaviside step function in pure hardware.

### 2. Go_Board_Perceptron Module (Top-Level Wrapper)
* **Switch Mapping:** The two onboard switches are converted to signed 4-bit values (`1` when pressed, `0` otherwise) and routed into the perceptron's input vector.
* **Hardcoded Network:** Weights are set to `+3` and `+3`, bias is set to `-2`. This combination places the decision boundary at $x_1 + x_2 \geq 1$, producing the truth table of a logical OR gate.
* **Output Drive:** The perceptron's activation output drives LED 1 directly. No further glue logic is required.

### 3. Reconfigurability
Because the entire logical behavior is determined by the weight and bias values, the same hardware can implement any linearly separable two-input function by changing only the constants in `Go_Board_Perceptron.sv`:
* **AND:** weights `+2`, `+2`, bias `-3`
* **OR:** weights `+3`, `+3`, bias `-2` (current)
* **NAND:** weights `-2`, `-2`, bias `+3`
* **NOR:** weights `-3`, `-3`, bias `+2`

## 🛠️ Tools & Hardware
* **Language:** SystemVerilog
* **Target:** Lattice iCE40 (Nandland Go Board)
* **Synthesis:** Yosys, NextPNR, and IceStorm (Open-source CLI flow)
* **Verification:** Icarus Verilog + GTKWave

## 🚀 Lessons Learned
This project taught me how the **SystemVerilog** type system improves on classic Verilog. Using `logic` instead of separate `wire` and `reg` declarations, splitting clocked logic into `always_ff` and combinational logic into `always_comb`, and packing multi-dimensional input/weight arrays in a single declaration made the module noticeably cleaner than it would have been in Verilog.

It also demonstrated that **a neural network primitive maps cleanly to hardware**. The multiply-accumulate is just an unrolled loop in combinational logic, and the activation function is a single comparator. Every clock cycle the perceptron produces a fresh classification with zero software overhead, which is the entire point of moving inference into FPGAs in the first place. While this design is fixed-weight, it lays the groundwork for future projects involving runtime weight updates, multi-layer networks, and on-chip learning.
