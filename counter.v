module counter(
	input wire clk, rst_n,
	input wire hw_clear, tick,
	input wire wr_en,
	input wire [11:0] addr,
	input wire [3:0] pstrb,
	input wire [31:0] wdata,

	output reg [63:0] count
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n || hw_clear) begin
		count <= 64'd0;
	end else begin
		if (wr_en && (addr == 12'h004)) begin //TDR0
			if (pstrb[0]) count[7:0] <= wdata[7:0];
			if (pstrb[1]) count[15:8] <= wdata[15:8];
			if (pstrb[2]) count[23:16] <= wdata[23:16];
			if (pstrb[3]) count[31:24] <= wdata[31:24];
		end

		else if (wr_en && (addr == 12'h008)) begin //TDR1
			if (pstrb[0]) count[39:32] <= wdata[7:0];
			if (pstrb[1]) count[47:40] <= wdata[15:8];
			if (pstrb[2]) count[55:48] <= wdata[23:16];
			if (pstrb[3]) count[63:56] <= wdata[31:24];
		end

	//Normal count
		else if (tick) begin
			count <= count + 1;
		end
	end
end
endmodule

