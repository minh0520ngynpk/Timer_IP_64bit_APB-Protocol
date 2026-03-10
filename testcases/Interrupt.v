task run_test();
	reg [31:0] out_rd;
	reg [3:0] fail;
	begin
		fail = 0;
		$display("============================================================================================");
		$display("------------------------ INTERRUPT CHECK -------------------------");
		$display("============================================================================================");

		test_bench.rst_n=1'b0;
		test_bench.psel = 1'b0;
		test_bench.pwrite=1'b0;
		test_bench.penable=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;
		
		test_bench.apb_write(12'hc, 32'h0000_00ff); //TCMP0
		test_bench.apb_write(12'h10, 32'h0000_0001); //TCMP1
		test_bench.apb_write(12'h4, 32'hffff_ff00);
		test_bench.apb_write(12'h0, 32'h0000_0003); 
		repeat(255+256) @(posedge test_bench.clk);
		test_bench.apb_read(12'h18, out_rd);
		if (!test_bench.tim_int && out_rd == 32'h1) begin
			$display("[PASS]: Correct interrrupt output without enable, LOW state");
		end else begin
			$display("[FAIL]: Wrong interrupt output without enable, exp: 1'b0, got: 1'b%b", test_bench.tim_int);
		fail = fail + 1;
		end

		//enable int
		test_bench.apb_write(12'h14, 32'h1); //TIER
		if (test_bench.tim_int) begin
			$display("[PASS]: Correct interrupt output with enable, HIGH state");
		end else begin
			$display("[FAIL]: Wrong interrupt output with enable, exp: 1'b1; got: 1'b%b", test_bench.tim_int);
			fail = fail + 1;
		end

		repeat (10) @(posedge test_bench.clk);
		test_bench.apb_write(12'h14, 32'h0);
		test_bench.apb_read(12'h18, out_rd);
		if(!test_bench.tim_int && out_rd == 32'h1) begin
			$display("[PASS]: Correct masking out interrupt output");
		end else begin
			$display("[FAIL]: Wrong masking out interrupt output");
		end

		test_bench.apb_write(12'h18, 32'h0);
		test_bench.apb_read(12'h18, out_rd);
		if (out_rd == 32'h1) begin
			$display("[PASS]: Not clear interrupt status until write 1");
		end else begin
			$display("[FAIL]: Clear interrupt status though not write 1");
		end

		test_bench.apb_write(12'h18, 32'h1); //RW1C at TISR
		test_bench.apb_read(12'h18, out_rd);
		if (out_rd == 32'h0) begin
			$display("[PASS]: Correct clear interrupt status");
		end else begin
			$display("[FAIL]: Wrong clear interrupt status");
		end

		test_bench.apb_write(12'h0, 32'h0); //Toggle down div_en retain the current counter & cover full coverage
		test_bench.apb_write(12'h4, 32'h0);
		test_bench.apb_write(12'h8, 32'h0);

		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end
	end
endtask
