//
// The interface for a bus master
//

interface bmif;
  logic clk;
  logic rst;
  logic [3:0] req;  // 0 == no request, others are request bid
  logic grant;      // This device has received a grant
  logic xfr;        // An active bus cycle
  logic RW ;        // 0=read, 1=write
  logic [31:0] addr;            // request address
  logic [31:0] DataToSlave;     // Data to a slave
  logic [31:0] DataFromSlave;   // Data from slave to master
  
  modport mstr(input clk, input rst, output req, input grant, output xfr,
            output RW, output addr, output DataToSlave, input DataFromSlave);
            
  modport mstrR(input clk, input rst, input req, output grant, input xfr,
            input RW, input addr, input DataToSlave, output DataFromSlave);






endinterface : bmif
