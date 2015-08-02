`timescale 1ns / 1ps
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
//  File:
//        nf_datapath.v
//
//  Module:
//        nf_datapath
//
//  Author: Noa Zilberman
//
//  Description:
//        NetFPGA user data path wrapper, wrapping input arbiter, output port lookup and output queues
//
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//


module nf_datapath #(
    //Slave AXI parameters
    parameter C_S_AXI_DATA_WIDTH    = 32,          
    parameter C_S_AXI_ADDR_WIDTH    = 32,          
    parameter C_USE_WSTRB           = 0,
    parameter C_DPHASE_TIMEOUT      = 0,
    parameter C_BASEADDR            = 32'h00000000,
    parameter C_HIGHADDR            = 32'h0000FFFF,

    // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter NUM_QUEUES=5
)
(
    //Datapath clock
    input                                     axis_aclk,
    input                                     axis_resetn,
    //Registers clock
    input                                     axi_aclk,
    input                                     axi_resetn,

    // Slave AXI Ports
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S0_AXI_AWADDR,
    input                                     S0_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S0_AXI_WSTRB,
    input                                     S0_AXI_WVALID,
    input                                     S0_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S0_AXI_ARADDR,
    input                                     S0_AXI_ARVALID,
    input                                     S0_AXI_RREADY,
    output                                    S0_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_RDATA,
    output     [1 : 0]                        S0_AXI_RRESP,
    output                                    S0_AXI_RVALID,
    output                                    S0_AXI_WREADY,
    output     [1 :0]                         S0_AXI_BRESP,
    output                                    S0_AXI_BVALID,
    output                                    S0_AXI_AWREADY,
    
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S1_AXI_AWADDR,
    input                                     S1_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S1_AXI_WSTRB,
    input                                     S1_AXI_WVALID,
    input                                     S1_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S1_AXI_ARADDR,
    input                                     S1_AXI_ARVALID,
    input                                     S1_AXI_RREADY,
    output                                    S1_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_RDATA,
    output     [1 : 0]                        S1_AXI_RRESP,
    output                                    S1_AXI_RVALID,
    output                                    S1_AXI_WREADY,
    output     [1 :0]                         S1_AXI_BRESP,
    output                                    S1_AXI_BVALID,
    output                                    S1_AXI_AWREADY,

    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S2_AXI_AWADDR,
    input                                     S2_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S2_AXI_WSTRB,
    input                                     S2_AXI_WVALID,
    input                                     S2_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S2_AXI_ARADDR,
    input                                     S2_AXI_ARVALID,
    input                                     S2_AXI_RREADY,
    output                                    S2_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_RDATA,
    output     [1 : 0]                        S2_AXI_RRESP,
    output                                    S2_AXI_RVALID,
    output                                    S2_AXI_WREADY,
    output     [1 :0]                         S2_AXI_BRESP,
    output                                    S2_AXI_BVALID,
    output                                    S2_AXI_AWREADY,

    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S3_AXI_AWADDR,
    input                                     S3_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S3_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S3_AXI_WSTRB,
    input                                     S3_AXI_WVALID,
    input                                     S3_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S3_AXI_ARADDR,
    input                                     S3_AXI_ARVALID,
    input                                     S3_AXI_RREADY,
    output                                    S3_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S3_AXI_RDATA,
    output     [1 : 0]                        S3_AXI_RRESP,
    output                                    S3_AXI_RVALID,
    output                                    S3_AXI_WREADY,
    output     [1 :0]                         S3_AXI_BRESP,
    output                                    S3_AXI_BVALID,
    output                                    S3_AXI_AWREADY,

    
    // Slave Stream Ports (interface from Rx queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_0_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_0_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_0_tuser,
    input                                     s_axis_0_tvalid,
    output                                    s_axis_0_tready,
    input                                     s_axis_0_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_1_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_1_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_1_tuser,
    input                                     s_axis_1_tvalid,
    output                                    s_axis_1_tready,
    input                                     s_axis_1_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_2_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_2_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_2_tuser,
    input                                     s_axis_2_tvalid,
    output                                    s_axis_2_tready,
    input                                     s_axis_2_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_3_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_3_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_3_tuser,
    input                                     s_axis_3_tvalid,
    output                                    s_axis_3_tready,
    input                                     s_axis_3_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_4_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_4_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_4_tuser,
    input                                     s_axis_4_tvalid,
    output                                    s_axis_4_tready,
    input                                     s_axis_4_tlast,


    // Master Stream Ports (interface to TX queues)
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_0_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_0_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_0_tuser,
    output                                     m_axis_0_tvalid,
    input                                      m_axis_0_tready,
    output                                     m_axis_0_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_1_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_1_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_1_tuser,
    output                                     m_axis_1_tvalid,
    input                                      m_axis_1_tready,
    output                                     m_axis_1_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_2_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_2_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_2_tuser,
    output                                     m_axis_2_tvalid,
    input                                      m_axis_2_tready,
    output                                     m_axis_2_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_3_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_3_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_3_tuser,
    output                                     m_axis_3_tvalid,
    input                                      m_axis_3_tready,
    output                                     m_axis_3_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_4_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_4_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_4_tuser,
    output                                     m_axis_4_tvalid,
    input                                      m_axis_4_tready,
    output                                     m_axis_4_tlast


    );
    
    /////////////////////////////////////////////
    
    
    //internal connectivity
  
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_opl_tdata;
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_opl_tkeep;
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_opl_tuser;
    wire                                     m_axis_opl_tvalid;
    wire                                     m_axis_opl_tready;
    wire                                     m_axis_opl_tlast;
     
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         s_axis_opl_tdata;
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_opl_tkeep;
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          s_axis_opl_tuser;
    wire                                     s_axis_opl_tvalid;
    wire                                     s_axis_opl_tready;
    wire                                     s_axis_opl_tlast;
 
  //Crypto module connectivity

     
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_crypto_tdata;
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_crypto_tkeep;
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_crypto_tuser;
    wire                                     m_axis_crypto_tvalid;
    wire                                     m_axis_crypto_tready;
    wire                                     m_axis_crypto_tlast;
   
  
  //input_arbiter 
  input_arbiter_ip 
 input_arbiter_v1_0 (
      .axis_aclk(axis_aclk), // input axi_aclk
      .axis_resetn(axis_resetn), // input axi_resetn
      .m_axis_tdata (s_axis_opl_tdata), // output [255 : 0] m_axis_tdata
      .m_axis_tkeep (s_axis_opl_tkeep), // output [31 : 0] m_axis_tkeep
      .m_axis_tuser (s_axis_opl_tuser), // output [127 : 0] m_axis_tuser
      .m_axis_tvalid(s_axis_opl_tvalid), // output m_axis_tvalid
      .m_axis_tready(s_axis_opl_tready), // input m_axis_tready
      .m_axis_tlast (s_axis_opl_tlast), // output m_axis_tlast
      .s_axis_0_tdata (s_axis_0_tdata), // input [255 : 0] s_axis_0_tdata
      .s_axis_0_tkeep (s_axis_0_tkeep), // input [31 : 0] s_axis_0_tkeep
      .s_axis_0_tuser (s_axis_0_tuser), // input [127 : 0] s_axis_0_tuser
      .s_axis_0_tvalid(s_axis_0_tvalid), // input s_axis_0_tvalid
      .s_axis_0_tready(s_axis_0_tready), // output s_axis_0_tready
      .s_axis_0_tlast (s_axis_0_tlast), // input s_axis_0_tlast
      .s_axis_1_tdata (s_axis_1_tdata), // input [255 : 0] s_axis_1_tdata
      .s_axis_1_tkeep (s_axis_1_tkeep), // input [31 : 0] s_axis_1_tkeep
      .s_axis_1_tuser (s_axis_1_tuser), // input [127 : 0] s_axis_1_tuser
      .s_axis_1_tvalid(s_axis_1_tvalid), // input s_axis_1_tvalid
      .s_axis_1_tready(s_axis_1_tready), // output s_axis_1_tready
      .s_axis_1_tlast (s_axis_1_tlast), // input s_axis_1_tlast
      .s_axis_2_tdata (s_axis_2_tdata), // input [255 : 0] s_axis_2_tdata
      .s_axis_2_tkeep (s_axis_2_tkeep), // input [31 : 0] s_axis_2_tkeep
      .s_axis_2_tuser (s_axis_2_tuser), // input [127 : 0] s_axis_2_tuser
      .s_axis_2_tvalid(s_axis_2_tvalid), // input s_axis_2_tvalid
      .s_axis_2_tready(s_axis_2_tready), // output s_axis_2_tready
      .s_axis_2_tlast (s_axis_2_tlast), // input s_axis_2_tlast
      .s_axis_3_tdata (s_axis_3_tdata), // input [255 : 0] s_axis_3_tdata
      .s_axis_3_tkeep (s_axis_3_tkeep), // input [31 : 0] s_axis_3_tkeep
      .s_axis_3_tuser (s_axis_3_tuser), // input [127 : 0] s_axis_3_tuser
      .s_axis_3_tvalid(s_axis_3_tvalid), // input s_axis_3_tvalid
      .s_axis_3_tready(s_axis_3_tready), // output s_axis_3_tready
      .s_axis_3_tlast (s_axis_3_tlast), // input s_axis_3_tlast
      .s_axis_4_tdata (s_axis_4_tdata), // input [255 : 0] s_axis_4_tdata
      .s_axis_4_tkeep (s_axis_4_tkeep), // input [31 : 0] s_axis_4_tkeep
      .s_axis_4_tuser (s_axis_4_tuser), // input [127 : 0] s_axis_4_tuser
      .s_axis_4_tvalid(s_axis_4_tvalid), // input s_axis_4_tvalid
      .s_axis_4_tready(s_axis_4_tready), // output s_axis_4_tready
      .s_axis_4_tlast (s_axis_4_tlast), // input s_axis_4_tlast
      .S_AXI_AWADDR(S0_AXI_AWADDR), 
      .S_AXI_AWVALID(S0_AXI_AWVALID),
      .S_AXI_WDATA(S0_AXI_WDATA),  
      .S_AXI_WSTRB(S0_AXI_WSTRB),  
      .S_AXI_WVALID(S0_AXI_WVALID), 
      .S_AXI_BREADY(S0_AXI_BREADY), 
      .S_AXI_ARADDR(S0_AXI_ARADDR), 
      .S_AXI_ARVALID(S0_AXI_ARVALID),
      .S_AXI_RREADY(S0_AXI_RREADY), 
      .S_AXI_ARREADY(S0_AXI_ARREADY),
      .S_AXI_RDATA(S0_AXI_RDATA),  
      .S_AXI_RRESP(S0_AXI_RRESP),  
      .S_AXI_RVALID(S0_AXI_RVALID), 
      .S_AXI_WREADY(S0_AXI_WREADY), 
      .S_AXI_BRESP(S0_AXI_BRESP),  
      .S_AXI_BVALID(S0_AXI_BVALID), 
      .S_AXI_AWREADY(S0_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn),
      .pkt_fwd() // output pkt_fwd
    );
    
    
    
   
       //output_port_lookup  #(
       output_port_lookup_ip 
   output_port_lookup_1  (
      .axis_aclk(axis_aclk), // input axi_aclk
      .axis_resetn(axis_resetn), // input axi_resetn
      .m_axis_tdata (m_axis_opl_tdata), // output [255 : 0] m_axis_tdata
      .m_axis_tkeep (m_axis_opl_tkeep), // output [31 : 0] m_axis_tkeep
      .m_axis_tuser (m_axis_opl_tuser), // output [127 : 0] m_axis_tuser
      .m_axis_tvalid(m_axis_opl_tvalid), // output m_axis_tvalid
      .m_axis_tready(m_axis_opl_tready), // input m_axis_tready
      .m_axis_tlast (m_axis_opl_tlast), // output m_axis_tlast
      .s_axis_tdata (s_axis_opl_tdata), // input [255 : 0] s_axis_tdata
      .s_axis_tkeep (s_axis_opl_tkeep), // input [31 : 0] s_axis_tkeep
      .s_axis_tuser (s_axis_opl_tuser), // input [127 : 0] s_axis_tuser
      .s_axis_tvalid(s_axis_opl_tvalid), // input s_axis_tvalid
      .s_axis_tready(s_axis_opl_tready), // output s_axis_tready
      .s_axis_tlast (s_axis_opl_tlast), // input s_axis_tlast

      .S_AXI_AWADDR(S1_AXI_AWADDR), 
      .S_AXI_AWVALID(S1_AXI_AWVALID),
      .S_AXI_WDATA(S1_AXI_WDATA),  
      .S_AXI_WSTRB(S1_AXI_WSTRB),  
      .S_AXI_WVALID(S1_AXI_WVALID), 
      .S_AXI_BREADY(S1_AXI_BREADY), 
      .S_AXI_ARADDR(S1_AXI_ARADDR), 
      .S_AXI_ARVALID(S1_AXI_ARVALID),
      .S_AXI_RREADY(S1_AXI_RREADY), 
      .S_AXI_ARREADY(S1_AXI_ARREADY),
      .S_AXI_RDATA(S1_AXI_RDATA),  
      .S_AXI_RRESP(S1_AXI_RRESP),  
      .S_AXI_RVALID(S1_AXI_RVALID), 
      .S_AXI_WREADY(S1_AXI_WREADY), 
      .S_AXI_BRESP(S1_AXI_BRESP),  
      .S_AXI_BVALID(S1_AXI_BVALID), 
      .S_AXI_AWREADY(S1_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)


    );

    //crypto_module #(
      crypto_ip 
     crypto  (
      .axis_aclk(axis_aclk), // input axi_aclk
      .axis_resetn(axis_resetn), // input axi_resetn
      .m_axis_tdata (m_axis_crypto_tdata), // output [255 : 0] m_axis_tdata
      .m_axis_tkeep (m_axis_crypto_tkeep), // output [31 : 0] m_axis_tkeep
      .m_axis_tuser (m_axis_crypto_tuser), // output [127 : 0] m_axis_tuser
      .m_axis_tvalid(m_axis_crypto_tvalid), // output m_axis_tvalid
      .m_axis_tready(m_axis_crypto_tready), // input m_axis_tready
      .m_axis_tlast (m_axis_crypto_tlast), // output m_axis_tlast
      .s_axis_tdata (m_axis_opl_tdata), // input [255 : 0] s_axis_tdata
      .s_axis_tkeep (m_axis_opl_tkeep), // input [31 : 0] s_axis_tkeep
      .s_axis_tuser (m_axis_opl_tuser), // input [127 : 0] s_axis_tuser
      .s_axis_tvalid(m_axis_opl_tvalid), // input s_axis_tvalid
      .s_axis_tready(m_axis_opl_tready), // output s_axis_tready
      .s_axis_tlast (m_axis_opl_tlast), // input s_axis_tlast

      .S_AXI_AWADDR(S3_AXI_AWADDR), 
      .S_AXI_AWVALID(S3_AXI_AWVALID),
      .S_AXI_WDATA(S3_AXI_WDATA),  
      .S_AXI_WSTRB(S3_AXI_WSTRB),  
      .S_AXI_WVALID(S3_AXI_WVALID), 
      .S_AXI_BREADY(S3_AXI_BREADY), 
      .S_AXI_ARADDR(S3_AXI_ARADDR), 
      .S_AXI_ARVALID(S3_AXI_ARVALID),
      .S_AXI_RREADY(S3_AXI_RREADY), 
      .S_AXI_ARREADY(S3_AXI_ARREADY),
      .S_AXI_RDATA(S3_AXI_RDATA),  
      .S_AXI_RRESP(S3_AXI_RRESP),  
      .S_AXI_RVALID(S3_AXI_RVALID), 
      .S_AXI_WREADY(S3_AXI_WREADY), 
      .S_AXI_BRESP(S3_AXI_BRESP),  
      .S_AXI_BVALID(S3_AXI_BVALID), 
      .S_AXI_AWREADY(S3_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)


    );

    
       //output_queues   #(
       output_queues_ip  
      bram_output_queues_1 (
      .axis_aclk(axis_aclk), // input axi_aclk
      .axis_resetn(axis_resetn), // input axi_resetn
      .s_axis_tdata   (m_axis_crypto_tdata), // input [255 : 0] s_axis_tdata
      .s_axis_tkeep   (m_axis_crypto_tkeep), // input [31 : 0] s_axis_tkeep
      .s_axis_tuser   (m_axis_crypto_tuser), // input [127 : 0] s_axis_tuser
      .s_axis_tvalid  (m_axis_crypto_tvalid), // input s_axis_tvalid
      .s_axis_tready  (m_axis_crypto_tready), // output s_axis_tready
      .s_axis_tlast   (m_axis_crypto_tlast), // input s_axis_tlast
      .m_axis_0_tdata (m_axis_0_tdata), // output [255 : 0] m_axis_0_tdata
      .m_axis_0_tkeep (m_axis_0_tkeep), // output [31 : 0] m_axis_0_tkeep
      .m_axis_0_tuser (m_axis_0_tuser), // output [127 : 0] m_axis_0_tuser
      .m_axis_0_tvalid(m_axis_0_tvalid), // output m_axis_0_tvalid
      .m_axis_0_tready(m_axis_0_tready), // input m_axis_0_tready
      .m_axis_0_tlast (m_axis_0_tlast), // output m_axis_0_tlast
      .m_axis_1_tdata (m_axis_1_tdata), // output [255 : 0] m_axis_1_tdata
      .m_axis_1_tkeep (m_axis_1_tkeep), // output [31 : 0] m_axis_1_tkeep
      .m_axis_1_tuser (m_axis_1_tuser), // output [127 : 0] m_axis_1_tuser
      .m_axis_1_tvalid(m_axis_1_tvalid), // output m_axis_1_tvalid
      .m_axis_1_tready(m_axis_1_tready), // input m_axis_1_tready
      .m_axis_1_tlast (m_axis_1_tlast), // output m_axis_1_tlast
      .m_axis_2_tdata (m_axis_2_tdata), // output [255 : 0] m_axis_2_tdata
      .m_axis_2_tkeep (m_axis_2_tkeep), // output [31 : 0] m_axis_2_tkeep
      .m_axis_2_tuser (m_axis_2_tuser), // output [127 : 0] m_axis_2_tuser
      .m_axis_2_tvalid(m_axis_2_tvalid), // output m_axis_2_tvalid
      .m_axis_2_tready(m_axis_2_tready), // input m_axis_2_tready
      .m_axis_2_tlast (m_axis_2_tlast), // output m_axis_2_tlast
      .m_axis_3_tdata (m_axis_3_tdata), // output [255 : 0] m_axis_3_tdata
      .m_axis_3_tkeep (m_axis_3_tkeep), // output [31 : 0] m_axis_3_tkeep
      .m_axis_3_tuser (m_axis_3_tuser), // output [127 : 0] m_axis_3_tuser
      .m_axis_3_tvalid(m_axis_3_tvalid), // output m_axis_3_tvalid
      .m_axis_3_tready(m_axis_3_tready), // input m_axis_3_tready
      .m_axis_3_tlast (m_axis_3_tlast), // output m_axis_3_tlast
      .m_axis_4_tdata (m_axis_4_tdata), // output [255 : 0] m_axis_4_tdata
      .m_axis_4_tkeep (m_axis_4_tkeep), // output [31 : 0] m_axis_4_tkeep
      .m_axis_4_tuser (m_axis_4_tuser), // output [127 : 0] m_axis_4_tuser
      .m_axis_4_tvalid(m_axis_4_tvalid), // output m_axis_4_tvalid
      .m_axis_4_tready(m_axis_4_tready), // input m_axis_4_tready
      .m_axis_4_tlast (m_axis_4_tlast), // output m_axis_4_tlast
      .bytes_stored(), // output [31 : 0] bytes_stored
      .pkt_stored(), // output [4 : 0] pkt_stored
      .bytes_removed_0(), // output [31 : 0] bytes_removed_0
      .bytes_removed_1(), // output [31 : 0] bytes_removed_1
      .bytes_removed_2(), // output [31 : 0] bytes_removed_2
      .bytes_removed_3(), // output [31 : 0] bytes_removed_3
      .bytes_removed_4(), // output [31 : 0] bytes_removed_4
      .pkt_removed_0(), // output pkt_removed_0
      .pkt_removed_1(), // output pkt_removed_1
      .pkt_removed_2(), // output pkt_removed_2
      .pkt_removed_3(), // output pkt_removed_3
      .pkt_removed_4(), // output pkt_removed_4
      .bytes_dropped(), // output [31 : 0] bytes_dropped
      .pkt_dropped(), // output [4 : 0] pkt_dropped

      .S_AXI_AWADDR(S2_AXI_AWADDR), 
      .S_AXI_AWVALID(S2_AXI_AWVALID),
      .S_AXI_WDATA(S2_AXI_WDATA),  
      .S_AXI_WSTRB(S2_AXI_WSTRB),  
      .S_AXI_WVALID(S2_AXI_WVALID), 
      .S_AXI_BREADY(S2_AXI_BREADY), 
      .S_AXI_ARADDR(S2_AXI_ARADDR), 
      .S_AXI_ARVALID(S2_AXI_ARVALID),
      .S_AXI_RREADY(S2_AXI_RREADY), 
      .S_AXI_ARREADY(S2_AXI_ARREADY),
      .S_AXI_RDATA(S2_AXI_RDATA),  
      .S_AXI_RRESP(S2_AXI_RRESP),  
      .S_AXI_RVALID(S2_AXI_RVALID), 
      .S_AXI_WREADY(S2_AXI_WREADY), 
      .S_AXI_BRESP(S2_AXI_BRESP),  
      .S_AXI_BVALID(S2_AXI_BVALID), 
      .S_AXI_AWREADY(S2_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)
    ); 
    
    
    
    
endmodule
