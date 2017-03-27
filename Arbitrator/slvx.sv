//
// A simple slave model for the arbitrator testing
//


module slvx(svif.slv q,input reg[3:0] id);

wire [31:0] saddr;
assign saddr=32'hFFEF_0200|(id<<12);
int ix;

always@(*) begin

   q.DataFromSlave= rdata[id][q.addr[5:4]];

end

always @(posedge(q.clk) or posedge(q.rst)) begin
  if(q.rst) begin
    for(ix=0; ix < 4; ix++) begin
      wdata[id][ix]=(id<<28);
      rdata[id][ix]=(id<<24);
    end
  end else begin
    if(q.sel) begin
      if( (q.addr&32'hFFEF_FF00) !== saddr) begin
        err($sformatf("Selected slave %d with bad address %08h",id,q.addr));
      end
      if(q.RW) begin
        if(q.DataToSlave !== wdata[id][q.addr[5:4]]) begin
          err($sformatf("Unexpected write data from address exp %08h got %08h",wdata[id][q.addr[5:4]],q.DataToSlave));
        end
        wdata[id][q.addr[5:4]] <= #1 wdata[id][q.addr[5:4]]+1;
      end else begin
        rdata[id][q.addr[5:4]] <= #1 rdata[id][q.addr[5:4]]+1;
      end
    end
  end
end



endmodule : slvx

