`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2021 10:06:52
// Design Name: 
// Module Name: AxiModule
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


module AxiModule #(parameter DATA_WIDTH_SLAVE = 32,
parameter STROBE_WIDTH_SLAVE = DATA_WIDTH_SLAVE/8,
parameter ADDRESS_WIDTH_SLAVE = 8,
parameter DATA_WIDTH_MASTER = 32,
parameter STROBE_WIDTH_MASTER = DATA_WIDTH_MASTER/8,
parameter ADDRESS_WIDTH_MASTER = 8)(
    input read,
    input write,
    input aclk_axi,
    input aresetn_axi
);


    //master input
    wire awready;
    wire wready;
    wire bvalid;
    wire arready;
    wire [DATA_WIDTH_MASTER-1:0]    rdata;
    wire rvalid;

    //slave input
    wire [ADDRESS_WIDTH_SLAVE-1:0] awaddr;
    wire awvalid;
    wire [DATA_WIDTH_SLAVE-1:0] wdata;
    wire [STROBE_WIDTH_SLAVE-1:0] wstrb;
    wire wvalid;
    wire bready;
    wire [ADDRESS_WIDTH_SLAVE-1:0] araddr;
    wire [2:0] arprot;
    wire arvalid;
    wire rready;


    //Master instance
        MasterModule MM0(
        .aclk(aclk_axi),
        .aresetn(aresetn_axi),
        .awready(awready),
        .wready(wready),
        .bvalid(bvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .awvalid(awvalid),
        .wdata(wdata),
	    .wstrb(wstrb),
	    .wvalid(wvalid),
	    .bready(bready),
        .arprot(arprot),
        .arvalid(arvalid),
        .rready(rready),  
        .read(read),
        .write(write),
        .awaddr(awaddr),
        .araddr(araddr)
        );
    
        //Slave instance
        SlaveModule SM0(
        .aclk(aclk_axi),
        .aresetn(aresetn_axi),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .bready(bready),
        .araddr(araddr),
        .arprot(arprot),
        .arvalid(arvalid),
        .rready(rready),
        .awready(awready),
        .wready(wready),
        .bvalid(bvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid)
        );

endmodule
