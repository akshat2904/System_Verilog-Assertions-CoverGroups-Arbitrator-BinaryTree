/*
    This is the interface to the NoC
*/

interface nocif(input logic clk,input 
logic rst);
  logic CmdW;       // bus to the device NoC interface
  logic [7:0] DataW;
  logic CmdR;       // bus from the device NoC interface
  logic [7:0] DataR;

  clocking cb @(posedge(clk));

  endclocking

  modport md(input clk,input rst,input CmdW,input DataW,
    output CmdR, output DataR);

endinterface
