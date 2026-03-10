task run_test();
	reg [31:0] rdata;
	reg [31:0] rdata0;
	reg [31:0] rdata1;
	reg [31:0] out_rd;
	reg [31:0] start_val;
	reg [31:0] end_val;
	reg [31:0] diff;
	reg fail;
	begin
		fail = 0;
		$display("=============================================================================");
		$display("------------------ COUNTING CHECK --------------------");
		$display("=============================================================================");

		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;
		
		//Setup
		test_bench.pstrb = 4'b1111;
		test_bench.apb_write(TCR, 32'h0000_0000); //disable timer, div=0

		$display("--- Check counting behavior ---");
		test_bench.apb_write(TDR1, 32'h0000_0000);
		test_bench.apb_write(TDR0, 32'hffff_fff0);

		//timer_en=1, div=0
		test_bench.apb_write(TCR, 32'h0000_0001);
		repeat (255-3) @(posedge test_bench.clk);
		test_bench.apb_read(TDR0, rdata0);
		if (rdata0 < 32'h0000_0100) begin
			$display("[PASS]: TDR0 continue counting");
		end else begin
			$display("%t [FAIL]: TDR0 stuck, not counting", $time);
		end

		test_bench.apb_read(TDR1, rdata1);
		if (rdata1 == 32'h1) begin
			$display("[PASS]: Carry asserted, TDR1 = 1");
		end else begin
			$display("%t [FAIL]: Carry not asserted, exp: TDR1 = 1, got: %h", $time, rdata1);
			fail = fail + 1;
		end
		
		test_bench.apb_write(TCR, 32'h0); //setup again
		
		test_bench.apb_write(TDR0, 32'hffff_ff00);
		test_bench.apb_write(TDR1, 32'hffff_ffff);

		//enable=1, div=0
		test_bench.apb_write(TCR, 32'h0000_0001);
		repeat(260) @(posedge test_bench.clk);
		test_bench.apb_read(TDR0, rdata0);
		if (rdata0 < 32'h0000_1000) begin
			$display("[PASS]: TDR0 continue counting");
		end else begin
			$display("%t [FAIL]: TDR0 stuck, not counting", $time);
		end

		test_bench.apb_read(TDR1, rdata1);
		if (rdata1 == 32'h0) begin
			$display("[PASS]: Carry asserted, TDR1 = 1");
		end else begin
			$display("%t [FAIL]: Carry not asserted, exp: TDR1 = 1, got: %h", $time, rdata1);
			fail = fail + 1;
		end

		$display("\n--- Check update while running ---");
		//setup
		test_bench.pstrb=4'hf;
		test_bench.apb_write(TCR, 32'h0);
		test_bench.apb_write(TDR0, 32'h0);
		test_bench.apb_write(TDR1, 32'h0);

		test_bench.apb_write(TCR, 32'h1);
		repeat(256) @(posedge test_bench.clk);
		#1; test_bench.apb_read(TDR0, rdata0);
		if (rdata0 >= 32'h100)
			$display("[PASS]: Timer is running  normally (Val: %h)", rdata0);
		else 
			$display("[FAIL]: Timer is not running probably (Val: %h)", rdata0);
		
		//TDR1=0, TDR0=0xffff_ff00
		test_bench.apb_write(TDR1, 32'h0);
		test_bench.apb_write(TDR0, 32'hffff_ff00);
		repeat (256) @(posedge test_bench.clk);
		
		test_bench.apb_read(TDR0, rdata0);
		test_bench.apb_read(TDR1, rdata1);
		if (rdata1 == 32'h1) begin
			$display("[PASS]: TDR1 updated correctly");
		end else begin
			$display("%t [FAIL]: TDR1 wrong, exp:1, got:%h", $time, rdata1);
			fail = fail + 1;
		end
		
		$display("\n--- Checking write while disabled ---");
		test_bench.pstrb=4'hF;
		test_bench.apb_write(TCR, 32'h0);

		test_bench.apb_write(TDR0, 32'hDEAD_BEEF);

		test_bench.apb_read(TDR0, rdata0);
		if (rdata0 == 32'hDEAD_BEEF) begin
			$display("[PASS]: Write successful while disabled.");
		end else begin
			$display("%t [FAIL]: Write failed, exp: DEADBEEF, got: %h", $time, rdata0);
			fail = fail + 1;
		end


		$display("\n--- Checking divider update & resume ---");
		test_bench.apb_write(TDR0, 32'h0);

		$display("Configuring Timer: div_val = 3 ---");
		test_bench.apb_write(TCR, 32'h0000_0203);

		test_bench.apb_read(TDR0, start_val);
		repeat(100) @(posedge test_bench.clk);
		test_bench.apb_read(TDR0, end_val);

		diff = end_val - start_val;
		$display("Elapsed: 100 clocks. Counted: %0d", diff);
		if (diff >= 23 && diff <= 27) begin
			$display("[PASS]: Period matches divider (Div=4)");
		end else begin
			$display("[FAIL]: Wrong period, exp: ~25, got: %0d", diff);
			fail = fail + 1;
		end

		$display("\n--- Checking counting during interrupt ---");
		test_bench.apb_write(TIER, 32'h1); //bit 0 = 1
		test_bench.apb_read(TDR0, start_val);
		test_bench.apb_write(TCMP0, start_val + 20);

		repeat(160) @(posedge test_bench.clk);

		test_bench.apb_read(TISR, rdata);
		if (rdata & 32'h1) $display("[INFO] Interrupt Triggered!");
		else $display("[INFO] Interrupt not Triggered!");
		
		test_bench.apb_read(TDR0, end_val);
		if (end_val > (start_val + 20)) begin
			$display("[PASS]: Counter continued counting past Interrupt");
		end else begin
			$display("[FAIL]: Counter stopped at interrupt! Val: %h", end_val);
		        fail = fail + 1;
	        end	   
	    	test_bench.apb_write(TISR, 32'h1);
		
		$display("\n--- Checking counting during overflow ---");
		test_bench.apb_write(TCR, 32'h1);
		test_bench.apb_write(TDR0, 32'hffff_fff0);

		repeat(400) @(posedge test_bench.clk);

		test_bench.apb_read(TDR0, rdata);
		if (rdata < 32'h1000) begin
			$display("[PASS]: Counter wrapped around. Val: %h", rdata);
		end else begin
			$display("[FAIL]: Counter stuck! Val: %h", rdata);
		end

		if (!fail)
			$display("TEST PASSED");
		else 
			$display("TEST FAILED");

		//Fill coverage
		force test_bench.u_dut.u_cnt_ctrl.div_val = 4'd15;
		@(posedge test_bench.clk);
		release test_bench.u_dut.u_cnt_ctrl.div_val;
		@(posedge test_bench.clk);

		force test_bench.u_dut.u_cnt_ctrl.divisor = 9'h1FF;
		repeat(2) @(posedge test_bench.clk);

		force test_bench.u_dut.u_cnt_ctrl.divisor = 9'h000;
		repeat(2) @(posedge test_bench.clk);

		release test_bench.u_dut.u_cnt_ctrl.divisor;

		force test_bench.u_dut.u_cnt_ctrl.pre_cnt=9'h1FF;
		repeat(2) @(posedge test_bench.clk);

		force test_bench.u_dut.u_cnt_ctrl.pre_cnt=9'h000;
		repeat(2) @(posedge test_bench.clk);
		release test_bench.u_dut.u_cnt_ctrl.pre_cnt;

	end
endtask
