module arb (bmif.mstrR m0, bmif.mstrR m1, bmif.mstrR m2, bmif.mstrR m3, svif.slvR s0, svif.slvR s1, svif.slvR s2, svif.slvR s3, input integer amt, input integer max_clk, input integer max_amt);

    logic [3:0] m0_req_reg,m1_req_reg,m2_req_reg,m3_req_reg;
    integer m0_bid,m1_bid,m2_bid,m3_bid;
    integer counter;
    
    always @(posedge m0.clk or posedge m0.rst) begin
            if (m0.rst || m1.rst|| m2.rst|| m3.rst) begin
                counter = 0;
                m0_bid = amt; m1_bid = amt; m2_bid = amt; m3_bid = amt;
                m0_req_reg = m0.req; m1_req_reg = m1.req; m2_req_reg = m2.req; m3_req_reg = m3.req;
            end
            else begin
                counter = counter + 1;
                if (counter == max_clk) begin 
                    m0_req_reg = m0.req; m1_req_reg = m1.req; m2_req_reg = m2.req; m3_req_reg = m3.req; 
                    counter = 0; 
                    if(m0_bid >= 150) m0_bid = max_amt; else m0_bid = amt + m0_bid;
                    if(m1_bid >= 150) m1_bid = max_amt; else m1_bid = amt + m1_bid;
                    if(m2_bid >= 150) m2_bid = max_amt; else m2_bid = amt + m2_bid;
                    if(m3_bid >= 150) m3_bid = max_amt; else m3_bid = amt + m3_bid;
                end
                    if (m0.grant == 1) m0_bid = m0_bid - m0_req_reg;
                    if (m1.grant == 1) m1_bid = m1_bid - m1_req_reg;
                    if (m2.grant == 1) m2_bid = m2_bid - m2_req_reg;
                    if (m3.grant == 1) m3_bid = m3_bid - m3_req_reg;
            end
    end
    
    always @(*) begin
    
        m0_req_reg = m0.req; m1_req_reg = m1.req; m2_req_reg = m2.req; m3_req_reg = m3.req;
                
        if (m0_bid < m0_req_reg) begin m0_bid = 1; m0_req_reg = 1; end
        else if (m1_bid < m1_req_reg) begin m1_bid = 1; m1_req_reg = 1; end
        else if (m2_bid < m2_req_reg) begin m2_bid = 1; m2_req_reg = 1; end
        else if (m3_bid < m3_req_reg) begin m3_bid = 1; m3_req_reg = 1; end
        
        if ((m0_req_reg > m1_req_reg) && (m0_req_reg > m2_req_reg) && (m0_req_reg > m3_req_reg)) begin 
            if (m0_req_reg > m2_req_reg) begin 
                if (m0_req_reg > m3_req_reg) begin
                    m0.grant = 1'b1; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant= 1'b0; 
                end
            end
        end
        else if ((m1_req_reg > m0_req_reg) && (m1_req_reg > m2_req_reg) && (m1_req_reg > m3_req_reg)) begin
            if (m1_req_reg > m2_req_reg) begin 
                if (m1_req_reg > m3_req_reg) begin
                    m0.grant = 1'b0; m1.grant = 1'b1; m2.grant = 1'b0; m3.grant= 1'b0; 
                end
            end
        end
        else if ((m2_req_reg > m0_req_reg) && (m2_req_reg > m1_req_reg) && (m2_req_reg > m3_req_reg)) begin 
            if (m2_req_reg > m1_req_reg) begin
                if (m2_req_reg > m3_req_reg) begin
                    m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b1; m3.grant= 1'b0; 
                end
            end
        end
        else if ((m3_req_reg > m0_req_reg) && (m3_req_reg > m1_req_reg) && (m3_req_reg > m2_req_reg)) begin 
            if (m3_req_reg > m1_req_reg) begin 
                if (m3_req_reg > m2_req_reg) begin
                    m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant= 1'b1; 
                end
            end
        end        
        else begin 
                if (m0_bid == 1) begin
                    if ((m1_req_reg == m2_req_reg) && (m2_req_reg == m3_req_reg)) begin 
                        if (m2_req_reg == m3_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant = 1'b1; 
                        end
                    end
                    if ((m1_req_reg == m2_req_reg) && (m2_req_reg > m3_req_reg)) begin 
                        if (m2_req_reg > m3_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b1; m3.grant= 1'b0; 
                        end
                    end
                    if ((m2_req_reg == m3_req_reg) && (m2_req_reg > m1_req_reg)) begin 
                        if (m2_req_reg > m1_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant= 1'b1; 
                        end
                    end
                    if ((m1_req_reg == m3_req_reg) && (m3_req_reg > m2_req_reg)) begin 
                        if (m3_req_reg > m2_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant= 1'b1; 
                        end
                    end
                    if ((m1_req_reg == m2_req_reg) && (m2_req_reg < m3_req_reg)) begin 
                        if (m2_req_reg < m3_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b0; m3.grant= 1'b1; 
                        end
                    end
                    if ((m2_req_reg == m3_req_reg) && (m2_req_reg < m1_req_reg)) begin 
                        if (m2_req_reg < m1_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b1; m2.grant = 1'b0; m3.grant= 1'b0; 
                        end
                    end
                    if ((m1_req_reg == m3_req_reg) && (m3_req_reg < m2_req_reg)) begin 
                        if (m3_req_reg < m2_req_reg) begin
                            m0.grant = 1'b0; m1.grant = 1'b0; m2.grant = 1'b1; m3.grant= 1'b0; 
                        end
                    end
            end
        end
		
        if (m3.grant == 1) begin
            if (m3.addr == 32'hFFEF_0230) begin
                s0.RW = m3.RW; s0.sel = 1'b1; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b0;
                s0.addr = m3.addr;
                s0.DataToSlave = m3.DataToSlave;
                m3.DataFromSlave = s0.DataFromSlave;
            end
            else if (m3.addr == 32'hFFEF_1230) begin
                s1.RW = m3.RW; s0.sel = 1'b0; s1.sel = 1'b1; s2.sel = 1'b0; s3.sel = 1'b0;
                s1.addr = m3.addr;
                s1.DataToSlave = m3.DataToSlave;
                m3.DataFromSlave = s1.DataFromSlave;
            end
            else if (m3.addr == 32'hFFEF_2230) begin
                s2.RW = m3.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b1; s3.sel = 1'b0;
                s2.addr = m3.addr;
                s2.DataToSlave = m3.DataToSlave;
                m3.DataFromSlave = s2.DataFromSlave;
            end
            else if(m3.addr == 32'hFFEF_3230) begin
                s3.RW = m3.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b1;
                s3.addr = m3.addr;
                s3.DataToSlave = m3.DataToSlave;
                m3.DataFromSlave = s3.DataFromSlave;
            end
        end
        else if (m2.grant == 1) begin
            if (m2.addr == 32'hFFEF_0220) begin
                s0.RW = m2.RW; s0.sel = 1'b1; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b0;
                s0.addr = m2.addr;
                s0.DataToSlave = m2.DataToSlave;
                m2.DataFromSlave = s0.DataFromSlave;
            end
            else if (m2.addr == 32'hFFEF_1220) begin
                s1.RW = m2.RW; s0.sel = 1'b0; s1.sel = 1'b1; s2.sel = 1'b0; s3.sel = 1'b0;
                s1.addr = m2.addr;
                s1.DataToSlave = m2.DataToSlave;
                m2.DataFromSlave = s1.DataFromSlave;
            end
            else if (m2.addr == 32'hFFEF_2220) begin
                s2.RW = m2.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b1; s3.sel = 1'b0;
                s2.addr = m2.addr;
                s2.DataToSlave = m2.DataToSlave;
                m2.DataFromSlave = s2.DataFromSlave;
                end
            else if(m2.addr == 32'hFFEF_3220) begin
                s3.RW = m2.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b1;
                s3.addr = m2.addr;
                s3.DataToSlave = m2.DataToSlave;
                m2.DataFromSlave = s3.DataFromSlave;
            end
        end
        else if (m1.grant == 1) begin
            if (m1.addr == 32'hFFEF_0210) begin
                s0.RW = m1.RW; s0.sel = 1'b1; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b0;
                s0.addr = m1.addr;
                s0.DataToSlave = m1.DataToSlave;
                m1.DataFromSlave = s0.DataFromSlave;
            end
            else if (m1.addr == 32'hFFEF_1210) begin
                s1.RW = m1.RW; s0.sel = 1'b0; s1.sel = 1'b1; s2.sel = 1'b0; s3.sel = 1'b0;
                s1.addr = m1.addr;
                s1.DataToSlave = m1.DataToSlave;
                m1.DataFromSlave = s1.DataFromSlave;
            end
            else if (m1.addr == 32'hFFEF_2210) begin
                s2.RW = m1.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b1; s3.sel = 1'b0;;
                s2.addr = m1.addr;
                s2.DataToSlave = m1.DataToSlave;
                m1.DataFromSlave = s2.DataFromSlave;
            end
            else if (m1.addr == 32'hFFEF_3210) begin
                s3.RW = m1.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b1;
                s3.addr = m1.addr;
                s3.DataToSlave = m1.DataToSlave;
                m1.DataFromSlave = s3.DataFromSlave;
            end
        end
        else if (m0.grant == 1) begin
            if (m0.addr == 32'hFFEF_0200) begin
                s0.RW = m0.RW; s0.sel = 1'b1; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b0;
                s0.addr = m0.addr;
                s0.DataToSlave = m0.DataToSlave;
                m0.DataFromSlave = s0.DataFromSlave;
            end
            else if (m0.addr == 32'hFFEF_1200) begin
                s1.RW = m0.RW; s0.sel = 1'b0; s1.sel = 1'b1; s2.sel = 1'b0; s3.sel = 1'b0;
                s1.addr = m0.addr;
                s1.DataToSlave = m0.DataToSlave;
                m0.DataFromSlave = s1.DataFromSlave;
            end
            else if (m0.addr == 32'hFFEF_2200) begin
                s2.RW = m0.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b1; s3.sel = 1'b0;
                s2.addr = m0.addr;
                s2.DataToSlave = m0.DataToSlave;
                m0.DataFromSlave = s2.DataFromSlave;
            end
            else if(m0.addr == 32'hFFEF_3200) begin
                s3.RW = m0.RW; s0.sel = 1'b0; s1.sel = 1'b0; s2.sel = 1'b0; s3.sel = 1'b1;
                s3.addr = m0.addr;
                s3.DataToSlave = m0.DataToSlave;
                m0.DataFromSlave = s3.DataFromSlave;
            end 
        end
    end
endmodule

