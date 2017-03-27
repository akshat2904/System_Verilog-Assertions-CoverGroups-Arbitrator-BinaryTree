`timescale 1ns/10ps
module noc (nocif n, crc_if c);
    logic [7:0] source_id_w, return_id, read_len, readlen_1;
    logic [7:0] addr0, addr1, addr2;
    logic [7:0] data_w0, data_w1, data_w2, addr_w0, addr_w1, addr_w2;
    logic [31:0] addrs, addrs_r, addrs_r1, data_read_1, data_read_2;
    logic [119:0] reg_data1, Data_Read_Resp;
    logic fifo_full, fifo_empty, Status_08, Status_0C;
    logic  write_en, read_en;
    
    /////////////////Bus MAster Variables//////////////////////
    logic  write_en_bm, read_en_bm;
    logic fifo_full_bm, fifo_empty_bm;
    logic [7:0] source_id_bm, Length_bm, Test_bm;
    //logic [47:0] data_bm_reg_pack, data_from_fifo_bm;
    logic [7:0] data_bm_reg_0, data_bm_reg_1, data_bm_reg_2, data_bm_reg_3, data_bm_reg_0_F4, data_bm_reg_1_F4, data_bm_reg_2_F4, data_bm_reg_3_F4;
    logic [31:0] data_bm_reg, data_bm_reg_F4;
    logic [4:0] counter;
    
    typedef enum logic [4:0] {READ_BM, TEST_DATA_BM, LEN_BM, DATA_BM_F0, DATA_BM_F4} bm_st;
    bm_st bm_state;
    
    typedef enum logic [4:0] {data_bm_0_F0, data_bm_1_F0, data_bm_2_F0, data_bm_3_F0, data_bm_4_F0} data_st_F0;
    data_st_F0 data_bm_st_F0;
    
    typedef enum logic [4:0] {data_bm_0_F4, data_bm_1_F4, data_bm_2_F4, data_bm_3_F4, data_bm_4_F4} data_st_F4;
    data_st_F4 data_bm_st_F4;
    
    /*typedef enum logic [2:0] {IDLE_RESP_BM, READ_RESP_BM, WRITE_RESP_BM} bm_resp_st;
    bm_resp_st bm_resp; */
    
    typedef enum logic [5:0] {state_0_bm, state_1_bm, state_2_bm, state_3_bm, state_4_bm, state_5_bm} state_bm;
    state_bm data_read_bm;
    
    typedef enum logic [5:0] {state_w0_bm, state_w1_bm, state_w2_bm, state_w3_bm, state_w4_bm, state_w5_bm} state_w_bm;
    state_w_bm data_write_bm;
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    typedef enum logic[3:0] {IDLE, READ, WRITE, BM_START} w_st;
    w_st w_state;
    
    typedef enum logic[3:0] {IDLE_RESP, READ_RESP, WRITE_RESP, END_CODE} rsp_state;
    rsp_state resp_state;
    
    typedef enum logic[1:0] {Status_0, Status_1} st_chk;
    st_chk Status_Check;
    
    typedef enum logic[5:0] {read_0, read_1, read_2, read_3, read_4, read_5} read_st;
    read_st read_state;
    
    typedef enum logic[9:0] {write_0, write_1, write_2, write_3, write_4, write_5, write_6, write_7, write_8, write_9} write_st;
    write_st write_state;
    
    typedef enum logic[14:0] {state_0, state_1, state_2, state_3, state_4, state_5, state_6, state_7, state_8, state_9, state_10, state_11, state_12, state_13, state_14} d_read;
    d_read data_read;
    
    typedef enum logic[3:0] {state_w_0, state_w_1, state_w_2, state_w_3} data_write_resp;
    data_write_resp data_write;
    
    fifo f1 (n.clk, n.rst, write_en, read_en, reg_data1, fifo_full, fifo_empty, Data_Read_Resp);
    
    /*fifo_bm f2 (n.clk, n.rst, write_en_bm, read_en_bm, data_bm_reg_pack, fifo_full_bm, fifo_empty_bm, data_from_fifo_bm);*/
    
    
always @ (posedge n.clk or posedge n.rst) begin
    if (n.rst == 1'b1) begin
            addr0 <= 8'b0000_0000; addr1 <= 8'b0000_0000; addr2 <= 8'b0000_0000;
            
            data_w0 <= 8'b0000_0000; data_w1 <= 8'b0000_0000; data_w2 <= 8'b0000_0000;
            
            addr_w0 <= 8'b0000_0000; addr_w1 <= 8'b0000_0000; addr_w2 <= 8'b0000_0000;
            
            read_len <= 8'b0000_0000; readlen_1 <= 8'b0000_0000;
            
            source_id_w <= 8'b0000_0000; return_id <= 8'b0000_0000;
            
            n.CmdR <= 1'b1; n.DataR <= 32'h0000_0000;
            
            addrs <= 32'h0000_0000; addrs_r <= 32'h0000_0000; addrs_r1 <= 32'h0000_0000;
            
            data_read_1 <= 32'h0000_0000; data_read_2 <= 32'h0000_0000;
            
            w_state <= IDLE; resp_state <= IDLE_RESP; read_state <= read_0; write_state <= write_0; data_read <= state_0; data_write <= state_w_0;
            
            c.Sel <= 1'b0; c.RW <= 1'b0;
            
            reg_data1 <= 0;
            
            read_en <= 1'b0; write_en <= 1'b0;
            
            Status_Check <= Status_0; Status_0C <= 1'b0; Status_08 <= 1'b0;
            
      ///////////////////////////////////////BM Signal initialization///////////////////      
            write_en_bm <= 1'b0; read_en_bm <= 1'b0;
            
            //data_bm <= data_bm_0;
            bm_state <= READ_BM;
            
            data_bm_reg_0 <= 8'h00; data_bm_reg_1 <= 8'h00; data_bm_reg_2 <= 8'h00; data_bm_reg_3 <= 8'h00;
            
            data_read_bm <= state_0_bm; data_write_bm <= state_w0_bm; //bm_resp <= IDLE_RESP_BM;
            
            data_bm_st_F0 <= data_bm_0_F0; data_bm_st_F4 <= data_bm_0_F4;
            counter <=0;
    end
    else if (n.rst == 1'b0) begin
           if (fifo_empty != 1'b1) begin
                read_en <= 1'b1;
           end
           
          /* if (fifo_empty_bm != 1'b1) begin
                read_en_bm <= 1'b1;
           end */
           
//            if(END_CODE_FLAG <= 1'b1)
//                 bm_state <= IDLE_BM;
            
            case (w_state)
            IDLE : begin
                        c.Sel <= 1'b0; c.RW <= 1'b0; write_en <= 1'b0;
                        if(n.DataW == 8'h23 && n.CmdW == 1'b1) begin
                            w_state <= READ;
                            read_state <= read_0;
                        end
                        else if (n.DataW == 8'h63 && n.CmdW == 1'b1) begin
                            w_state <= WRITE;
                            write_state <= write_0;
                        end
                        else if (n.DataW == 8'h68 && n.CmdW == 1'b1) begin
                            n.CmdR <= 1'b1;
                            w_state <= BM_START;
                            bm_state <= READ_BM;
                        end
                   end
            READ : begin
                        case (read_state)
                        read_0 : begin
                                    source_id_w <= n.DataW;
                                    c.Sel <= 0; c.RW <= 0;
                                    read_state <= read_1;
                                 end
                        read_1 : begin
                                    addr0 <= n.DataW;
                                    c.Sel <= 0; c.RW <= 0;
                                    read_state <= read_2;
                                    end
                        read_2 : begin
                                    addr1 <= n.DataW;
                                    c.Sel <= 0; c.RW <= 0;
                                    read_state <= read_3;
                                 end
                        read_3 : begin
                                    addr2 <= n.DataW;
                                    c.Sel <= 0; c.RW <= 0;
                                    read_state <= read_4;
                                 end
                        read_4 : begin
                                    c.Sel   <= 1; c.RW <= 0;
                                    c.addr  <= {n.DataW, addr2, addr1, addr0};
                                    addrs_r <= {n.DataW, addr2, addr1, addr0};
                                    read_state <= read_5;
                                 end
                       
                       read_5 : begin // For data_read_1 = FFFF_FFFF
                                 read_len <= n.DataW;
                                 if(n.DataW == 8'h04) begin
                                        c.Sel <= 0; c.RW <= 0;
                                        data_read_1 <= c.data_rd;
                                        reg_data1 <= {8'h40, source_id_w, n.DataW, c.data_rd, 64'h0000_0000_0000_0000};
                                        write_en <= 1'b1;
                                        read_state <= read_0;
                                        w_state <= IDLE;
                                 end
                                 else if (n.DataW == 8'h08) begin
                                        c.Sel <= 1; c.RW <= 0;
                                        c.addr <= addrs_r + 32'h0000_0004;
                                        data_read_1 <= c.data_rd;
                                        Status_08 <= 1'b1;
                                        read_state <= read_0;
                                        w_state <= IDLE;
                                 end
                                 else if (n.DataW == 8'h0C) begin
                                        c.Sel <= 1; c.RW <= 0;
                                        Status_0C <= 1'b1;
                                        c.addr <= addrs_r + 32'h0000_0004;
                                        addrs_r1 <= addrs_r + 32'h0000_0004;
                                        data_read_1 <= c.data_rd;
                                        read_state <= read_0;
                                        w_state <= IDLE;
                                end
                                end
                        endcase
                        end      
           
           WRITE : begin
                        case (write_state)
                        write_0 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    source_id_w <= n.DataW;
                                    write_state <= write_1;
                                  end
                        write_1 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    addr_w0 <= n.DataW;
                                    write_state <= write_2;
                                  end
                        write_2 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    addr_w1 <= n.DataW;
                                    write_state <= write_3;
                                  end
                        write_3 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    addr_w2 <= n.DataW;
                                    write_state <= write_4;
                                  end
                        write_4 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    addrs <= {n.DataW, addr_w2, addr_w1, addr_w0};
                                    write_state <= write_5;
                                  end
                                 
                        write_5 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    write_state <= write_6;
                                  end
                                 
                        write_6 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    data_w0 <= n.DataW;
                                    write_state <= write_7;
                                  end
                        write_7 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    data_w1 <= n.DataW;
                                    write_state <= write_8;
                                  end
                        write_8 : begin
                                    c.Sel <= 0; c.RW <= 0;
                                    data_w2 <= n.DataW;
                                    write_state <= write_9;
                                  end
                        write_9 : begin
                                    c.Sel <= 1; c.RW <= 1;
                                    c.data_wr <= {n.DataW, data_w2, data_w1, data_w0};
                                    c.addr <= addrs;
                                    reg_data1 <= {8'h80, source_id_w, 104'd0};
                                    write_en <= 1'b1;
                                    write_state <= write_0;
                                    w_state <= IDLE;
                                  end
                       endcase
                       end
            BM_START : begin
                                case(bm_state)
//                                 IDLE_BM : begin
//                                             n.CmdR <= 1'b1;
//                                             if(n.DataW == 8'h68 && n.CmdW == 1'b1) begin
//                                                 bm_bit <= n.DataW;
//                                                 w_state <= IDLE;
//                                             end 
//                                           end
                                READ_BM : begin
                                                n.CmdR <= 1'b0;
                                                source_id_bm <= n.DataW;
                                                bm_state <= TEST_DATA_BM;
                                          end
                           TEST_DATA_BM : begin
                                                Test_bm <= n.DataW;  //F0 or F4
                                                bm_state <= LEN_BM;
                                          end
                                LEN_BM :  begin
                                                Length_bm <= n.DataW;
                                                if(Test_bm <= 8'hF0) begin
                                                    bm_state <= DATA_BM_F0;
                                                    data_bm_st_F0 <= data_bm_0_F0;
                                                end
                                                else if (Test_bm <= 8'hF4) begin
                                                    bm_state <= DATA_BM_F4;
                                                    data_bm_st_F4 <= data_bm_0_F4;
                                                end
                                          end
                             DATA_BM_F0 : begin
                                            case(data_bm_st_F0)
                                            data_bm_0_F0 : begin
                                                                data_bm_reg_0 <= n.DataW;
                                                                data_bm_st_F0 <= data_bm_1_F0;
                                                           end
                                            data_bm_1_F0 : begin
                                                                data_bm_reg_1 <= n.DataW;
                                                                data_bm_st_F0 <= data_bm_2_F0;
                                                           end
                                            data_bm_2_F0 : begin
                                                                data_bm_reg_2 <= n.DataW;
                                                                data_bm_st_F0 <= data_bm_3_F0;
                                                           end
                                            data_bm_3_F0 : begin
                                                                data_bm_reg_3 <= n.DataW;
                                                                w_state <= IDLE;
                                                           end
                                            endcase
                                          end
                             DATA_BM_F4 : begin
                                            case(data_bm_st_F4)
                                            data_bm_0_F4 : begin
                                                            data_bm_reg_0_F4 <= n.DataW;
                                                            data_bm_st_F4 <= data_bm_1_F4;
                                                        end
                                            data_bm_1_F4 : begin
                                                            data_bm_reg_1_F4 <= n.DataW;
                                                            data_bm_st_F4 <= data_bm_2_F4;
                                                        end
                                            data_bm_2_F4 : begin
                                                            data_bm_reg_2_F4 <= n.DataW;
                                                            data_bm_st_F4 <= data_bm_3_F4;
                                                        end
                                            data_bm_3_F4 : begin
                                                            data_bm_reg_3_F4 <= n.DataW;
                                                            data_bm_reg_F4 <= {n.DataW, data_bm_reg_2_F4, data_bm_reg_1_F4, data_bm_reg_0_F4};
                                                            data_bm_st_F4 <= data_bm_4_F4;
                                                           end
                                            data_bm_4_F4 : begin
                                                            if(data_bm_reg_F4 != 32'h0000_0000) begin
                                                                counter <= 0;
                                                                if(counter == 0) begin
                                                                    //n.CmdR <= 1'b1;
                                                                    n.DataR <= data_bm_reg_0;
                                                                    counter++;
                                                                end
                                                                else if(counter == 1) begin
                                                                    //n.CmdR <= 1'b0;
                                                                    n.DataR <= data_bm_reg_1;
                                                                    counter++;
                                                                end
                                                                else if(counter == 2) begin
                                                                    n.DataR <= data_bm_reg_2;
                                                                    counter++;
                                                                end
                                                                else if(counter == 3) begin
                                                                    n.DataR <= data_bm_reg_3;
                                                                    //counter <= 0;
                                                                end
                                                            end
                                                            else if (data_bm_reg_F4 == 32'h0000_0000) begin
                                                                    w_state <= IDLE;
                                                            end
                                                            //w_state <= IDLE;
                                                        end
                                           endcase
                                        end
             endcase
             end
             endcase
            
          case(resp_state)
           IDLE_RESP : begin
                            n.CmdR <= 1'b1; n.DataR <= 32'h0000_0000;
                            if (Data_Read_Resp[119:112] == 8'h40) begin
                                resp_state <= READ_RESP;
                            end
                            else if (Data_Read_Resp[119:112] == 8'h80) begin
                                resp_state <= WRITE_RESP;
                            end
                      end
           READ_RESP : begin
                       case (data_read)
                            state_0 : begin
                                            n.CmdR <= 1'b1;read_en <= 1'b1;
                                            n.DataR <= Data_Read_Resp[119:112];
                                            data_read <= state_1;
                                      end
                            state_1 : begin
                                            read_en <= 1'b0; n.CmdR <= 1'b0;
                                            n.DataR <= Data_Read_Resp[111:104]; //For SourceID
                                            data_read <= state_2;
                                      end
                            state_2 : begin
                                            //read_en <= 1'b0; n.CmdR <= 1'b0;
                                            readlen_1 <= Data_Read_Resp[103:96]; // n.DataR; ///////////////For Length/////////////////////////
                                            data_read <= state_3;
                                      end
                            state_3 : begin
                                             n.DataR <= Data_Read_Resp[71:64];
                                             data_read <= state_4;                               //1st part of Data Read
                                      end
                            state_4 : begin
                                            n.DataR <= Data_Read_Resp[79:72];
                                            data_read <= state_5;                               //2nd part of Data Read
                                       end
                            state_5 : begin
                                            n.DataR <= Data_Read_Resp[87:80];
                                            data_read <= state_6;                               //3rd part of Data read
                                      end
                            state_6 : begin
                                            if (readlen_1 == 8'h04) begin
                                                n.DataR <= Data_Read_Resp[95:88];
                                                read_en <= 1'b0;
                                                data_read <= state_0;
                                                resp_state <= END_CODE;
                                            end
                                            else begin
                                                n.DataR <= Data_Read_Resp[95:88];            //4th part of data Read, Data read complete for Length 04
                                                data_read <= state_7;
                                                                                            //4th part of data Read, Data read complete for Length 04
                                            end
                                      end
                            state_7 : begin
                                            n.DataR <= Data_Read_Resp[39:32];
                                            data_read <= state_8;
                                                                                            // Now 2nd data for Legth 08 and 0C, 1st part of data read
                                      end
                            state_8 : begin
                                            n.DataR <= Data_Read_Resp[47:40];           // Now 2nd data for Legth 08 and 0C, 2nd part of data read
                                            data_read <= state_9;                         // Now 2nd data for Legth 08 and 0C, 2nd part of data read
                                      end
                            state_9 : begin
                                            n.DataR <= Data_Read_Resp[55:48];           // Now 2nd data for Legth 08 and 0C, 3rd part of data read
                                            data_read <= state_10;                        // Now 2nd data for Legth 08 and 0C, 3rd part of data read
                                      end
                            state_10 : begin
                                            if (readlen_1 == 8'h08) begin
                                                n.DataR <= Data_Read_Resp[63:56];// Now 2nd data for Legth 08 and 0C, 4th part of data read
                                                read_en <= 1'b0;
                                                data_read <= state_0;                        // Data Read complete for Length 08
                                                resp_state <= END_CODE;
                                            end
                                            else  begin
                                                n.DataR <= Data_Read_Resp[63:56];
                                                data_read <= state_11;
                                            end
                                      end
                           state_11 : begin
                                                n.DataR <= Data_Read_Resp[7:0];
                                                data_read <= state_12;
                                      end
                           state_12 : begin
                                                n.DataR <= Data_Read_Resp[15:8];
                                                data_read <= state_13;
                                      end
                           state_13 : begin                                             // Now 3rd data for Legth 0C, 3rd part of data read
                                                n.DataR <= Data_Read_Resp[23:16];
                                                data_read <= state_14;
                                      end
                           state_14 : begin                                              // Now 3rd data for Legth 0C, 4th part of data read
                                              n.DataR <= Data_Read_Resp[31:24];         //Data Read complete for Length 0C
                                                data_read <= state_0;
                                                resp_state <= END_CODE;
                                      end
                        endcase
                       end
            
            
          WRITE_RESP : begin
                       case(data_write)
                       state_w_0 : begin
                                        n.CmdR <= 1'b1;
                                        n.DataR <= Data_Read_Resp[119:112];
                                        data_write <= state_w_1;
                                   end
                       state_w_1 : begin         
                                        read_en <= 1'b0; n.CmdR <= 1'b0;
                                        n.DataR <= Data_Read_Resp[111:104];
                                        data_write <= state_w_2;
                                   end
                       state_w_2 : begin
                                        return_id <= n.DataR;
                                        write_en <= 1'b1;
                                        resp_state <= IDLE_RESP;
                                   end           
                       endcase
                       end
            END_CODE : begin
                            n.CmdR <= 1'b1;
                            n.DataR <= 8'hE0;
                            resp_state <= IDLE_RESP;
                       end
          endcase


        /*case(bm_resp)
                IDLE_RESP_BM : begin
                                    n.CmdR <= 1'b1; n.DataR <= 8'b0000_0000;
                                    if (data_from_fifo_bm[47:40] == 8'hF0)
                                        bm_resp <= READ_RESP_BM;
                                    else if(data_from_fifo_bm[47:40] == 8'hF4)
                                        bm_resp <= WRITE_RESP_BM;
                                        
                                    if(data_from_fifo_bm[47:40] == 8'hF4 && data_from_fifo_bm[31:0] != 32'h0000_0000)
                                        bm_resp <= READ_RESP_BM;
                                    else bm_resp <= IDLE_RESP_BM;
                               end
                READ_RESP_BM : begin
                                    case(data_read_bm)
                                        state_0_bm : begin
                                                            n.CmdR <= 1'b1; read_en_bm <= 1'b1;
                                                            n.DataR <= data_from_fifo_bm[47:40];
                                                            data_read_bm <= state_1_bm;
                                                     end
                                        state_1_bm : begin
                                                            n.CmdR <= 1'b0; read_en_bm <= 1'b0;
                                                            n.DataR <= data_from_fifo_bm[39:32];
                                                            data_read_bm <= state_2_bm;
                                                     end
                                        state_2_bm : begin
                                                            n.DataR <= data_from_fifo_bm[7:0];
                                                            data_read_bm <= state_3_bm;
                                                     end
                                        state_3_bm : begin
                                                            n.DataR <= data_from_fifo_bm[15:8];
                                                            data_read_bm <= state_4_bm;
                                                     end
                                        state_4_bm : begin
                                                            n.DataR <= data_from_fifo_bm[23:16];
                                                            data_read_bm <= state_5_bm;
                                                     end             
                                        state_5_bm : begin
                                                            n.DataR <= data_from_fifo_bm[31:24];
                                                            data_read_bm <= state_0_bm;
                                                            bm_resp <= IDLE_RESP_BM;
                                                     end
                                        endcase
                               end
               WRITE_RESP_BM : begin
                                    if(data_from_fifo_bm[31:0] != 32'h0000_0000)
                                        bm_resp <= READ_RESP_BM;
                                    else bm_resp <= IDLE_RESP_BM;
                               end
                                    
                                    case(data_write_bm)
                                        state_w0_bm : begin
                                                            //n.CmdR <= 1'b1; read_en_bm <= 1'b1;
                                                            n.DataR <= data_from_fifo_bm[47:40];
                                                            data_write_bm <= state_w1_bm;
                                                     end
                                        state_w1_bm : begin
                                                            //n.CmdR <= 1'b0; read_en_bm <= 1'b0;
                                                            n.DataR <= data_from_fifo_bm[39:32];
                                                            data_write_bm <= state_w2_bm;
                                                     end
                                        state_w2_bm : begin
                                                            //n.DataR <= data_from_fifo_bm[7:0];
                                                            data_write_bm <= state_w3_bm;
                                                     end
                                        state_w3_bm : begin
                                                            //n.DataR <= data_from_fifo_bm[15:8];
                                                            data_write_bm <= state_w4_bm;
                                                     end
                                        state_w4_bm : begin
                                                            //n.DataR <= data_from_fifo_bm[23:16];
                                                            data_write_bm <= state_w5_bm;
                                                     end             
                                        state_w5_bm : begin
                                                            //n.DataR <= data_from_fifo_bm[31:24];
                                                            data_write_bm <= state_w0_bm;
                                                            bm_resp <= IDLE_RESP_BM;
                                                     end
                                        endcase
                               end
        endcase */
    end
    end
    always @(posedge c.clk or posedge c.rst) begin
            if(Status_0C == 1'b1) begin
                case(Status_Check)
                    Status_0 : begin
                                c.Sel <= 1; c.RW <= 0;
                                c.addr <= addrs_r1 + 32'h0000_0004;
                                data_read_2 <= c.data_rd;
                                Status_Check <= Status_1;
                               end
                    Status_1 : begin
                                c.Sel <= 0; c.RW <= 0;
                                reg_data1 <= {8'h40, source_id_w, read_len, data_read_1, data_read_2, c.data_rd};
                                write_en <= 1'b1;
                                Status_0C <= 1'b0;
                                Status_Check <= Status_0;
                               end
            endcase  
           end
    end
    
   always @(posedge c.clk or posedge c.rst) begin
     if(Status_08 == 1'b1) begin
            c.Sel <= 0; c.RW <= 0;
            reg_data1 <= {8'h40, source_id_w, read_len, data_read_1, c.data_rd, 32'h0000_0000};
            write_en <= 1'b1;
            Status_08 <= 1'b0;
     end
    end
endmodule : noc


module fifo (clk, rst, write_en, read_en, data_from_crc, fifo_full, fifo_empty, data_out);
parameter width = 120;
parameter depth = 20;


    input clk, rst, write_en, read_en;
    input [width-1:0] data_from_crc;
    output fifo_full, fifo_empty;
    output reg [width-1:0] data_out;
    reg [width-1:0] FIFO_data1[depth-1:0];
    reg [3:0] rd_ptr, wr_ptr;


    assign fifo_full = ((wr_ptr == 20) && (rd_ptr == 0))?1:((rd_ptr == wr_ptr +1)?1:0);
    assign fifo_empty = (rd_ptr == wr_ptr)?1:0;
    
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            data_out <= 0;
        end
        else begin
             if (read_en == 1'b1 && fifo_empty == 1'b0) begin
                    data_out <= FIFO_data1[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                  end
             else begin
                    data_out <= data_out;
                    rd_ptr <= rd_ptr;
                  end
             if (write_en == 1'b1 && fifo_full == 1'b0) begin
                    FIFO_data1[wr_ptr] <= data_from_crc;
                    wr_ptr <= wr_ptr +1;
                  end
             else begin
                    FIFO_data1[wr_ptr] <= FIFO_data1[wr_ptr];
                    wr_ptr <= wr_ptr;
                  end
        end
   end
endmodule : fifo


/*module fifo_bm (clk, rst, write_en_bm, read_en_bm, data_from_noc, fifo_full_bm, fifo_empty_bm, data_out_bm);
parameter width = 48;
parameter depth = 20;


    input clk, rst, write_en_bm, read_en_bm;
    input [width-1:0] data_from_noc;
    output fifo_full_bm, fifo_empty_bm;
    output reg [width-1:0] data_out_bm;
    reg [width-1:0] FIFO_data1_bm[depth-1:0];
    reg [3:0] rd_ptr_bm, wr_ptr_bm;


    assign fifo_full_bm = ((wr_ptr_bm == 20) && (rd_ptr_bm == 0))?1:((rd_ptr_bm == wr_ptr_bm +1)?1:0);
    assign fifo_empty_bm = (rd_ptr_bm == wr_ptr_bm)?1:0;
    
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            wr_ptr_bm <= 0;
            rd_ptr_bm <= 0;
            data_out_bm <= 0;
        end
        else begin
             if (read_en_bm == 1'b1 && fifo_empty_bm == 1'b0) begin
                    data_out_bm <= FIFO_data1_bm[rd_ptr_bm];
                    rd_ptr_bm <= rd_ptr_bm + 1;
                  end
             else begin
                    data_out_bm <= data_out_bm;
                    rd_ptr_bm <= rd_ptr_bm;
                  end
             if (write_en_bm == 1'b1 && fifo_full_bm == 1'b0) begin
                    FIFO_data1_bm[wr_ptr_bm] <= data_from_noc;
                    wr_ptr_bm <= wr_ptr_bm +1;
                  end
             else begin
                    FIFO_data1_bm[wr_ptr_bm] <= FIFO_data1_bm[wr_ptr_bm];
                    wr_ptr_bm <= wr_ptr_bm;
                  end
        end
   end
endmodule : fifo_bm */
