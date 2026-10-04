# Reference timing contract for tools accepting SDC; use constraints.ucf for ISE.
create_clock -name board_clk -period 20.000 [get_ports clk]
create_generated_clock -name dac_clk -source [get_ports clk] -divide_by 2 [get_ports DAC_CLK]
# RGB changes on DAC falling phase, with one 50 MHz period before its rising edge.
# Board-specific DAC setup/hold and trace delay must be measured before closure.
