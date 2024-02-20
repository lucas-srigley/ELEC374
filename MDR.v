module MDR (
	input wire clr, 
	input wire clk, 
	input wire enable, 
	input wire read,
	input wire [31:0] BusMuxOut,
	input wire [31:0] Mdatain, 
	output reg [31:0] qOut
	
); 

	always@(posedge clk or negedge clr)
		begin 
			if(clr == 0)
				qOut <= 0; 
			else if (enable)
				qOut <= read ? Mdatain : BusMuxOut;
	
			
		end
endmodule 
	