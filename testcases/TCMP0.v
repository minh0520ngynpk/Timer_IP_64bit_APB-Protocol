task run_test();
	reg fail;
	reg [31:0] out_rd;
	begin
		fail = 0;
		$display("######################################################");
		$display("-------------------- TCMP0 CHECK ---------------------");
		$display("######################################################");
		$display("================= Check R/W ================");
		test_bench.rst_n=1'b0;
		@(posedge test_bench.clk);
		#1; test_bench.rst_n=1'b1;
		test_bench.apb_read (12'hc, out_rd);
		if (out_rd == 32'hffff_ffff) begin
			$display("[PASS]: Correct initial value, 32'hffff_ffff");
		end else begin
			$display("%t [FAIL]: Wrong initial value, exp: 32'hffff_ffff, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n========== Write 32'h0000_0000 =============");
		test_bench.apb_write(12'hc, 32'h0000_0000);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'h0000_0000) begin
			$display("[PASS]: Read 32'h0000_0000 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h0000_0000 incorrectly, exp: 32'h0000_0000, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n========== Write 32'hffff_ffff =============");
		test_bench.apb_write(12'hc, 32'hffff_ffff);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'hffff_ffff) begin
			$display("[PASS]: Read 32'hffff_ffff correctly");
		end else begin
			$display("%t [FAIL]: Read 32'hffff_ffff incorrectly, exp: 32'hffff_ffff, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		$display("\n========== Write 32'h5555_5555 =============");
		test_bench.apb_write(12'hc, 32'h5555_5555);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'h5555_5555) begin
			$display("[PASS]: Read 32'h5555_5555 correctly");
		end else begin
			$display("%t [FAIL]: Read 32'h5555_5555 incorrectly, exp: 32'h5555_5555, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		$display("\n========== Write 32'haaaa_aaaa =============");
		test_bench.apb_write(12'hc, 32'haaaa_aaaa);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'haaaa_aaaa) begin
			$display("[PASS]: Read 32'haaaa_aaaa correctly");
		end else begin
			$display("%t [FAIL]: Read 32'haaaa_aaaa incorrectly, exp: 32'haaaa_aaaa, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end

		$display("\n================== Byte Access =========================");
		test_bench.pstrb=4'h0;
		test_bench.apb_write(12'hc, 32'h3333_3333);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'haaaa_aaaa) begin
			$display("[PASS]: Correct byte access 4'b0000 pstrb, 32'haaaa_aaaa\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0000 pstrb, exp: 32'haaaa_aaaa, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end


		test_bench.pstrb=4'h1;
		test_bench.apb_write(12'hc, 32'h4444_4444);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'haaaa_aa44) begin
			$display("[PASS]: Correct byte access 4'b0001 pstrb, 32'haaaa_aa44\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0001 pstrb, exp: 32'haaaa_aa44, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h2;
		test_bench.apb_write(12'hc, 32'h6666_6666);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'haaaa_6644) begin
			$display("[PASS]: Correct byte access 4'b0010 pstrb, 32'haaaa_6644\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0010 pstrb, exp: 32'haaaa_6644, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h4;
		test_bench.apb_write(12'hc, 32'h7777_7777);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'haa77_6644) begin
			$display("[PASS]: Correct byte access 4'b0100 pstrb, 32'haa77_6644\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0100 pstrb, exp: 32'haa77_6644, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h8;
		test_bench.apb_write(12'hc, 32'h8888_8888);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'h8877_6644) begin
			$display("[PASS]: Correct byte access 4'b1000 pstrb, 32'h8877_6644\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b1000 pstrb, exp: 32'h8877_6644, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		test_bench.pstrb=4'h3;
		test_bench.apb_write(12'hc, 32'h1111_1111);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'h8877_1111) begin
			$display("[PASS]: Correct byte access 4'b0011 pstrb, 32'h8877_1111\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0011 pstrb, exp: 32'h8877_1111, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end
		
		//test_bench.pstrb=4'h1; //init
		//test_bench.apb_write(12'h0, 32'h0000_0000);
		
		test_bench.pstrb=4'h6;
		test_bench.apb_write(12'hc, 32'h2222_2222);
		test_bench.apb_read(12'hc, out_rd);
		if (out_rd == 32'h8822_2211) begin
			$display("[PASS]: Correct byte access 4'b0110 pstrb, 32'h8822_2211\n");
		end else begin
			$display("%t [FAIL]: Incorrect byte access 4'b0110 pstrb, exp: 32'h8822_2211, got: 32'h%h", $time, out_rd);
			fail = fail + 1;
		end


		if (!fail) begin
			$display("TEST PASSED");
		end else begin
			$display("TEST FAILED");
		end
	end
endtask

