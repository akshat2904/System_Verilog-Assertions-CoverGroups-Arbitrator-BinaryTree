//
// This is an interface for the simple CRC Block
//

interface crc_if();
logic    clk,rst;       // the reset signal
logic [31:0] addr;      // The device address
logic [31:0] data_wr;   // The write data
logic        RW;        // read = 0 write = 1
logic        Sel;       // The device is selected
logic [31:0] data_rd;   // the read data

clocking cb @(posedge(clk));
  input addr,data_wr,RW,Sel;
  output data_rd;
endclocking : cb

modport dp(input clk, input rst, input addr, input RW, input Sel,
    input data_wr, output data_rd);
    
modport dn(output addr, output RW, output Sel, output data_wr,
    input data_rd);

endinterface : crc_if
