task run_test();
	reg fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("==========================================================================");
		$display("----------------- RESERVED CHECK ------------------");
		$display("==========================================================================");

		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;
		test_bench.apb_write(12'h1D, 32'hffff_ffff);
		test_bench.apb_read(12'h1D, out_rd);
		if (out_rd == 32'h0000_0000) begin
			$display("[PASS]: Read reserved is always zero, 32'h0000_0000");
		end else begin
			$display("%t [FAIL]: Not read reserved as zero, exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		test_bench.apb_write(12'h3FC, 32'hffff_ffff);
		test_bench.apb_read(12'h3FC, out_rd);
		if (out_rd == 32'h0000_0000) begin
			$display("[PASS]: Read reserved is always zero, 32'h0000_0000");
		end else begin
			$display("%t [FAIL]: Not read reserved as zero, exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end 
	end 
endtask
