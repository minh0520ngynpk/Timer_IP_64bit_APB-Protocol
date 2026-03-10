task run_test();
	reg [3:0]  fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("=================================================================================================");
		$display("------------------------------ COUNTER CHECK (EN_VAL = 1_reserved) --------------------------------");
		$display("=================================================================================================");

		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk); #1;
		test_bench.rst_n=1'b1;

		//div_en=1 & div_val=0
		test_bench.apb_write(12'h0, 32'h0000_0C03);
		test_bench.apb_write(12'h4, 32'hffff_ff00);
		repeat(255*(1 << 1) - 1) @(posedge test_bench.clk); 
		test_bench.apb_read(12'h4, out_rd);
		if (out_rd == 32'hffff_ff00) begin
			$display("[PASS]: Correct bound count in (reserved) control mode, 32'hffff_ff00, apb blocking TCR, TCR = 32'h0000_0000");
		end else begin
			$display("%t [FAIL]: Wrong bound count in (reserved) control mode, exp: 32'hffff_ff00, got 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end 
	end 
endtask

