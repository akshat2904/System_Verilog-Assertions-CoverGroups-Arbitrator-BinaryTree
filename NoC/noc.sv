`timescale 1ns/10ps
module noc ();
logic [2:0] AddrLen;
logic [7:0] read_code;
logic [7:0] read_resp;
logic [7:0] write_code;
logic [7:0] write_resp;
logic [7:0] msg_code;
logic [7:0] end_code;
logic [8:0] packet_data;
logic [7:0] SourceID_R;
logic [7:0] SourceID_W;
byte Byte_R;
byte Byte_W;

`include "crc.sv"

always @ (posedge m.rst or posedge m.clk) begin
        case(packet_data)
         9'b1000xxxxx : ;                                               //idle state
         9'b1001xxxxx :  if(m.cmdR == 1) begin                          //Read Data 
                            case(m.DataR[2:0])
                                3'b000 : size.m.DataR[2:0] = Byte_R; 
                                3'b001 : size.m.DataR[2:0] = 2*Byte_R; 
                                3'b010 : size.m.DataR[2:0] = 3*Byte_R; 
                                3'b011 : size.m.DataR[2:0] = 4*Byte_R; 
                                3'b100 : size.m.DataR[2:0] = 5*Byte_R; 
                                3'b101 : size.m.DataR[2:0] = 7*Byte_R; 
                                3'b110 : size.m.DataR[2:0] = 8*Byte_R; 
                                3'b111 : size.m.DataR[2:0] = 12*Byte_R; 
                                default : ;
                            endcase 
                        end
         9'b1010xxxxx : read_resp = m.DataR;                            //Read Response
         9'b1011xxxxx : if (m.cmdW == 1) begin                          //Write
                            case(m.DataW[2:0])
                                3'b000 : size.m.DataW[2:0] = Byte_W; 
                                3'b001 : size.m.DataW[2:0] = 2*Byte_W; 
                                3'b010 : size.m.DataW[2:0] = 3*Byte_W; 
                                3'b011 : size.m.DataW[2:0] = 4*Byte_W; 
                                3'b100 : size.m.DataW[2:0] = 5*Byte_W; 
                                3'b101 : size.m.DataW[2:0] = 7*Byte_W; 
                                3'b110 : size.m.DataW[2:0] = 8*Byte_W; 
                                3'b111 : size.m.DataW[2:0] = 12*Byte_W; 
                                default : ;
                            endcase
                       end
         9'b1100xxxxx : write_resp = m.DataW;                           // Write Response
         9'b1101xxxxx : reserved;                                       // Reserved
         9'b1110xxxxx : msg;                                            // Message
         9'b1111xxxxx : end_code                                        //End
    default : ;
    endcase
    end
endmodule
