`timescale 1ns/1ps

module tb_axi_aes;

reg clk;
reg rst;

// AXI Write Address
reg [31:0] s_axi_awaddr;
reg s_axi_awvalid;
wire s_axi_awready;

// AXI Write Data
reg [31:0] s_axi_wdata;
reg s_axi_wvalid;
wire s_axi_wready;

// AXI Write Response
wire s_axi_bvalid;
reg s_axi_bready;

// AXI Read Address
reg [31:0] s_axi_araddr;
reg s_axi_arvalid;
wire s_axi_arready;

// AXI Read Data
wire [31:0] s_axi_rdata;
wire s_axi_rvalid;
reg s_axi_rready;

axi_aes_top dut(
    .clk(clk),
    .rst(rst),

    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),

    .s_axi_wdata(s_axi_wdata),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),

    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),

    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),

    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready)
);

// Clock Generation
always #5 clk = ~clk;

// AXI Write Task
task axi_write;
input [31:0] addr;
input [31:0] data;
begin
    @(posedge clk);

    s_axi_awaddr  <= addr;
    s_axi_awvalid <= 1'b1;

    s_axi_wdata   <= data;
    s_axi_wvalid  <= 1'b1;

    @(posedge clk);

    s_axi_awvalid <= 1'b0;
    s_axi_wvalid  <= 1'b0;
end
endtask

//----------------------------------------------------
// TEST
//----------------------------------------------------

initial
begin

    clk = 0;
    rst = 1;

    s_axi_awaddr  = 0;
    s_axi_awvalid = 0;

    s_axi_wdata   = 0;
    s_axi_wvalid  = 0;

    s_axi_bready  = 1;

    s_axi_araddr  = 0;
    s_axi_arvalid = 0;

    s_axi_rready  = 1;

    //------------------------------------
    // RESET
    //------------------------------------

    #20;
    rst = 0;

    $display("=================================");
    $display("TB Started");
    $display("=================================");

    //------------------------------------
    // PLAINTEXT
    //------------------------------------

    axi_write(32'h08,32'hCCDDEEFF);
    axi_write(32'h0C,32'h8899AABB);
    axi_write(32'h10,32'h44556677);
    axi_write(32'h14,32'h00112233);

    //------------------------------------
    // KEY
    //------------------------------------

    axi_write(32'h18,32'h0C0D0E0F);
    axi_write(32'h1C,32'h08090A0B);
    axi_write(32'h20,32'h04050607);
    axi_write(32'h24,32'h00010203);

    //------------------------------------
    // START AES
    //------------------------------------

    axi_write(32'h00,32'h00000001);

    $display("AES Start Command Issued");

    //------------------------------------
    // WAIT
    //------------------------------------

    #500;

    //------------------------------------
    // RESULTS
    //------------------------------------

    $display("=================================");
    $display("STATUS      = %h", dut.status_reg);
    $display("FSM         = %d", dut.state);
    $display("AES_BUSY    = %b", dut.aes_busy);
    $display("AES_OUT     = %h", dut.aes_out);
    $display("CIPHERTEXT  = %h", dut.ciphertext_reg);
    $display("=================================");

    #20;

    $finish;

end

endmodule