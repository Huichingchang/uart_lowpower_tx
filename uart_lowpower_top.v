`timescale 1ns/1ps
module uart_lowpower_top(
	input wire clk,  //系統時脈
	input wire rst,  // 非同步重置信號
	input wire tx_start,  //啟動傳送
	input wire [7:0] data_in,  //要傳送的資料
	output wire tx,  //UART傳送腳位
	output wire busy,  //傳送中旗標
	output wire [2:0] state  //UART FSM狀態	
);

	wire gated_clk;  // clock gating後的時脈
	wire clk_enable; // UART產生的clock enable控制信號
	
	// Clock Gating Instance
	clock_gating u_clock_gating(
		.clk(clk),
		.enable(clk_enable),
		.gated_clk(gated_clk)
	);
	
	// UART TX Instance
	uart_tx u_uart_tx(
		.clk(clk),
		.gated_clk(gated_clk),  //注意這裡用gaged_clk
		.rst(rst),
		.tx_start(tx_start),
		.data_in(data_in),
		.tx(tx),
		.busy(busy),
		.state(state),
		.clk_enable(clk_enable)  // UART告訴clock gating何時要開/關
	);
endmodule