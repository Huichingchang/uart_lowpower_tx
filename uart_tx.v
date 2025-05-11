`timescale 1ns/1ps
module uart_tx(
	input wire clk,   //系統時脈(不被Gating)
	input wire gated_clk,  //改成gated clock(節省工耗用)
	input wire rst,        //非同步重置信號
	input wire tx_start,   //啟動傳送
	input wire [7:0] data_in,  //要傳送的資料
	output reg tx,             //UART 傳送腳位
	output reg busy,           //傳送中旗標
	output reg [2:0] state,    //FSM狀態輸出
	output reg clk_enable      //時脈啟用訊號
);
   
	//狀態定義
	localparam IDLE = 3'd0,
	           START = 3'd1,
	           DATA = 3'd2,
              STOP = 3'd3,
              DONE = 3'd4;
	
	//暫存器
	reg [3:0] bit_cnt;  //資料位元計數器
	reg [7:0] shift_reg;  //傳送資料暫存器
	reg [3:0] baud_cnt;   //假設16倍baudrate
	
	// FSM用系統clk運作,確保always活著
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
			busy <= 1'b0;
			bit_cnt <= 4'd0;
			baud_cnt <= 4'd0;
			shift_reg <= 8'd0;
			clk_enable <= 1'b1;  // Reset時 clock gating打開,啟動後再控制
	   end else begin
			case (state)
				IDLE: begin
					busy <= 1'b0;
					clk_enable <= 1'b0;  //在IDLE停掉clock toggling
					if (tx_start) begin
						shift_reg <= data_in;
						state <= START;
						busy <= 1'b1;
						baud_cnt <= 4'd0;
						clk_enable <= 1'b1;  //啟動傳送時開啟clock
					end
			   end
				
				START: begin
					if (baud_cnt == 4'd15) begin
						baud_cnt <= 4'd0;
						bit_cnt <= 4'd0;
						state <= DATA;
					end else begin
						baud_cnt <= baud_cnt + 1;
					end
			   end
				
				DATA: begin
					if (baud_cnt == 4'd15) begin
						baud_cnt <= 4'd0;
						if (bit_cnt == 7) begin
							state <= STOP;
						end else begin
							bit_cnt <= bit_cnt + 1;
						end
					end else begin
						baud_cnt <= baud_cnt + 1;
					end
			   end
				
				STOP: begin
					if (baud_cnt == 4'd15) begin
						baud_cnt <= 4'd0;
						state <= DONE;
					end else begin
						baud_cnt <= baud_cnt + 1;
					end
				end
					
				DONE: begin
					busy <= 1'b0;
					state <= IDLE;
					//	在IDLE state裡會自動動關閉clk_enable
				end
					
				default: begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	// tx輸出,搭配gated_clk切換
	always @(posedge gated_clk or posedge rst) begin
		if (rst) begin
		   tx <= 1'b1;  // UART限制是高
	   end else begin
		    case (state)
			      START: tx <= 1'b0;  // Start bit
			      DATA: tx <= shift_reg[bit_cnt];  //資料bits
			      STOP: tx <= 1'b1;
			      default: tx <= 1'b1;  // Stop bit
		    endcase
		end
	end
endmodule
					
				