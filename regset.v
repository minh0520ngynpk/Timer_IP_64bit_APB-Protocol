module regset(
	input wire clk, rst_n,
        input wire wr_en, rd_en,
	input wire [11:0] addr,
	input wire [31:0] wdata,
	input wire [3:0] pstrb,
	input wire [63:0] count,
	input wire halt_ack,

	output reg timer_en, div_en,
	output reg [3:0] div_val,
	output reg [63:0] tcmp,
	output reg int_en, halt_req,
	output wire tim_int,
	output reg [31:0] prdata

);

reg int_st;

//Interrupt Logic (RW1C Priority)
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) int_st <= 1'b0;
	else begin
		//Delete int use 12-bit addr compare
		if (wr_en && (addr == 12'h018) && pstrb[0] && wdata[0])
			int_st <= 1'b0;
		else if (count == tcmp)
			int_st <= 1'b1;
	end 
end
assign tim_int = int_st && int_en;

//Reg Write Logic
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		timer_en <= 1'b0;
		div_en <= 1'b0;
		halt_req <= 1'b0;
		int_en <= 1'b0;
		div_val <= 4'b0001;
		tcmp <= 64'hFFFF_FFFF_FFFF_FFFF;
	end else if (wr_en) begin
		case (addr)
			12'h000: begin //TCR
			if (pstrb[0]) {div_en, timer_en} <= {wdata[1], wdata[0]};
			if (pstrb[1]) div_val <= wdata[11:8];
			end
			
			12'h00C: begin //TCMP0
			if (pstrb[0]) tcmp[7:0] <= wdata[7:0];
			if (pstrb[1]) tcmp[15:8] <= wdata[15:8];
			if (pstrb[2]) tcmp[23:16] <= wdata[23:16];
			if (pstrb[3]) tcmp[31:24] <= wdata[31:24];
			end

			12'h010: begin //TCMP1
			if (pstrb[0]) tcmp[39:32] <= wdata[7:0];
			if (pstrb[1]) tcmp[47:40] <= wdata[15:8];
			if (pstrb[2]) tcmp[55:48] <= wdata[23:16];
			if (pstrb[3]) tcmp[63:56] <= wdata[31:24];
			end

			12'h014: if (pstrb[0]) int_en <= wdata[0];
			12'h01C: if (pstrb[0]) halt_req <= wdata[0];
		endcase
	end
end

//Read 
always @(*) begin
	prdata = 32'd0;
	if (rd_en) begin
		case (addr)
			12'h00: prdata = {20'b0, div_val, 6'h0, div_en, timer_en}; //TCR
			12'h04: prdata = count[31:0]; //TDR0
			12'h08: prdata = count[63:32]; //TCD1
			12'h0C: prdata = tcmp[31:0]; //tcmp0
			12'h10: prdata = tcmp[63:32]; //tcmp1
			12'h14: prdata = {31'h0, int_en}; //tier
			12'h18: prdata = {31'h0, int_st}; //tisr
			12'h1C: prdata = {30'h0, halt_ack, halt_req}; //thcsr
			default: prdata = 32'd0;
		endcase
	end
end

endmodule

