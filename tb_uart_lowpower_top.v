`timescale 1ns/1ps
module tb_uart_lowpower_top;

// Testbench內部訊號
reg clk;
reg rst;
reg tx_start;
reg [7:0] data_in;
wire tx;
wire busy;
wire [2:0] state;

// Instantiate the UART Low Power Top
uart_lowpower_top uut(
	.clk(clk),
	.rst(rst),
	.tx_start(tx_start),
	.data_in(data_in),
	.tx(tx),
	.busy(busy),
	.state(state)
);

//時脈產生器: 50MHz (週期20ns)
initial begin
	clk = 0;
	forever #10 clk = ~clk;
end

//測試流程
initial begin
	//初始化
	rst = 1;
	tx_start = 0;
	data_in = 8'd0;
	
	#100;  // Hold reset一段時間
	rst = 0;  //解除reset
	#100;  //等待一段時間

	//傳送第一筆資料
	data_in = 8'hA5;  //10100101
	tx_start = 1;
	#20;
	tx_start = 0;  //拉一拍就好
	
	//等待busy釋放
	wait (busy == 0);
	#200;   //空白間隔一段時間
	
	//傳送第二筆資料
	data_in = 8'h3C; //00111100
	tx_start = 1;
	#20;
	tx_start = 0;
	
	//等待busy釋放
	wait (busy == 0);
   #200;    //多等一段
	
	$display("Simulation finished!");
	$stop;
end

//超時保護(防止死循環)
initial begin
	#50000;  //如果50us還沒停下來,自動stop
	$display("Timeout reached!");
	$stop;
end
endmodule