`timescale 1ns/10ps
module crc(crc_if m);
  logic [31:0] CRC_DATA;
  logic [31:0] checksum_16_crc, checksum_tot, checksum_16_tot;
  logic [31:0] checksum_crc;
  logic [31:0] CRC_GPOLY;
  logic [31:0] CRC_CTRL;
  logic [31:0] seed;
  logic [31:0] seed_16;
  logic [31:0] seed_32;
  logic [31:0] seed_shift;
  logic [31:0] seed_shift_16;
  logic [31:0] data_shift;
  logic [31:0] data_shift_16;
  logic [31:0] checksum;
  logic [31:0] checksum_16;
  logic [1:0] TOT; 
  logic [1:0] TOTR;
  logic FXOR, WAS, TCRC;
  integer i;
assign TOT = CRC_CTRL[31:30];
assign TOTR = CRC_CTRL[29:28];
assign FXOR = CRC_CTRL[26];
assign WAS = CRC_CTRL[25];
assign TCRC = CRC_CTRL[24];

always @ (posedge m.clk or posedge m.rst) begin
if(m.rst)
  begin
    checksum_crc  = 32'hFFFF_FFFF;
    checksum_16_crc = 32'hFFFF_FFFF;
    checksum = 32'hFFFF_FFFF;
    checksum_16 = 32'h0000_FFFF;
    CRC_GPOLY = 32'h0000_1021;
    CRC_CTRL = 32'h0000_0000;		
  end
else if (m.rst == 0 && m.Sel == 1 && m.RW == 1) begin
                	case (m.addr)        
                		32'h4003_2000 : begin
					if(TCRC == 1) begin
					if(WAS == 0 && m.Sel == 1 && m.RW == 1) begin
						seed_shift = checksum_crc;					
						data_shift = seed;
 						for(i = 0; i < 32; i = i+1) begin
   							if (seed_shift[31] == 0) begin
								seed_shift = seed_shift<<1;	
     								seed_shift = {seed_shift[31:1], data_shift[31]};
								data_shift = data_shift<<1;
   							end
   							else if (seed_shift[31] == 1) begin
								seed_shift = seed_shift<<1;
								seed_shift[0] = data_shift[31];
     								data_shift = data_shift<<1;
								seed_shift = seed_shift ^ CRC_GPOLY;
   							end
 		 				end
						checksum_crc = seed_shift;
					end
					else if (WAS == 1 && m.Sel == 1 && m.RW == 1) begin
						checksum_crc = seed;		
					end
					end
	//////////////////////////////////////// 16 bit Operation//////////////////////////////////////////////
					else if (TCRC == 0) begin 
					if(WAS == 0 && m.Sel == 1 && m.RW == 1) begin
						seed_shift_16 = checksum_16_crc;					
						data_shift_16 = seed;
 						for(i = 0; i < 32; i = i+1) begin
   							if (seed_shift_16[15] == 0) begin
								seed_shift_16 = seed_shift_16<<1;
								seed_shift_16[0] = data_shift_16[31];	
								data_shift_16 = data_shift_16<<1;
   							end
   							else if (seed_shift_16[15] == 1) begin
								seed_shift_16 = seed_shift_16<<1;
								seed_shift_16[0] = data_shift_16[31];
     								data_shift_16 = data_shift_16<<1;
								seed_shift_16[15:0] = seed_shift_16[15:0] ^ CRC_GPOLY[15:0];
   							end
 		 				end
							if (i == 32) begin	
								checksum_16_crc = {16'h0000, seed_shift_16[15:0]};
							end
					end
					else if (WAS == 1 && m.Sel == 1 && m.RW == 1) begin
						checksum_16_crc = seed;		
					end
					end
				end
                		32'h4003_2004 : CRC_GPOLY = m.data_wr;
                		32'h4003_2008 : CRC_CTRL = m.data_wr;
                //default : ;
              		endcase
            	end
end
always @(*) begin
    if (m.rst) begin
        checksum_tot = 32'hFFFF_FFFF;
        checksum_16_tot = 32'hFFFF_FFFF;
    end
    else
	if (m.rst == 0 && m.Sel == 1 && m.RW == 0) begin
               	case (m.addr)
                		32'h4003_2000 : begin 
						if (TCRC == 1 && m.Sel == 1 && m.RW == 0) begin 
							m.data_rd = seed_32;
						end							
						else if (TCRC == 0 && m.Sel == 1 && m.RW == 0) begin
							m.data_rd = seed_16; 
						end
						end
				32'h4003_2004 : m.data_rd  = CRC_GPOLY;			
                32'h4003_2008 : m.data_rd = CRC_CTRL;
                //default : ;
			endcase
        end
        
CRC_DATA = m.data_wr;
case (TOT)
  2'b00 :
      seed[31:0] = CRC_DATA[31:0];
  2'b01 :
 begin
      seed[31:24] = {CRC_DATA[24],CRC_DATA[25],CRC_DATA[26],CRC_DATA[27],CRC_DATA[28],CRC_DATA[29],CRC_DATA[30],CRC_DATA[31]};
      seed[23:16] = {CRC_DATA[16],CRC_DATA[17],CRC_DATA[18],CRC_DATA[19],CRC_DATA[20],CRC_DATA[21],CRC_DATA[22],CRC_DATA[23]};
      seed[15:8] = {CRC_DATA[8],CRC_DATA[9],CRC_DATA[10],CRC_DATA[11],CRC_DATA[12],CRC_DATA[13],CRC_DATA[14],CRC_DATA[15]};
      seed[7:0] = {CRC_DATA[0],CRC_DATA[1],CRC_DATA[2],CRC_DATA[3],CRC_DATA[4],CRC_DATA[5],CRC_DATA[6],CRC_DATA[7]};
 end
  2'b10:
 begin
      seed[31:24] = {CRC_DATA[0],CRC_DATA[1],CRC_DATA[2],CRC_DATA[3],CRC_DATA[4],CRC_DATA[5],CRC_DATA[6],CRC_DATA[7]};
      seed[23:16] = {CRC_DATA[8],CRC_DATA[9],CRC_DATA[10],CRC_DATA[11],CRC_DATA[12],CRC_DATA[13],CRC_DATA[14],CRC_DATA[15]};
      seed[15:8] = {CRC_DATA[16],CRC_DATA[17],CRC_DATA[18],CRC_DATA[19],CRC_DATA[20],CRC_DATA[21],CRC_DATA[22],CRC_DATA[23]};
      seed[7:0] = {CRC_DATA[24],CRC_DATA[25],CRC_DATA[26],CRC_DATA[27],CRC_DATA[28],CRC_DATA[29],CRC_DATA[30],CRC_DATA[31]};
 end
2'b11:
 begin
      seed[31:24] = {CRC_DATA[7],CRC_DATA[6],CRC_DATA[5],CRC_DATA[4],CRC_DATA[3],CRC_DATA[2],CRC_DATA[1],CRC_DATA[0]};
      seed[23:16] = {CRC_DATA[15],CRC_DATA[14],CRC_DATA[13],CRC_DATA[12],CRC_DATA[11],CRC_DATA[10],CRC_DATA[9],CRC_DATA[8]};
      seed[15:8] = {CRC_DATA[23],CRC_DATA[22],CRC_DATA[21],CRC_DATA[20],CRC_DATA[19],CRC_DATA[18],CRC_DATA[17],CRC_DATA[16]};
      seed[7:0] = {CRC_DATA[31],CRC_DATA[30],CRC_DATA[29],CRC_DATA[28],CRC_DATA[27],CRC_DATA[26],CRC_DATA[25],CRC_DATA[24]};
 end
 //default : ;
endcase

if (TCRC == 1 && m.rst == 0 && m.Sel == 1 && m.RW == 0) begin
checksum = checksum_tot;
case (TOTR)
  2'b00 :
      seed_32[31:0] = checksum[31:0];
  2'b01 :
 begin
      seed_32[31:24] = {checksum[24],checksum[25],checksum[26],checksum[27],checksum[28],checksum[29],checksum[30],checksum[31]};
      seed_32[23:16] = {checksum[16],checksum[17],checksum[18],checksum[19],checksum[20],checksum[21],checksum[22],checksum[23]};
      seed_32[15:8] = {checksum[8],checksum[9],checksum[10],checksum[11],checksum[12],checksum[13],checksum[14],checksum[15]};
      seed_32[7:0] = {checksum[0],checksum[1],checksum[2],checksum[3],checksum[4],checksum[5],checksum[6],checksum[7]};
 end
  2'b10:
 begin
      seed_32[31:24] = {checksum[0],checksum[1],checksum[2],checksum[3],checksum[4],checksum[5],checksum[6],checksum[7]};
      seed_32[23:16] = {checksum[8],checksum[9],checksum[10],checksum[11],checksum[12],checksum[13],checksum[14],checksum[15]};
      seed_32[15:8] = {checksum[16],checksum[17],checksum[18],checksum[19],checksum[20],checksum[21],checksum[22],checksum[23]};
      seed_32[7:0] = {checksum[24],checksum[25],checksum[26],checksum[27],checksum[28],checksum[29],checksum[30],checksum[31]};
 end
2'b11:
 begin
      seed_32[31:24] = {checksum[7],checksum[6],checksum[5],checksum[4],checksum[3],checksum[2],checksum[1],checksum[0]};
      seed_32[23:16] = {checksum[15],checksum[14],checksum[13],checksum[12],checksum[11],checksum[10],checksum[9],checksum[8]};
      seed_32[15:8] = {checksum[23],checksum[22],checksum[21],checksum[20],checksum[19],checksum[18],checksum[17],checksum[16]};
      seed_32[7:0] = {checksum[31],checksum[30],checksum[29],checksum[28],checksum[27],checksum[26],checksum[25],checksum[24]};
 end
//default : ;
endcase
end
else if (TCRC == 0 && m.rst == 0 && m.Sel == 1 && m.RW == 0) begin
checksum_16 = checksum_16_tot;
case (TOTR)
  2'b00 :
      seed_16[31:0] = checksum_16[31:0];
  2'b01 :
 begin
      seed_16[31:24] = {checksum_16[24],checksum_16[25],checksum_16[26],checksum_16[27],checksum_16[28],checksum_16[29],checksum_16[30],checksum_16[31]};
      seed_16[23:16] = {checksum_16[16],checksum_16[17],checksum_16[18],checksum_16[19],checksum_16[20],checksum_16[21],checksum_16[22],checksum_16[23]};
      seed_16[15:8] = {checksum_16[8],checksum_16[9],checksum_16[10],checksum_16[11],checksum_16[12],checksum_16[13],checksum_16[14],checksum_16[15]};
      seed_16[7:0] = {checksum_16[0],checksum_16[1],checksum_16[2],checksum_16[3],checksum_16[4],checksum_16[5],checksum_16[6],checksum_16[7]};
 end
  2'b10: begin
      seed_16[31:24] = {checksum_16[0],checksum_16[1],checksum_16[2],checksum_16[3],checksum_16[4],checksum_16[5],checksum_16[6],checksum_16[7]};
      seed_16[23:16] = {checksum_16[8],checksum_16[9],checksum_16[10],checksum_16[11],checksum_16[12],checksum_16[13],checksum_16[14],checksum_16[15]};
      seed_16[15:8] = {checksum_16[16],checksum_16[17],checksum_16[18],checksum_16[19],checksum_16[20],checksum_16[21],checksum_16[22],checksum_16[23]};
      seed_16[7:0] = {checksum_16[24],checksum_16[25],checksum_16[26],checksum_16[27],checksum_16[28],checksum_16[29],checksum_16[30],checksum_16[31]};
 end
2'b11: begin
      seed_16[31:24] = {checksum_16[7],checksum_16[6],checksum_16[5],checksum_16[4],checksum_16[3],checksum_16[2],checksum_16[1],checksum_16[0]};
      seed_16[23:16] = {checksum_16[15],checksum_16[14],checksum_16[13],checksum_16[12],checksum_16[11],checksum_16[10],checksum_16[9],checksum_16[8]};
      seed_16[15:8] = {checksum_16[23],checksum_16[22],checksum_16[21],checksum_16[20],checksum_16[19],checksum_16[18],checksum_16[17],checksum_16[16]};
      seed_16[7:0] = {checksum_16[31],checksum_16[30],checksum_16[29],checksum_16[28],checksum_16[27],checksum_16[26],checksum_16[25],checksum_16[24]};
 end
 //default : ;
endcase
end

    if (m.rst == 0 && m.Sel == 1 && m.RW == 0) begin
		if(FXOR == 0) begin
			if (TCRC == 1) begin
				checksum_tot = checksum_crc;
			end
			else if (TCRC == 0) begin
				checksum_16_tot = checksum_16_crc;
			end
   		end
   		else if (FXOR == 1) begin
		if (TCRC == 1) begin
				checksum_tot = checksum_crc ^ 32'hFFFF_FFFF;
			end
			else if (TCRC == 0) begin
				case (TOTR)
					2'b00 : checksum_16_tot = checksum_16_crc ^ 16'hFFFF;
					2'b01 : checksum_16_tot = checksum_16_crc ^ 16'hFFFF;
					2'b10 : checksum_16_tot = checksum_16_crc ^ 32'hFFFF_0000;
					2'b11 : checksum_16_tot = checksum_16_crc ^ 32'hFFFF_0000;
					//default : ;
				endcase
			end
   		end
   end
end
endmodule












