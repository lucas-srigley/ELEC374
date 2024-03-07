`timescale 1ns/10ps
module ld_tb; //Add name of test bench here.
    reg PC_out, ZLow_out, ZHigh_out, HI_out, LO_out, C_out, in_port_out; 
    wire [31:0] MDR_data_out;
    reg MDR_out;
    reg MAR_enable, Z_enable, PC_enable, MDR_enable, IR_enable, Y_enable, LO_enable, HI_enable, InPort;
    reg IncPC, Read;
    reg [4:0] opcode;
    reg Clock, clr;
    wire [31:0] Mdatain;

    //Phase 2 Shiz
    reg con_in, in_port_in, BA_out,Gra, Grb, Grc, out_port_enable, R_in, R_out, in_port_enable;
    reg RAM_write_enable;

    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, Reg_load2a = 4'b0011,
    Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, T0 = 4'b0111,
    T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100, T6= 4'b1101, T7= 4'b1110;
    reg [3:0] Present_state = Default;

		DataPath DUT(
			 // Outputs
			 Mdatain, MDR_data_out,
			 // Inputs
			 PC_out, ZHigh_out, ZLow_out, HI_out, LO_out, C_out,
			 MDR_out, MDR_enable, MAR_enable, Z_enable, Y_enable, PC_enable, LO_enable, 
			 HI_enable, clr, Clock, InPort, IncPC, Read,
			 opcode,
			 // Phase 2 Inputs/Outputs
			 con_in, out_port_enable, RAM_write_enable, IR_enable,
			 Gra, Grb, Grc, R_in, R_out, BA_out, in_port_out, in_port_enable
		);


    initial
        begin
            Clock = 0;
            forever #10 Clock = ~ Clock;
        end

    always @(posedge Clock) // finite state machine; if clock rising-edge
        begin
            case (Present_state)
                Default : Present_state = T0;
                T0 : #40  Present_state = T1;
                T1 : #40  Present_state = T2;
                T2 : #40  Present_state = T3;
                T3 : #40  Present_state = T4;
                T4 : #40  Present_state = T5;
                T5 : #40  Present_state = T6;
                T6 : #40  Present_state = T7;
            endcase
        end

    always @(Present_state) // do the required job in each state
        begin
            case (Present_state) // assert the required signals in each clock cycle
                Default: begin
                    PC_out <= 0; ZLow_out <= 0; clr<=0;
                    MAR_enable <= 0; Z_enable <= 0;
                    PC_enable <=0; MDR_enable <= 0; IR_enable= 0; Y_enable= 0;
                    IncPC <= 0; Read <= 0; opcode <= 0;
                    ZHigh_out <= 0; HI_out <= 0; LO_out <= 0; C_out <= 0; in_port_out <= 0;
                    MDR_out <= 0;

                    // Phase 2 Initialization process for signals
                    Gra <= 0; Grb<= 0; Grc<=0; BA_out <=0; RAM_write_enable <=0; out_port_enable <=0; 
                    in_port_in <=0; con_in<=0; R_out <= 0; R_in <=0; in_port_enable <=0;
                end

                // ----------------------------------- T0 INSTRUCTION FETCH ----------------------------------- // 
                T0: begin
                    PC_out <= 1; MAR_enable <= 1; PC_enable <= 1;
                end
                // ----------------------------------- T1 INSTRUCTION FETCH ----------------------------------- // 
                T1: begin
                    PC_out <= 0; MAR_enable <= 0; PC_enable <= 0;

                    //Instruction to fetch from RAM.
                    Read <= 1;
                    MDR_enable <= 1; 
                end
                // // ----------------------------------- T2 INSTRUCTION FETCH ----------------------------------- // 
                T2: begin
                    MDR_enable <= 0;
                    MDR_out <= 1; IR_enable <= 1; 
                end
                // // ----------------------------------- T3 CYCLE OPERATION ----------------------------------- // 
                T3: begin
                    MDR_out <= 0; IR_enable <= 0;

                    Grb <= 1; BA_out <= 1; Y_enable <= 1; //Sends out the data of reg to Y
                end
                // // // ----------------------------------- T4 CYCLE OPERATION ----------------------------------- // 
                T4: begin
                    Grb <= 0; BA_out <= 0; Y_enable <= 0;

                    C_out<= 1; Z_enable <= 1; opcode <= 5'b00011; //ADD OP CODE, send $45 to ALU and add
                end
                //  // ----------------------------------- T5 CYCLE OPERATION ----------------------------------- // 
                T5: begin
                    C_out<= 0; Z_enable <= 0; 

                    // Notes ZLow out is the effective address we are looking into the ram for the data.
                    ZLow_out <= 1; MAR_enable <=1; //Sending it back to MAR to get the effective memory address
                end
                //  // ----------------------------------- T6 CYCLE OPERATION ----------------------------------- // 
                T6: begin
                    ZLow_out <= 0; MAR_enable <=0;

                    //Fetching data from ram
                    Read <= 1; MDR_enable <=1;  
                end
                //  // ----------------------------------- T7 CYCLE OPERATION ----------------------------------- // 
                T7: begin
                    MDR_enable <=0;

                    //Send the data that was taken from ram and load it into register R1
                    MDR_out <=1; //Data from ram
                    Gra <= 1; 
                    R_in <= 1;
                    // MDR_out <= 0; //Data from ram
                    // Gra <= 0; 
                    // R_in <= 0;
                end
            endcase
        end
endmodule