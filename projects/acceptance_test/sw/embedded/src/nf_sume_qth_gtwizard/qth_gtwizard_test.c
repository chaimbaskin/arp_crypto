/*
 * Copyright (c) 2015 Digilent Inc.
 * Copyright (c) 2015 Tinghui Wang (Steve)
 * All rights reserved.
 *
 * File:
 *     sw/embedded/src/nf_sume_qth_gtwizard/qth_Gtwizard_test.c
 *
 * Project:
 *     acceptance_test
 *
 * Author:
 *     Tinghui Wang (Steve)
 *
 * Description:
 *     Functions for QTH GTwizard Test
 *
 * This software was developed by the University of Cambridge Computer Laboratory
 * under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
 * and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL),
 * under contract FA8750-11-C-0249.
 * 
 * @NETFPGA_LICENSE_HEADER_START@
 * 
 * Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
 * license agreements. See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership. NetFPGA licenses this
 * file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 * 
 * http://www.netfpga-cic.org
 * 
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 * 
 * @NETFPGA_LICENSE_HEADER_END@
 *
 */

#include "iic_config.h"
#include "xstatus.h"
#include "xgpio.h"
#include "xparameters.h"
#include <stdio.h>

XGpio gpioRW0_ctrl;
XGpio gpioRO0_status;

XGpio gpioROs[8];

u32 arGpioDevIds[8] = {
	XPAR_AXI_GPIO_RO_1_DEVICE_ID,
	XPAR_AXI_GPIO_RO_2_DEVICE_ID,
	XPAR_AXI_GPIO_RO_3_DEVICE_ID,
	XPAR_AXI_GPIO_RO_4_DEVICE_ID,
	XPAR_AXI_GPIO_RO_5_DEVICE_ID,
	XPAR_AXI_GPIO_RO_6_DEVICE_ID,
	XPAR_AXI_GPIO_RO_7_DEVICE_ID,
	XPAR_AXI_GPIO_RO_8_DEVICE_ID
};

/*
 * Initialize GPIO instance for qdrA Testing
 */
int qthTest_Init() {
	XGpio_Config* gpioConfigPtr;
	int i;
	int Status;

	gpioConfigPtr = XGpio_LookupConfig(XPAR_AXI_GPIO_RW_0_DEVICE_ID);
	if (gpioConfigPtr == NULL) {
		return XST_FAILURE;
	}

	Status = XGpio_CfgInitialize(&gpioRW0_ctrl, gpioConfigPtr, gpioConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	gpioConfigPtr = XGpio_LookupConfig(XPAR_AXI_GPIO_RO_0_DEVICE_ID);
	if (gpioConfigPtr == NULL) {
		return XST_FAILURE;
	}

	Status = XGpio_CfgInitialize(&gpioRO0_status, gpioConfigPtr, gpioConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	for(i = 0; i < 8; i++) {
		gpioConfigPtr = XGpio_LookupConfig(arGpioDevIds[i]);
		if (gpioConfigPtr == NULL) {
			return XST_FAILURE;
		}

		Status = XGpio_CfgInitialize(&gpioROs[i], gpioConfigPtr, gpioConfigPtr->BaseAddress);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
	}

	XGpio_DiscreteWrite(&gpioRW0_ctrl, 1, 0x01);

	for(i = 0; i < 100; i++) {
		asm("nop");
	}

	XGpio_DiscreteWrite(&gpioRW0_ctrl, 1, 0x00);

	return XST_SUCCESS;
}

/*
 * Read GPIO Status
 */
int qthRwStat() {
	u32 qthStatus;
	u32 errStatus = XST_SUCCESS;
	int i;

	qthStatus = XGpio_DiscreteRead(&gpioRO0_status, 1);
	if(qthStatus != 0x01) {
		xil_printf("qth: Transceiver Initialization Failed\r\n");
		return XST_FAILURE;
	}

	for(i = 0; i < 8; i++) {
		qthStatus = XGpio_DiscreteRead(&gpioROs[i], 1);
		if(qthStatus != 0x00) {
			xil_printf("qth-Channel%d: Error Count %4d (0x%02x)\r\n", i, qthStatus, qthStatus);
			errStatus = XST_FAILURE;
		}
	}
	
	if(errStatus == XST_SUCCESS) {
		xil_printf("qth: Test Passed with no Errors\r\n");
	}

	return errStatus;
}

/*
 * Read GPIO Status
 */
int qthRwTest() {
	u32 qthStatus;
	int i;

	qthStatus = XGpio_DiscreteRead(&gpioRO0_status, 1);
	if(qthStatus != 0x01) {
		return XST_FAILURE;
	}

	for(i = 0; i < 8; i++) {
		qthStatus = XGpio_DiscreteRead(&gpioROs[i], 1);
		if(qthStatus != 0x00) {
			xil_printf("qth-Channel%d: Error Count %4d (0x%02x)\r\n", i, qthStatus, qthStatus);
			return XST_FAILURE;
		}
	}

	return XST_SUCCESS;
}
