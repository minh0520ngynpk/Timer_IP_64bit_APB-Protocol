task run_test();
	integer fail;
	reg [31:0] val1;
	reg [31:0] val2;
	begin
		fail = 0;
		$display("===============================================================================");
		$display("----------------- HALT (DEBUG MODE) CHECK -------------------");
		$display("===============================================================================");
		
		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;

		//setup
		test_bench.pstrb=4'hF;
		test_bench.apb_write(TCR, 32'h0);
		test_bench.apb_write(TCMP0, 32'hFFFF_FFFF);
		test_bench.apb_write(TDR0, 32'h0);

		test_bench.halt_req = 1'b0;
		test_bench.dbg_mode = 1'b0;

		$display("--- Debug mode = 1, Counter halted ---");
		test_bench.dbg_mode = 1'b1;
		test_bench.apb_write(TCR, 32'h1);
		repeat(20) @(posedge test_bench.clk);
		$display("Asserting halt_req = 1...");
		test_bench.halt_req = 1'b1;
		repeat(10) @(posedge test_bench.clk);
		
		//check halt
		if (test_bench.halt_ack == 1'b1) begin
			$display("[PASS]: Halt_ack asserted correctly");
		end else begin
			$display("%t [FAIL]: Halt_ack not asserted correctly, got 0", $time);
			fail = fail + 1;
		end

		//check counter
		test_bench.apb_read(TDR0, val1);
		repeat(20) @(posedge test_bench.clk);
		test_bench.apb_read(TDR0, val2);
		if (val1 == val2) begin
			$display("[PASS]: Counter stopped correctly (Val stuck at %h).", val1);
		end else begin
			$display("%t [FAIL]: Counter did not stop! (%h -> %h)", $time, val1, val2);
		end

		$display("De-asserting halt_req = 0...");
		test_bench.halt_req = 1'b0;
		repeat(20) @(posedge test_bench.clk);
		if (test_bench.halt_ack == 0) begin
			$display("[PASS] Halt_ack cleared");
		end else begin
			$display("%t [FAIL] Halt_ack stuck at 1", $time);
			fail = fail + 1;
		end

		test_bench.apb_read(TDR0, val1);
		if (val1 > val2) begin
			$display("[PASS]: Counter resumed correctly (Val: %h).", val1);
		end else begin
			$display("%t [FAIL]: Counter stuck after resume (Val: %h)", $time, val1);
			fail = fail + 1;
		end

		$display("\n--- Debug mode = 0, Counter not halted ---");
		test_bench.dbg_mode = 1'b0;

		$display("Asserting halt_req = 1 (expect ignored)...");
		test_bench.halt_req = 1'b1;
		repeat(20) @(posedge test_bench.clk);

		//check halt
		if (test_bench.halt_ack == 0) begin
			$display("[PASS]: Halt ack = 0 (correctly ignored)");
		end else begin
			$display("%t [FAIL]: Halt ack asserted in normal mode", $time);
			fail = fail + 1;
		end

		//check counter
		test_bench.apb_read(TDR0, val1);
		repeat(20) @(posedge test_bench.clk);
		test_bench.apb_read(TDR0, val2);
		if (val2 > val1) begin
			$display("[PASS]: Counter kept running (ignored halt). %h -> %h", val1, val2);
		end else begin
			$display("%t [FAIL]: Counter stopped in normal mode", $time);
			fail = fail + 1;
		end

		test_bench.halt_req = 0;

		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end

		//Toggle coverage
		force test_bench.u_dut.u_regset.halt_ack = 1'b1;
		@(posedge test_bench.clk);
		force test_bench.u_dut.u_regset.halt_ack = 1'b0;
		@(posedge test_bench.clk);
		release test_bench.u_dut.u_regset.halt_ack;

	end 
endtask

