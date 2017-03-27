//
// The slave interface
// Connects to a master through the arbitrator
//

interface svif;
  logic clk;    // positive edge clock
  logic rst;
  logic sel;    // device selected
  logic RW;     // read = 0, write = 1
  logic [31:0] addr;            // address to slave
  logic [31:0] DataToSlave;     // data into the slave
  logic [31:0] DataFromSlave;   // data from the slave
  
  modport slv ( input clk, input rst, input sel, input RW, 
                input addr, input DataToSlave, output DataFromSlave);
                
  modport slvR(input clk, input rst, output sel, output RW,
                output addr, output DataToSlave, input DataFromSlave);
  
endinterface : svif
