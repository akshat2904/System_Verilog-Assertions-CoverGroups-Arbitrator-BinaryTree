//
// This is a simple bus master item...
//

module bmx(bmif.mstr q,input reg[3:0] id);

int ix;
typedef enum reg [2:0] { Sidle,Swait,Sarb} State;

State cs,nexts;
reg rw;
reg [3:0] reqamt,ts;
int waitc,waitc_d;
reg [1:0] tslave;
reg [2:0] st;
int timer,timer_d;
int tval=60;


always @(*) begin
  nexts = cs;
  st = cs;
  q.req=0;
  q.xfr=0;
  q.RW=0;
  q.addr=0;
  q.DataToSlave=0;
  case(cs) 
    Sidle: begin
      rw = $urandom_range(0,1);
      ts = $urandom_range(0,3);
      timer_d = tval;
      case(id)
        0: begin
          nexts = Sarb;
          waitc_d=0;
          reqamt=15;
        end
        1: begin
          waitc_d = $urandom_range(0,6);
          reqamt = $urandom_range(1,5);
          nexts = Swait;
          if(waitc_d == 0) begin
            nexts = Swait;
            reqamt = $urandom_range(1,5);
          end
        end
        2: begin
          waitc_d = $urandom_range(5,20);
          nexts = Swait;
          reqamt = $urandom_range(1,15);
        end
        3: begin
          waitc_d = $urandom_range(1,3);
          nexts = Swait;
          reqamt = $urandom_range(6,15);
        end
      endcase
    end
    Swait: begin
      if(waitc<=0) nexts=Sarb;
      waitc_d=waitc-1;
    end
    Sarb: begin
      q.req=reqamt;
      q.xfr = 1;
      q.RW = rw;
      q.addr = 32'hFFEF_0200|(ts<<12)|(id<<4);  
      if ( rw ) begin
        q.DataToSlave = mwdata[ts][id];
      end else begin
        q.DataToSlave = $random(); 
      end
    
      if( q.grant ) begin
        if(id==0) begin
          nexts = Sarb;
          rw = $urandom_range(0,1);
          timer_d=tval;
        end else begin
          nexts = Sidle;
        end
      end else begin
        if(timer<= 0) begin
          err($sformatf("Master %d waited for %d clocks and no grant",id,tval));
        end
        timer_d=timer-1;
      end
    end
  endcase

end

always @(posedge(q.clk) or posedge(q.rst)) begin
  if(q.rst) begin
    for(ix=0; ix < 4; ix++) begin
      mrdata[ix][id]=(ix<<24);
      mwdata[ix][id]=(ix<<28);
      cs <= Sidle;
      waitc <= 1;
      timer <= 0;
    end  
  end else begin
    cs <= #1 nexts;
    waitc <= #1 waitc_d;
    timer <= #1 timer_d;
    if( q.grant ) begin
        if( q.RW ) begin
          mwdata[ts][id]<= #1 mwdata[ts][id] + 1;
        end else begin
          if( mrdata[ts][id] !== q.DataFromSlave) begin
            err($sformatf("Read error master %d exp %08h got %08h",
                id,mrdata[ts][id],q.DataFromSlave));
          end
          mrdata[ts][id]+=1;
          if(id==0) ts=$urandom_range(0,3);
        end
    end
  end
end




endmodule : bmx
