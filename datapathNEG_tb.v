`timescale 1ns / 10ps
module datapathNEG_tb; 	
	reg	PCout, ZHighout, Zlowout, MDRout, R2out, R3out, R4out, R5out, R6out, R7out;
	reg	MARin, PCin, MDRin, IRin, Yin;
	reg 	IncPC, Read;
	reg 	[4:0] NEG; 
	reg 	R1in, R2in, R3in;
	reg   R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
	reg	HIin, LOin, ZHighIn, ZLowIn, Cin;
	reg	Clock, Clear;	
	reg	[31:0] Mdatain;

parameter	Default = 4'b0000, Reg_load1a= 4'b0001, Reg_load1b= 4'b0010,
					Reg_load2a= 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101,
					Reg_load3b = 4'b0110, T0= 4'b0111, T1= 4'b1000,T2= 4'b1001, T3= 4'b1010, T4= 4'b1011, T5= 4'b1100;
reg	[3:0] Present_state= Default;

initial Clear = 0;

DataPath DUT(PCout, ZHighout, Zlowout, MDRout, R2out, R3out, R4out, R5out, R6out, R7out,
					MARin, PCin, MDRin, IRin, Yin, 
					IncPC, Read, 
					NEG,
					R1in, R2in, R3in, 
					R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in, 
					HIin, LOin, ZHighIn, ZLowIn, Cin,
					Clock, Clear, 
					Mdatain);
// add test logic here

initial 
	begin
		Clock = 0;
		forever #10 Clock = ~ Clock;
end

always @(posedge Clock)
begin
	case (Present_state)
		Default			:	#40 Present_state = Reg_load1a;
		Reg_load1a		:	#40 Present_state = Reg_load1b;
		Reg_load1b		:	#40 Present_state = Reg_load2a;
		Reg_load2a		:	#40 Present_state = Reg_load2b;
		Reg_load2b		:	#40 Present_state = Reg_load3a;
		Reg_load3a		:	#40 Present_state = Reg_load3b;
		Reg_load3b		:	#40 Present_state = T0;
		T0					:	#40 Present_state = T1;
		T1					:	#40 Present_state = T2;
		T2					:	#40 Present_state = T3;
		T3					:	#40 Present_state = T4;
		T4					:	#40 Present_state = T5;
		endcase
	end

always @(Present_state)
begin
	case (Present_state)              
		Default: begin
				PCout <= 0;   Zlowout <= 0; ZHighout <= 0;  MDRout<= 0;   
				R2out <= 0;   R3out <= 0;   MARin <= 0;   ZLowIn <= 0;  
				PCin <=0;   MDRin <= 0;   IRin  <= 0;   Yin <= 0;  
				IncPC <= 0;   Read <= 0;   NEG <= 0;
				R6in <= 0; R7in <= 0; R3in <= 0; Mdatain <= 32'h00000000;
		end
		Reg_load1a: begin 
				Mdatain<= 32'h00000012;
				Read = 0; MDRin = 0;	
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load1b: begin
				#10 MDRout<= 1; R7in <= 1;  
				#15 MDRout<= 0; R7in <= 0;     // initialize R2 with the value $12
		end
		Reg_load2a: begin 
				Mdatain <= 32'h00000014;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load2b: begin
				#10 MDRout<= 1; R3in <= 1;  
				#15 MDRout<= 0; R3in <= 0;		// initialize R3 with the value $14 
		end
		Reg_load3a: begin 
				Mdatain <= 32'h00000018;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load3b: begin
				#10 MDRout<= 1; R6in <= 1;  
				#15 MDRout<= 0; R6in <= 0;		// initialize R1 with the value $18
		end
	
		T0: begin
				Mdatain <= 32'h00000007; 
				PCin <= 1; MDRout <=1;
				
				#10 PCout<= 1; MARin <= 1; IncPC <= 1; 
				#10 PCin <= 0; MDRout <=0; PCout<= 0; MARin <= 0; IncPC <= 0;
		end
		T1: begin
				Mdatain <= 32'h28918000;   // opcode for “and R1, R2, R3
				Read <= 1; MDRin <= 1;
				#10 Read <= 0; MDRin <= 0;
				
		end
		T2: begin
				MDRout<= 1; IRin <= 1; 
				#10 MDRout<= 0; IRin <= 0; 
		end
		T3: begin
				#10 R2out<= 1; Yin <= 1;  
				#15 R2out<= 0; Yin <= 0;
		end
		T4: begin
				R3out<= 1; NEG <= 5'b10001; ZLowIn <= 1; 
				#25 R3out<= 0; ZLowIn <= 0; 
		end
		T5: begin
				Zlowout<= 1; R6in <= 1; 
				#25 Zlowout<= 0; R6in <= 0;
		end
	endcase
end
endmodule
