//-
// Copyright (c) 2015 University of Cambridge
// Copyright (c) 2015 Noa Zilberman
// All rights reserved.
//
// This software was developed by the University of Cambridge Computer Laboratory 
// under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
// and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
// under contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//

`timescale 1ns / 1ps

 module top_tb_bd ();

 
 localparam HALF_CORE_PERIOD = 2.5;
  
  reg  reset; 

  reg  fpga_sysclk;
  wire fpga_sysclk_p, fpga_sysclk_n;
 
 
 reference_nic_wrapper top_sim_bd_wrapper
 ( .fpga_sysclk_n 		(fpga_sysclk_p),
   .fpga_sysclk_p		(fpga_sysclk_n),
   .reset			(reset)
 );
 
 
 // rst - ACTIVE_HIGH 
 initial begin 
    reset = 1'b1;
    #(HALF_CORE_PERIOD * 2*200);
    reset = 1'b0;
    $display("Reset Deasserted");
 end

 //clk - 200MHz fpga_clk
   
 initial begin
   fpga_sysclk = 1'b0;
   #(HALF_CORE_PERIOD);
   forever
      #(HALF_CORE_PERIOD) fpga_sysclk = ~fpga_sysclk;
end 

assign fpga_sysclk_p = fpga_sysclk;
assign fpga_sysclk_n = ~fpga_sysclk; 

endmodule
