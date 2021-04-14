`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2021 15:53:37
// Design Name: 
// Module Name: ReadModule
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



module MasterModule#(parameter DATA_WIDTH_MASTER = 32,
parameter STROBE_WIDTH_MASTER = DATA_WIDTH_MASTER/8,
parameter ADDRESS_WIDTH_MASTER = 8)(

	//Global signals
	input 					aclk,
	input 					aresetn,
	//Write address channel
	output reg [ADDRESS_WIDTH_MASTER-1:0] 	 awaddr,
	output reg				awvalid,
	input					awready,
	//Write data channel
	output reg [DATA_WIDTH_MASTER-1:0]		 wdata,
	output reg [STROBE_WIDTH_MASTER-1:0]	 wstrb,
	output reg				                 wvalid,
	input                                    wready,			
	//Write response channel
    input					bvalid,
	output reg				bready,
	//Read address channel
	output reg [ADDRESS_WIDTH_MASTER-1:0]	araddr,
    output reg [2:0]                        arprot,
	output reg                              arvalid,
	input                                   arready,
	//Read data channel
	input [DATA_WIDTH_MASTER-1:0]			rdata,
	input                                   rvalid,
	output reg                              rready,
	//Test signals
	input read,
	input write	
	);

reg [DATA_WIDTH_MASTER-1:0]dataIncoming;
reg [2:0] ss, ss_next;
reg [DATA_WIDTH_MASTER-1:0] write_data=32'b10101010101010101010101010101010; //4500011
reg [STROBE_WIDTH_MASTER-1:0] write_strb=4'b1111;
reg [ADDRESS_WIDTH_MASTER-1:0] addr = 8'b00000000;
localparam S0=3'b000, READ=3'b001, DATAREAD=3'b010, WRITE=3'b011, DATAWRITE=3'b100, RESPONSE=3'b101, READINIT=3'b110, WRITEINIT=3'b111; 
integer update = 0;

always @(posedge aclk)
if(aresetn) ss<=S0;
else ss<=ss_next;

always @(ss,read,write,addr,aresetn,awready,wready,bvalid,arready,rdata,rvalid)
begin
    ss_next=ss;
    begin
    case(ss)
        S0: 
            begin
                wdata=0;
                wstrb=0;
                wvalid=0;
                awvalid=0;
                arvalid=0;
                arprot=0;
                rready=0;
                bready=0;
                update=0;
                
                if(write==1) ss_next=WRITEINIT;
                    
                if(read==1) ss_next=READINIT;

            end
        
        
        WRITEINIT:
            begin
                ss_next=WRITE;
                awvalid=1;
                awaddr=addr;
            end
            
            
        READINIT:
            begin
                arvalid=1;
                ss_next=READ;
                araddr=addr;
                arprot= 3'b101;                    
            end     

            
        
        READ:
            if(arready==1)
                begin
                    rready=1;
                    ss_next=DATAREAD; 
                    arvalid=0;
                end
            else ss_next=S0;
        
        
        DATAREAD:
            begin
                dataIncoming=rdata;
                ss_next=S0;
                if(update==0)
                    begin
                        addr=addr+1;
                        update = 1;
                    end
            end
            
            
        WRITE:
            if(awready==1)
                 begin
                    wvalid=1;
                    bready=1;
                    ss_next=DATAWRITE;
                    awvalid=0;
                  end
            else ss_next=S0; 
        
          
        DATAWRITE:
            begin
                wdata = write_data;
                wstrb = write_strb;
                if(update==0)
                    begin
                        write_data = write_data+1;
                        addr=addr+1;
                        write_strb=write_strb+1;
                        update = 1;
                    end
                ss_next=RESPONSE;
            end
        
        
        RESPONSE:
            begin
                if(bvalid==1) ss_next=S0;
                else ss_next=RESPONSE;
            end
      endcase
    end
end
endmodule

