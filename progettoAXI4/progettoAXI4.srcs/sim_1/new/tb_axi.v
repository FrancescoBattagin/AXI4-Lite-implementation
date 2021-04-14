`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2021 11:39:24
// Design Name: 
// Module Name: tb_axi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_axi();
    parameter DATA_WIDTH_SLAVE = 32;
parameter STROBE_WIDTH_SLAVE = DATA_WIDTH_SLAVE/8;
parameter ADDRESS_WIDTH_SLAVE = 8;
    parameter DATA_WIDTH_MASTER = 32;
parameter STROBE_WIDTH_MASTER = DATA_WIDTH_MASTER/8;
parameter ADDRESS_WIDTH_MASTER = 8;
    
    reg clk_tb;
    reg rst_tb;

    reg read_tb;
    reg write_tb;
    
    integer i = 0; 

    //generated clk signal
    always #5 clk_tb=~clk_tb;
    
    //test
    initial
    begin
        clk_tb=0;
        rst_tb=1;
        
        //rst
        repeat(2) @(posedge clk_tb);
        rst_tb =0;
        
        //10 read -> only if addr%3!=0
        repeat(2) @(posedge clk_tb);
        repeat(10)
            begin
                if(i%2!=0)
                    begin
                        #50 read_tb=1;
                        #20 read_tb=0;
                        #50 read_tb=1;
                        #20 read_tb=0;
                        #50 write_tb=1;
                        #20 write_tb=0;
                        #50 read_tb=1;
                        #20 read_tb=0;
                    end
                else
                    begin
                        #50 write_tb=1;
                        #20 write_tb=0;
                        #50 read_tb=1;
                        #20 read_tb=0;
                        #50 write_tb=1;
                        #20 write_tb=0;
                        #50 read_tb=1;
                        #20 read_tb=0;
                    end
                i=i+1;
            end
        
          
        //rst
        repeat(2) @(posedge clk_tb);
        rst_tb = 1;
        repeat(2) @(posedge clk_tb);
        rst_tb =0;
        
             
        $finish;
    end

    
        AxiModule AM0(
        .aclk_axi(clk_tb),
        .aresetn_axi(rst_tb),
        .read(read_tb),
        .write(write_tb)
        );
        
endmodule