`timescale 1ns/10ps
// prints out the state values

module dut(intf.idut ix);

default clocking @(posedge(ix.clk));

endclocking

always @(posedge(ix.clk)) begin
  $display(ix.state);
end
  
  covergroup cov_g();
    coverpoint ix.state iff (!ix.rst)
        {   bins state_0_1   = (0 => 1);
            bins state_1_2_4 = (1 => 2,4);
            bins state_2_3   = (2 => 3);
            bins state_3_5_1 = (3 => 5, 1);
            bins state_4_5   = (4 => 5);
            bins state_5_1_6 = (5 => 1, 6);
            bins state_6_7   = (6 => 7);
            bins state_7_0_8 = (7 => 0, 8);
            bins state_8_2_4_14_9 = (8 => 2, 4, 14, 9);
            bins state_9_8   = (9 => 8);
            bins state_14_0  = (14 => 0);
        }
  endgroup
       
  cov_g cg_int = new();
    
  initial begin
    @ix.state cg_int.sample();
  end

endmodule