module clock_gating(
	input wire clk,
	input wire enable,
	output wire gated_clk
);

reg enable_latched;

//使用 latch 鎖住 enable
always @(clk or enable) 
begin
	if (!clk)  //latch triggered when clk is low
		enable_latched = enable;
end

assign gated_clk = clk & enable_latched;

endmodule
	