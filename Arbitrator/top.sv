//
// A simplt top level test bench
//
// It contains 4 masters and 4 slaves

// The slaves are addressed as:
// FFEF_S200-FFEF_S2FF
//  where S indicates the slave 0-3
//
reg bad=0;
task err(string msg); 
   $display("At time %t ns",$realtime);
   $display(msg);
   bad=1;
   #10;
   $finish;
endtask : err

reg [31:0] rdata[0:3][0:3];
reg [31:0] wdata[0:3][0:3];
reg [31:0] mrdata[0:3][0:3];
reg [31:0] mwdata[0:3][0:3];

reg [31:0] rw[0:3];
reg [31:0] ww[0:3];


`include "bmif.sv"
`include "svif.sv"
`include "bmx.sv"
`include "slvx.sv"
`include "arb.sv"







module top;
logic clk,rst;

bmif bm0();
bmif bm1();
bmif bm2();
bmif bm3();

svif sv0();
svif sv1();
svif sv2();
svif sv3();
int ix,sv;


initial begin
  clk=1;
  repeat(200000) begin
    #5 clk=~clk;
    bm0.clk=clk;
    bm1.clk=clk;
    bm2.clk=clk;
    bm3.clk=clk;
    sv0.clk=clk;
    sv1.clk=clk;
    sv2.clk=clk;
    sv3.clk=clk;
  end
  for(ix=0; ix < 4; ix++) begin
    for(sv=0; sv < 4; sv++) begin
      $display(" For master %d to slave %d reads %d writes %d",ix,sv,
        mrdata[sv][ix][19:0],mwdata[sv][ix][19:0]);
    end
  end
end

initial begin
  rst=1;
  bm0.rst=rst;
  bm1.rst=rst;
  bm2.rst=rst;
  bm3.rst=rst;
  sv0.rst=rst;
  sv1.rst=rst;
  sv2.rst=rst;
  sv3.rst=rst;
  repeat(3) @(posedge(clk)) #2;
  rst=0;
  bm0.rst=rst;
  bm1.rst=rst;
  bm2.rst=rst;
  bm3.rst=rst;
  sv0.rst=rst;
  sv1.rst=rst;
  sv2.rst=rst;
  sv3.rst=rst;
end

bmx m0(bm0.mstr,4'h0);
bmx m1(bm1.mstr,4'h1);
bmx m2(bm2.mstr,4'h2);
bmx m3(bm3.mstr,4'h3);


slvx s0(sv0.slv,4'h0);
slvx s1(sv1.slv,4'h1);
slvx s2(sv2.slv,4'h2);
slvx s3(sv3.slv,4'h3);

arb a(bm0.mstrR,bm1.mstrR,bm2.mstrR,bm3.mstrR,
    sv0.slvR,sv1.slvR,sv2.slvR,sv3.slvR,750,400,900);

initial begin
  $dumpfile("arb.vpd");
  $dumpvars(0,top);
end

endmodule : top
