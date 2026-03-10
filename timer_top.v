module timer_top(
	input wire sys_clk, sys_rst_n,
	//APB Interface
        input wire tim_pwrite, tim_psel, tim_penable,
	input wire [3:0]    tim_pstrb,
        input wire [11:0]   tim_paddr,
	input wire  [31:0]  tim_pwdata,
	output wire [31:0]  tim_prdata,
  	output wire         tim_pready,
	output wire         tim_pslverr,
	//Interrupt & Debug
	output wire tim_int,
 	input wire dbg_mode,
	input wire halt_req,
	output wire halt_ack

);

//Internal connections
wire wr_en, rd_en; 
wire timer_en, div_en, int_en;
wire stop, hw_clear, tick;
wire [3:0] div_val;
wire [63:0] count, tcmp;

//1. APB Interface Logic
apbif u_apbif(
	.clk(sys_clk), .rst_n(sys_rst_n),
	.psel(tim_psel), .penable(tim_penable), .pwrite(tim_pwrite),
	.paddr(tim_paddr), .pstrb(tim_pstrb), .pwdata(tim_pwdata),

	//Feedback signals for protection logic
	.timer_en_curr(timer_en),
	.div_val_curr(div_val),
	.div_en_curr(div_en),

	.pready(tim_pready), .pslverr(tim_pslverr),
	.wr_en(wr_en), .rd_en(rd_en)

);

//2. Register File
regset u_regset(
	.clk(sys_clk), .rst_n(sys_rst_n),
	.wr_en(wr_en), .rd_en(rd_en),
	.addr(tim_paddr), .wdata(tim_pwdata), .pstrb(tim_pstrb),

	.count(count), //input from counter
	.halt_ack(1'b0), //input from cnt_ctrl
	
	.timer_en(timer_en), .div_en(div_en), .div_val(div_val),
	.tcmp(tcmp), .int_en(int_en), .halt_req(),
	.tim_int(tim_int), .prdata(tim_prdata)

);

//3. Counter Control
cnt_ctrl u_cnt_ctrl(
	.clk(sys_clk), .rst_n(sys_rst_n),
	.timer_en(timer_en), .div_en(div_en), .div_val(div_val),
	.dbg_mode(dbg_mode), .halt_req(halt_req),

	.stop(stop), .halt_ack(halt_ack),
	.hw_clear(hw_clear), .tick(tick)
);

//4. Counter
counter u_cnt(
	.clk(sys_clk), .rst_n(sys_rst_n),
	.pstrb(tim_pstrb), .wdata(tim_pwdata),
	.wr_en(wr_en), .addr(tim_paddr),
	.hw_clear(hw_clear), .tick(tick),

	.count(count)

);
endmodule

