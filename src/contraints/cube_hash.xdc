## Clock CONNECTED TO INTERNAL CLOCK

##clk
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]


#### RESET CONNECTED TO BUTTON CENTER ####

##rst
set_property PACKAGE_PIN U18 [get_ports rst_p]
set_property IOSTANDARD LVCMOS33 [get_ports rst_p]


###############
# INPUT DELAY #
###############

set_input_delay -clock clk -add_delay 0.000 [get_ports part_block*]
set_input_delay -clock clk -add_delay 0.000 [get_ports rst_p]
set_input_delay -clock clk -add_delay 0.000 [get_ports in_en]
set_input_delay -clock clk -add_delay 0.000 [get_ports start]
set_input_delay -clock clk -add_delay 0.000 [get_ports load]



################
# OUTPUT DELAY #
################

set_output_delay -clock clk -add_delay 0.000 [get_ports level_out_en]
set_output_delay -clock clk -add_delay 0.000 [get_ports part_hash*]
set_output_delay -clock clk -add_delay 0.000 [get_ports err]
set_output_delay -clock clk -add_delay 0.000 [get_ports level_fall_rst]
set_output_delay -clock clk -add_delay 0.000 [get_ports load_rpi0]
set_output_delay -clock clk -add_delay 0.000 [get_ports hash_ready_led]





#### PMODs CONNENCTED TO PMOD C ####

## INPUT

##JC1
set_property PACKAGE_PIN K17 [get_ports {part_block[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[0]}]
set_property PACKAGE_PIN M18 [get_ports {part_block[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[1]}]
set_property PACKAGE_PIN N17 [get_ports {part_block[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[2]}]
set_property PACKAGE_PIN P18 [get_ports {part_block[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[3]}]
set_property PACKAGE_PIN L17 [get_ports {part_block[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[4]}]
set_property PACKAGE_PIN M19 [get_ports {part_block[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[5]}]
set_property PACKAGE_PIN P17 [get_ports {part_block[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[6]}]
##JC1
set_property PACKAGE_PIN R18 [get_ports {part_block[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_block[7]}]




#### PMODs CONNENCTED TO PMOD B ####

##INPUT

##JB1
set_property PACKAGE_PIN A14 [get_ports in_en]
set_property IOSTANDARD LVCMOS33 [get_ports in_en]

##JB2
set_property PACKAGE_PIN A16 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

##JB3
set_property PACKAGE_PIN B15 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports load]



##OUTPUT

##JB10
set_property PACKAGE_PIN C16 [get_ports level_out_en]
set_property IOSTANDARD LVCMOS33 [get_ports level_out_en]

##JB4
set_property PACKAGE_PIN B16 [get_ports level_fall_rst]
set_property IOSTANDARD LVCMOS33 [get_ports level_fall_rst]

##JB7
set_property PACKAGE_PIN A15 [get_ports load_rpi0]
set_property IOSTANDARD LVCMOS33 [get_ports load_rpi0]



#### PMODs CONNENCTED TO PMOD A ####

##OUTPUT
##JA1
set_property PACKAGE_PIN J1 [get_ports {part_hash[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[0]}]
set_property PACKAGE_PIN L2 [get_ports {part_hash[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[1]}]
set_property PACKAGE_PIN J2 [get_ports {part_hash[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[2]}]
set_property PACKAGE_PIN G2 [get_ports {part_hash[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[3]}]
set_property PACKAGE_PIN H1 [get_ports {part_hash[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[4]}]
set_property PACKAGE_PIN K2 [get_ports {part_hash[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[5]}]
set_property PACKAGE_PIN H2 [get_ports {part_hash[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[6]}]
##JA10
set_property PACKAGE_PIN G3 [get_ports {part_hash[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {part_hash[7]}]


#### ERROR indicator connected to led LD0 ####

set_property PACKAGE_PIN U16 [get_ports err]
set_property IOSTANDARD LVCMOS33 [get_ports err]






#### finish hashing indicator led LD8 ####

set_property PACKAGE_PIN V13 [get_ports hash_ready_led]
set_property IOSTANDARD LVCMOS33 [get_ports hash_ready_led]

