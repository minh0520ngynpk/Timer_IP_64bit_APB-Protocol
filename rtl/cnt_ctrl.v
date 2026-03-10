module cnt_ctrl(
	input wire clk, rst_n,
	input wire timer_en, div_en, 
	input wire [3:0] div_val,
	input wire halt_req,
	input wire dbg_mode,

	output wire stop, halt_ack,
	output wire hw_clear,
	output reg tick //Enable counter
);

reg [8:0] divisor;
reg [8:0] pre_cnt;
reg       timer_en_d;

//Halt logic
assign stop = halt_req && dbg_mode;
assign halt_ack = stop;

//Detect falling edge of timer_en
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) timer_en_d <= 1'b0;
	else timer_en_d <= timer_en;
end
assign hw_clear = timer_en_d && !timer_en;

//Prescaler
always @(*) begin
	case(div_val)
		4'd0: divisor = 9'd1;
		4'd1: divisor = 9'd2;
		4'd2: divisor = 9'd4;
		4'd3: divisor = 9'd8;
		4'd4: divisor = 9'd16;
		4'd5: divisor = 9'd32;
		4'd6: divisor = 9'd64;
		4'd7: divisor = 9'd128;
		4'd8: divisor = 9'd256;
		default: divisor = 9'd2; //Default value
	endcase
end

//Prescaler Counter
always @(posedge clk or negedge rst_n) begin
	if (!rst_n || hw_clear) begin
		pre_cnt <= 9'd0;
		tick <= 1'b0;
	end else if (timer_en && !stop) begin
		if (div_en) begin
			if (pre_cnt >= (divisor - 1)) begin
				pre_cnt <= 9'd0;
				tick <= 1'b1;
			end else begin
				pre_cnt <= pre_cnt + 1;
				tick <= 1'b0;
			end
		end else begin
			tick <= 1'b1; //No division
		end
	end else begin
		tick <= 1'b0; //Not running
	end
end
endmodule

