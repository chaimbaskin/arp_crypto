#
# Copyright (c) 2015 Digilent Inc.
# Copyright (c) 2015 Tinghui Wang (Steve)
# All rights reserved.
#
# File:
# nf_sume_fmc_gtwizard.tcl
#
# Project:
# acceptance_test
#
# Author:
# Tinghui Wang (Steve)
#
# Description:
# Vivado TCL script to generate FMC GTwizard project 
#
# This software was developed by the University of Cambridge Computer Laboratory
# under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
# and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL),
# under contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

source tcl/nf_sume_mbsys.tcl

set ip_name {nf_sume_fmc_gtwizard}

# Create Project in Memory
create_project -in_memory -part xc7vx690tffg1761-3

# Generate MIG IP Core
create_ip -name gtwizard -vendor xilinx.com -library ip -module_name ${ip_name}
set_property -dict [list\
	CONFIG.identical_val_tx_line_rate {12.5}\
	CONFIG.gt4_val {true}\
	CONFIG.gt5_val {true}\
	CONFIG.gt6_val {true}\
	CONFIG.gt7_val {true}\
	CONFIG.gt8_val {true}\
	CONFIG.gt9_val {true}\
	CONFIG.gt10_val {true}\
	CONFIG.gt11_val {true}\
	CONFIG.gt12_val {true}\
	CONFIG.gt13_val {true}\
	CONFIG.gt0_val_encoding {64B/66B_with_Ext_Seq_Ctr}\
	CONFIG.gt0_val_decoding {64B/66B}\
	CONFIG.gt0_val_drp {false}\
	CONFIG.gt0_val_drp_clock {100}\
	CONFIG.gt0_uselabtools {true}\
	CONFIG.identical_val_rx_line_rate {12.5}\
	CONFIG.gt_val_tx_pll {QPLL}\
	CONFIG.gt_val_rx_pll {QPLL}\
	CONFIG.gt4_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt5_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt6_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt7_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt8_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt9_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt10_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt11_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt12_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt13_val_tx_refclk {REFCLK0_Q2}\
	CONFIG.gt4_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt5_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt6_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt7_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt8_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt9_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt10_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt11_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt12_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt13_val_rx_refclk {REFCLK0_Q2}\
	CONFIG.gt0_val_tx_line_rate {12.5}\
	CONFIG.gt0_val_tx_data_width {32}\
	CONFIG.gt0_val_tx_int_datawidth {32}\
	CONFIG.gt0_val_rx_line_rate {12.5}\
	CONFIG.gt0_val_rx_data_width {32}\
	CONFIG.gt0_val_rx_int_datawidth {32}\
	CONFIG.gt0_val_qpll_fbdiv {80}\
	CONFIG.gt0_val_cpll_rxout_div {1}\
	CONFIG.gt0_val_cpll_txout_div {1}\
	CONFIG.gt0_val_rxcomma_deten {false}\
	CONFIG.gt0_val_dec_mcomma_detect {false}\
	CONFIG.gt0_val_dec_pcomma_detect {false}\
	CONFIG.gt0_val_port_rxslide {false}\
	CONFIG.gt0_val_clk_cor_seq_1_1 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_1_2 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_1_3 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_1_4 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_2_1 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_2_2 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_2_3 {00000000}\
	CONFIG.gt0_val_clk_cor_seq_2_4 {00000000}\
	CONFIG.gt0_val_rxslide_mode {OFF}\
] [get_ips ${ip_name}]

# Create Example Design
open_example_project -force -in_process -dir project [get_ips ${ip_name}] 

# Create Microblaze block design
create_bd -iic true -uart true -add_rw 1 -add_ro 1 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8 -add_ro 8

# Add Constraints
add_files -fileset constrs_1 -norecurse xdc/nf_sume_system_general.xdc
add_files -fileset constrs_1 -norecurse xdc/nf_sume_fmc_gtwizard.xdc

exit
