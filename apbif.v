module apbif(
	input wire clk, rst_n,
	input wire pwrite, penable, psel,
	input wire [11:0] paddr, 
	input wire [3:0] pstrb,
	input wire [31:0] pwdata,
	
	input wire timer_en_curr,
	input wire [3:0] div_val_curr,
	input wire div_en_curr,

	output wire wr_en, rd_en, pready, pslverr
);

//assign pready = 1'b1;

//Wait State Logic (1 cycle)
reg p_state;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		p_state <= 1'b0;
	end else begin
		//If in access state but not ready, after 1 cycle will ready
		if (psel && penable && !p_state)
			p_state <= 1'b1;
		else
			p_state <= 1'b0;
	end
end

assign pready = p_state && psel && penable;

//Read & Write
assign wr_en = pwrite && pready && !pslverr;
assign rd_en = !pwrite && pready;

//Detect errors 
wire is_tcr = (paddr == 12'h000);

//err_st0
assign err_cfg = timer_en_curr && is_tcr && pwrite && ((pstrb[1] && (pwdata[11:8] != div_val_curr)) || (pstrb[0] && (pwdata[1] != div_en_curr)));
//err_st1
assign err_val = is_tcr && pwrite && pstrb[1] && (pwdata[11:8] > 4'd8);

assign pslverr = (err_cfg || err_val) && psel && penable && p_state;

endmodule

