//
// A test bench for the CRC module
//
`timescale 1ns/10ps

`include "crcif.sv"

package crc_pkg;

`include "uvm.sv"

import uvm_pkg::*;

`include "ucrc.svrp"

endpackage : crc_pkg

import uvm_pkg::*;
import crc_pkg::*;

`include "crc.sv"

module top();

reg debug=1;

crc_if cif();

crc c(cif.dp);

initial begin
  cif.clk=1;
  forever #5 cif.clk=~cif.clk;
end

initial begin
  cif.rst=0;
  cif.Sel=0;
  repeat(5000000) @(posedge(cif.clk)) #1;
  $display("Safety timer expired");
  $finish;
end

initial
  begin
    #0;
    uvm_config_db #(virtual crc_if)::set(null, "uvm_test_top", "crc_if" , cif);
    run_test("crc_test");
    #100;
    $display("\n\n\nOh what happiness, you passed the test\n\n\n");
    $finish;
  end

initial begin
  if(debug) begin
    $dumpfile("crc.vpd");
    $dumpvars(9,top);
  end
end
  
endmodule : top
