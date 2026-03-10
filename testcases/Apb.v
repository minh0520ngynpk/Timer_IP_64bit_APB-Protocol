task run_test();
	integer fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("============================================================================================");
		$display("------------------------ APB SETTING CHECK -------------------------");
		$display("============================================================================================");

		test_bench.rst_n=1'b0;
		test_bench.psel = 1'b1;
		test_bench.pwrite=1'b1;
		test_bench.penable=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;

		//Check wait state
		//Write 
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b1;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		@(posedge test_bench.clk); #1;
		if (test_bench.pready) begin
			$display("[PASS]: Correct trigger APB's pready - write");
		end else begin
			$display("[FAIL]: Wrong trigger APB's pready - write");
		end

		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b0; test_bench.psel=1'b0; test_bench.pwrite=1'b0;
		#1;
		if (!test_bench.pready) begin
			$display("[PASS]: Correct toggle down APB's pready - write");
		end else begin
			$display("[FAIL]: Wrong toggle down APB's pready - write");
		end

		//Read
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b0;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		@(posedge test_bench.clk); #1;
		if (test_bench.pready) begin
			$display("[PASS]: Correct trigger APB's pready - read");
		end else begin
			$display("[FAIL]: Wrong trigger APB's pready - read");
		end

		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b0; test_bench.psel=1'b0;
		#1;
		if (!test_bench.pready) begin
			$display("[PASS]: Correct toggle down APB's pready - read");
		end else begin
			$display("[FAIL]: Wrong toggle down APB's pready - read");
		end 

		$display("\n-------------- ERROR RESPONSE CHECK ---------------");
		test_bench.pstrb=4'hf;
		test_bench.apb_write(TCR, 32'h0000_0503); //timer_en && div_val=5
		//Check div_val while timer_en
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b1; test_bench.paddr=12'h0; test_bench.pwdata=32'h0000_0703;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		wait(pready); #1;
		if (pslverr) begin
			$display("[PASS]: Correct error response when modifying div_val during timer_en");
		end else begin
			$display("[FAIL]: Wrong error response when modyfying div_val during timer_en");
		end 

		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b0; test_bench.pwrite=1'b0; test_bench.penable=1'b0;

		//Change div_en while timer_en
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b1; test_bench.paddr=12'h0; test_bench.pwdata=32'h0000_0701;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		wait(pready); #1;
		if (pslverr) begin
			$display("[PASS]: Correct error repsponse when modifying div_en during timer_en");
		end else begin
			$display("[FAIL]: Wrong error response when modifying div_en during timer_en");
		end
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b0; test_bench.pwrite=1'b0; test_bench.penable=1'b0;

		//Div_val > 8
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b1; test_bench.paddr=12'h0; test_bench.pwdata=32'h0000_0c00;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		wait(pready); #1;
		if (pslverr) begin
			$display("[PASS]: Correct error response when writing prohibit div_val");
		end else begin
			$display("[FAIL]: Wrong error response when writing prohibit div_val");
		end
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b0; test_bench.pwrite=1'b0; test_bench.penable=1'b0;
		
		$display("\n--------------- WRONG APB CHECK ------------------");
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b1; test_bench.paddr=12'h10; test_bench.pwdata=32'h0123_4567;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		wait(pready); test_bench.psel=1'b0;
		@(posedge test_bench.clk); #1;
		test_bench.pwrite=1'b0; test_bench.penable=1'b0;
		test_bench.apb_read(12'h10, out_rd);
		if (out_rd != 32'h0123_4567) begin
			$display("[PASS]: Data is not written if setup is not successful");
		end else begin
			$display("[FAIL]: Data is written");
		end

		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b1; test_bench.pwrite=1'b0; test_bench.paddr=12'h10;
		@(posedge test_bench.clk); #1;
		test_bench.penable=1'b1;
		wait(pready);
		test_bench.psel=1'b0;
		@(posedge test_bench.clk); #1;
		test_bench.psel=1'b0;
		#1;
		if (!test_bench.prdata) begin
			$display("[PASS]: Data is not read if setup is not successful, as zero");
		end else begin
			$display("[FAI:]: Data is not read if setup is not successful, exp: 32'h0, got: 32'h%h", out_rd);
		end

	if (!fail) begin
		$display("TEST PASSED");
	end else begin
		$display("TEST FAILED");
	end

	//Fill coverage
	test_bench.rst_n=1'b0; @(posedge test_bench.clk);
	test_bench.rst_n=1'b1; @(posedge test_bench.clk);
	test_bench.pstrb=4'hf;
	test_bench.apb_write(TCR, 32'h0000_0900);

	test_bench.apb_write(12'h0, 32'h0000_0F00);

	test_bench.apb_write(12'h0, 32'h0000_0001);

	test_bench.apb_write(12'h0, 32'h0000_0101);

	test_bench.apb_write(12'h0, 32'h0000_0003);

	test_bench.apb_write(12'h0, 32'h0000_0000);
	
	test_bench.apb_read(12'h002, out_rd);

	test_bench.apb_read(12'h400, out_rd);

	test_bench.apb_read(12'h800, out_rd);

	test_bench.apb_read(12'h00, out_rd);

	test_bench.apb_write(12'h0, 32'h0000_0802);

	test_bench.apb_write(12'h0, 32'h0000_0000);

	//@(posedge test_bench.clk);
	//test_bench.rst_n=1'b0;
	//@(posedge test_bench.clk);
	//test_bench.rst_n=1'b1;

	test_bench.pstrb=4'h1;
	test_bench.apb_write(12'h0, 32'h0000_0001);
	
	test_bench.pstrb=4'h2;
	test_bench.apb_write(12'h0, 32'h0000_0200);

	test_bench.pstrb=4'hf;
	
	test_bench.apb_read(12'h3E0, out_rd);

	test_bench.apb_read(12'h000, out_rd);

	@(posedge test_bench.clk);
	test_bench.penable = 1'b0;
	test_bench.psel = 1'b0;

	@(posedge test_bench.clk);
	test_bench.penable = 1'b0;
	test_bench.psel = 1'b1;
	
	@(posedge test_bench.clk);
	test_bench.penable = 1'b1;
	
	@(posedge test_bench.clk);
	test_bench.penable = 1'b0;

	@(posedge test_bench.clk);
	test_bench.psel = 1'b0;

end
endtask
