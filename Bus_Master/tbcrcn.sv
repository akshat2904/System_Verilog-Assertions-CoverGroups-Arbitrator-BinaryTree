//
// A test bench for the CRC module
//
`timescale 1ns/10ps

`include "crcif.sv"
`include "nocif.sv"

package crc_pkg;

`include "uvm.sv"

import uvm_pkg::*;

`include "ucrcn.svrp"

endpackage : crc_pkg

import uvm_pkg::*;
import crc_pkg::*;

`include "crc.sv"
`include "noc.sv"

module top();

reg debug=0;

crc_if cif();
nocif nif(cif.clk,cif.rst);

noc n(nif.md,cif.dn);

crc c(cif.dp);

initial begin
  cif.clk=1;
  forever #5 cif.clk=~cif.clk;
end

initial begin
  cif.rst=0;
  cif.Sel=0;
  nif.CmdW=1;
  nif.DataW=7;
  repeat(500000) @(posedge(cif.clk)) #1;
  $display("Safety timer expired");
  $finish;
end

initial
  begin
    #0;
    uvm_config_db #(virtual crc_if)::set(null, "uvm_test_top", "crc_if" , cif);
    uvm_config_db #(virtual nocif)::set(null, "uvm_test_top", "noc_if" , nif);
    $display("About to run crc_test");
    run_test("crc_test");
    #100;
    $display("\n\n\nOh what happiness, you passed the test\n\n\n");
    repeat(10) @(posedge(cif.clk)) #1;
    $finish;
  end

initial begin
  if(debug) begin
    $dumpfile("crc.vpd");
    $dumpvars(9,top);
  end
end
  
endmodule : top
