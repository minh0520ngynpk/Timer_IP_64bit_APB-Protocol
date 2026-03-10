task run_test();
	reg fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("######################################################");
		$display("-------------------- TCR CHECK ---------------------");
		$display("######################################################");
		$display("================= Check R/W ================");
		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;
		test_bench.apb_read (12'h0, out_rd);
		if (out_rd == 32'h0000_0100) begin
			$display("[PASS]: Correct initial value, 32'h0000_0100");
		end else begin
			$display("%t [FAIL]: Wrong initial value, exp: 32'h0000_0100, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n========== Write 32'h0000_0000 =============");
		test_bench.apb_write(12'h0, 32'h0000_0000);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0000) begin
			$display("[PASS]: Read 32'h0000_0000 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h0000_0000 incorrectly, exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n========== Write 32'hffff_ffff =============");
		test_bench.apb_write(12'h0, 32'hffff_ffff);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0000) begin
			$display("[PASS]: Read 32'h0000_0000 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h0000_0000 incorrectly, exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		$display("\n========== Write 32'h5555_5555 =============");
		test_bench.apb_write(12'h0, 32'h5555_5555);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0501) begin
			$display("[PASS]: Read 32'h0000_0501 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h0000_0501 incorrectly, exp: 32'h0000_0501, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		$display("\n========== Write 32'haaaa_aaaa =============");
		test_bench.apb_write(12'h0, 32'haaaa_aaaa);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0501) begin
			$display("[PASS]: Read 32'h0000_0501 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h0000_0501 incorrectly, exp: 32'h0000_0501, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n================== Byte Access =========================");
		test_bench.pstrb=4'h0;
		test_bench.apb_write(12'h0, 32'h3333_3333);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0501) begin
			$display("[PASS]: Correct byte access 4'b0000 pstrb, 32'h0000_0501\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0000 pstrb, exp: 32'h0000_0501, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end


		test_bench.pstrb=4'h1;
		test_bench.apb_write(12'h0, 32'h4444_4444);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0500) begin
			$display("[PASS]: Correct byte access 4'b0001 pstrb, 32'h0000_0500\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0001 pstrb, exp: 32'h0000_0500, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h2;
		test_bench.apb_write(12'h0, 32'h6666_6666);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0600) begin
			$display("[PASS]: Correct byte access 4'b0010 pstrb, 32'h0000_0600\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0010 pstrb, exp: 32'h0000_0600, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h4;
		test_bench.apb_write(12'h0, 32'h7777_7777);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0600) begin
			$display("[PASS]: Correct byte access 4'b0100 pstrb, 32'h0000_0600\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0100 pstrb, exp: 32'h0000_0600, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h8;
		test_bench.apb_write(12'h0, 32'h8888_8888);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0600) begin
			$display("[PASS]: Correct byte access 4'b1000 pstrb, 32'h0000_0600\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b1000 pstrb, exp: 32'h0000_0600, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h3;
		test_bench.apb_write(12'h0, 32'h1111_1111);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0101) begin
			$display("[PASS]: Correct byte access 4'b0011 pstrb, 32'h0000_0101\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0011 pstrb, exp: 32'h0000_0101, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h1; //init
		test_bench.apb_write(12'h0, 32'h0000_0000);
		
		test_bench.pstrb=4'h6;
		test_bench.apb_write(12'h0, 32'h2222_2222);
		test_bench.apb_read(12'h0, out_rd);
		if (out_rd == 32'h0000_0200) begin
			$display("[PASS]: Correct byte access 4'b0110 pstrb, 32'h0000_0200\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0110 pstrb, exp: 32'h0000_0200, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end


		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end
	end
endtask
