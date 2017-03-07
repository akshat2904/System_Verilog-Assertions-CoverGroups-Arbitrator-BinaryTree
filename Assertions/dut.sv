`timescale 1ns/10ps
// prints out the state values
//
module dut(intf.idut ix);

default clocking @(posedge(ix.clk));

endclocking

always @(posedge(ix.clk)) begin
  $display(ix.state);
end
   
   STATE_0 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 0) |=> ix.state == 1) 
                else $display("Assert_state : The next state after State 0 is State 1 only");
   
   STATE_1 :  assert property (@(posedge ix.clk) (~ix.rst && ix.state == 1) |=> ix.state inside {2,4}) 
                else $display("Assert_state : The next states after State 1 are States 2 & 4 only");
   
   STATE_2 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 2) |=> ix.state == 3)
                else $display("Assert_state : The next state after State 2 is State 3 only");
   
   STATE_3 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 3) |=> ix.state inside {5,1}) 
                else $display("Assert_state : The next states after State 3 are States 1 & 5 only");
   
   STATE_4 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 4) |=> ix.state == 5) 
                else $display("Assert_state : The next state after State 4 is State 5 only");
   
   STATE_5 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 5) |=> ix.state inside {1,6}) 
                else $display("Assert_state : The next states after State 5 are States 1 & 6 only");
   
   STATE_6 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 6) |=> ix.state == 7) 
                else $display("Assert_state : The next state after State 6 is State 7 only");
   
   STATE_7 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 7) |=> ix.state inside {0,8}) 
                else $display("Assert_state : The next states after State 7 are States 0 & 8 only");
   
   STATE_8 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 8) |=> ix.state inside {2,4,14,9}) 
                else $display("Assert_state : The next states after State 8 are States 2,4,9 & 10 only");
   
   STATE_9 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 9) |=> ix.state == 0) 
               else $display("Assert_state : The next state after State 9 is State 0 only");
   
   STATE_14 : assert property (@(posedge ix.clk) (~ix.rst && ix.state == 14) |=> ix.state == 0) 
              else $display("Assert_state : The next state after State 14 is State 0 only");
   
   STATE_DEFAULT : assert property (@(posedge ix.clk) (~ix.rst && ix.state > 9 && ix.state != 14) /*inside {10,11,12,13,15})*/ |=> ix.state == 4) 
               else $display("Assert_state : The default state for States other than 0 to 9 & 14 is State 4");
endmodule