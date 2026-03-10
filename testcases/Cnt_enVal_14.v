task run_test();
	reg [3:0]  fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("=================================================================================================");
		$display("------------------------------ COUNTER CHECK (EN_VAL = 14) --------------------------------");
		$display("=================================================================================================");

		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk); #1;
		test_bench.rst_n=1'b1;

		//div_en=1 & div_val=0
		test_bench.apb_write(12'h0, 32'h0000_0403);
		test_bench.apb_write(12'h4, 32'hffff_ff00);
		repeat(255*(1 << 4)) @(posedge test_bench.clk); 
		test_bench.apb_read(12'h4, out_rd);
		if (out_rd == 32'hffff_ffff) begin
			$display("[PASS]: Correct bound count in (4'b0100) control mode, 32'hffff_ffff");
		end else begin
			$display("%t [FAIL]: Wrong bound count in (4'b0100) control mode, exp: 32'hffff_ffff, got 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		repeat(13) @(posedge test_bench.clk);
		test_bench.apb_read(12'h4, out_rd);
		if (out_rd == 32'h0) begin
			$display("[PASS]: Cont correctly again after ovf in (4'b0100) control mode (32-bit LSB), 32'h0000_0000");
		end else begin
			$display("%t [FAIL]: Wrong count again after overflow in (4'b0100) control mode (32-bit LSB), exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		test_bench.apb_read(12'h8, out_rd);
		if (out_rd == 32'h1) begin
			$display("[PASS]: Correctly count again after overflow in (4'b0100) control mode (32-bit MSB), 32'h0000_0001");
		end else begin
			$display("[FAIL]: Wrong count again after overflow in (4'b0100) control mode (32-bit MSB), exp: 32'h0000_0001, got 32'h%h", out_rd);
		end

		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end 
	end 
endtask


