`timescale 1ns/1ps

module test_bench;

	reg clk;
	reg rst_n;

	reg [11:0] paddr;
	reg psel;
	reg pwrite;
	reg penable;

	reg [31:0] pwdata;
	reg [3:0] pstrb;
	reg dbg_mode;
	reg halt_req;

	wire halt_ack;
	wire pready;
	wire pselverr;
	wire tim_int;
	wire [31:0] prdata;

//Parameters (addr map)
parameter TCR = 12'h00;
parameter TDR0 = 12'h04;
parameter TDR1 = 12'h08;
parameter TCMP0 = 12'h0C;
parameter TCMP1 = 12'h10;
parameter TIER = 12'h14;
parameter TISR = 12'h18;
parameter HALT_REQ = 12'h1C;

timer_top u_dut (
	.sys_clk(clk),
	.sys_rst_n(rst_n),
	.tim_paddr(paddr),
	.tim_psel(psel),
	.tim_pwrite(pwrite),
	.tim_penable(penable),

	.tim_pwdata(pwdata),
	.tim_pstrb(pstrb),
	.tim_pready(pready),
	.tim_pslverr(pslverr),
	.tim_prdata(prdata),
	.tim_int(tim_int),
	.dbg_mode(dbg_mode),
	.halt_req(halt_req),
	.halt_ack(halt_ack)

);
	
`include "run_test.v"

initial begin
	clk = 0;
	forever #25 clk = ~clk;
end

initial begin
	psel = 1'b0;
	pwrite = 1'b0;
	penable = 1'b0;
	dbg_mode = 1'b0;
	pstrb = 4'b1111;
	paddr = 12'h0;
	pwdata = 0;
end

//run testcase
initial begin
	#100;
	run_test();
	repeat(10) @(posedge clk);
	#100;
	$finish;
end

task apply_reset();
	begin
		$display("Applying Reset...");
		rst_n = 0;
		#100;
		rst_n = 1;
		#20;
		$display("Reset released");
	end
endtask

task apb_write(
	input [11:0] addr,
	input [31:0] data

);
begin
	//Setup (state 1)
	@(posedge clk);
	#1; //Prevent race cond
	psel = 1'b1;
	pwrite = 1'b1;
	paddr = addr;
	pwdata = data;

	//Access (state 2)
	@(posedge clk);
	#1;
	penable = 1'b1; 
	//if (pready === 1'b1) begin
		//$display("[FAIL] t=%0t: pready asserts early!", $time);
	//end
	//wait for pready
	wait(pready === 1);

	//end phase
	@(posedge clk);
	#1;
	psel = 1'b0;
	penable = 1'b0;
	pwrite = 1'b0;
end
endtask

task apb_read(
	input [11:0] addr,
	output [31:0] data_out

);
begin
	@(posedge clk);
	#1;
	psel = 1'b1;
	pwrite = 1'b0;
	paddr = addr;

	@(posedge clk);
	#1;
	penable = 1'b1; //access (state 2)
	//if (pready === 1'b1)
		//$display("[FAIL] t=%0t (Read): pready asserts early!", $time);

	//wait for pready
	wait(pready === 1);
	#1;
	data_out = prdata;

	//idle phase
	@(posedge clk);
	#1;
	psel = 1'b0;
	penable = 1'b0;
end
endtask

endmodule

