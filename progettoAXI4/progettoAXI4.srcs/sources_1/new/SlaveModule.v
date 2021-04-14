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


module SlaveModule#(parameter DATA_WIDTH_SLAVE = 32,
parameter STROBE_WIDTH_SLAVE = DATA_WIDTH_SLAVE/8,
parameter ADDRESS_WIDTH_SLAVE = 8)(

	//Global signals
	input 					aclk,
	input 					aresetn,
	//Write address channel
	input [ADDRESS_WIDTH_SLAVE-1:0] 	awaddr,
	input					awvalid,
	output	reg				awready,
	//Write data channel
	input [DATA_WIDTH_SLAVE-1:0]		wdata,
	input [STROBE_WIDTH_SLAVE-1:0]		wstrb,
	input 					wvalid,
	output	reg				wready,			
	//Write response channel
	output	reg				bvalid,
	input					bready,
	//Read address channel
	input [ADDRESS_WIDTH_SLAVE-1:0]		araddr,
    input [2:0]             arprot,
	input					arvalid,
	output	reg			    arready,
	//Read data channel
	output reg[DATA_WIDTH_SLAVE-1:0]	rdata,
	output	reg				rvalid,
	input					rready
	);

reg [2:0] ss, ss_next;
localparam S0=3'b000, READ=3'b001, DATAREAD=3'b010, WRITE=3'b011, DATAWRITE=3'b100,RESPONSE=3'b101, READINIT=3'b110, WRITEINIT=3'b111; 
reg [DATA_WIDTH_SLAVE-1:0] memory [0:1023];
reg [2:0] prot;
localparam path="C:\ProgettoES1\progettoAXI4\data.hex";
integer outfile;
integer i;
reg [DATA_WIDTH_SLAVE-1:0] temp_memory;

always @(posedge aclk)
if(aresetn) ss<=S0;
else ss<=ss_next;

always @(ss,awaddr,awvalid,wdata,wstrb,wvalid,bready,araddr,arprot,arvalid,rready)
begin
    ss_next=ss;
    $readmemh("data.hex",memory);
    begin
    case(ss)
        S0: 
            begin
                awready=0;
                wready=0;
                bvalid=0;
                awready=0;
                arready=0;
                rvalid=0;
                rdata=0;
            
                if(awvalid==1) ss_next=WRITEINIT;
                
                if(arvalid==1) ss_next=READINIT;
                    
            end
        
        
        READINIT:
            begin
                arready=1;
                prot=arprot;
                ss_next=READ;
            end
            
            
        WRITEINIT:
            begin
                awready=1;
                ss_next=WRITE;
            end
        
        
        READ:
            if(rready==1)
                begin
                    rvalid=1;
                    ss_next=DATAREAD;
                    arready=0;
                end
        
        DATAREAD:
            begin
                rdata = memory[araddr];
                ss_next=S0;
            end
            
        WRITE:
            if(wvalid==1)
              begin
                wready=1;
                ss_next=DATAWRITE; 
                awready=0;   
              end
          
        DATAWRITE:
            begin
                temp_memory=memory[awaddr];
                for(i=0; i<32; i=i+1)
                    begin
                        if(wstrb[i/8]==1)
                            begin
                                temp_memory[i]=wdata[i];     
                            end
                    end
                    
                memory[awaddr]=temp_memory;
                outfile=$fopen("data.hex","w");
                for (i=0; i<1024; i=i+1) 
                    begin
                        $fdisplay(outfile,"%h",memory[i]);  //write as hexadecimal 
                    end
                $fclose(outfile);
                ss_next=RESPONSE;
            end
        
        RESPONSE:
            begin
                if(bready==1) 
                    begin
                        bvalid=1;
                        ss_next=S0;
                    end
            end
      endcase
    end
end
     
endmodule

