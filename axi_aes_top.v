`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2026 18:50:49
// Design Name: 
// Module Name: axi_aes_top
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


module axi_aes_top(

    input clk,
    input rst,

    // AXI Write Address Channel
    input [31:0] s_axi_awaddr,
    input        s_axi_awvalid,
    output reg   s_axi_awready,

    // AXI Write Data Channel
    input [31:0] s_axi_wdata,
    input        s_axi_wvalid,
    output reg   s_axi_wready,

    // AXI Write Response
    output reg   s_axi_bvalid,
    input        s_axi_bready,

    // AXI Read Address Channel
    input [31:0] s_axi_araddr,
    input        s_axi_arvalid,
    output reg   s_axi_arready,

    // AXI Read Data Channel
    output reg [31:0] s_axi_rdata,
    output reg        s_axi_rvalid,
    input             s_axi_rready
);

//------------------------------------
// Registers
//------------------------------------

reg [31:0] control_reg;
reg [31:0] status_reg;

reg [127:0] plaintext_reg;
reg [127:0] key_reg;
reg [127:0] ciphertext_reg;

//------------------------------------
// AES Signals
//------------------------------------

reg start_aes;
reg aes_started;
reg aes_busy_d;

wire [127:0] aes_out;
wire aes_busy;

//------------------------------------
// AES Core
//------------------------------------

aes_core aes_inst(
    .clk(clk),
    .load_i(start_aes),
    .key_i({128'h0,key_reg}),
    .data_i(plaintext_reg),
    .size_i(2'b00),
    .dec_i(1'b0),
    .data_o(aes_out),
    .busy_o(aes_busy)
);

//------------------------------------
// Busy Delay
//------------------------------------

always @(posedge clk)
begin
    aes_busy_d <= aes_busy;
end

//------------------------------------
// FSM
//------------------------------------

parameter IDLE = 2'd0;
parameter RUN  = 2'd1;
parameter DONE = 2'd2;

reg [1:0] state;

always @(posedge clk)
begin

    if(rst)
    begin
        state <= IDLE;

        start_aes <= 0;
        aes_started <= 0;

        status_reg <= 0;
        ciphertext_reg <= 0;
    end

    else
    begin

        case(state)

        IDLE:
        begin

            status_reg <= 0;
            start_aes <= 0;
            aes_started <= 0;

            if(control_reg[0])
                state <= RUN;

        end

        RUN:
        begin

            if(!aes_started)
            begin
                start_aes <= 1;
                aes_started <= 1;
            end
            else
                start_aes <= 0;

            if(aes_busy_d && !aes_busy)
            begin
                ciphertext_reg <= aes_out;
                state <= DONE;
            end

        end

        DONE:
        begin
            status_reg <= 32'h1;
        end

        endcase

    end

end

//------------------------------------
// AXI WRITE CHANNEL
//------------------------------------

always @(posedge clk)
begin

    if(rst)
    begin
        s_axi_awready <= 0;
        s_axi_wready  <= 0;
        s_axi_bvalid  <= 0;

        control_reg   <= 0;
        plaintext_reg <= 0;
        key_reg       <= 0;
    end

    else
    begin

        s_axi_awready <= 0;
        s_axi_wready  <= 0;

        //--------------------------------
        // Write Transaction
        //--------------------------------

        if(s_axi_awvalid && s_axi_wvalid)
        begin

            s_axi_awready <= 1;
            s_axi_wready  <= 1;
            s_axi_bvalid  <= 1;

            case(s_axi_awaddr)

                //--------------------------------
                // Control
                //--------------------------------

                32'h00:
                    control_reg <= s_axi_wdata;

                //--------------------------------
                // Plaintext
                //--------------------------------

                32'h08:
                    plaintext_reg[31:0] <= s_axi_wdata;

                32'h0C:
                    plaintext_reg[63:32] <= s_axi_wdata;

                32'h10:
                    plaintext_reg[95:64] <= s_axi_wdata;

                32'h14:
                    plaintext_reg[127:96] <= s_axi_wdata;

                //--------------------------------
                // Key
                //--------------------------------

                32'h18:
                    key_reg[31:0] <= s_axi_wdata;

                32'h1C:
                    key_reg[63:32] <= s_axi_wdata;

                32'h20:
                    key_reg[95:64] <= s_axi_wdata;

                32'h24:
                    key_reg[127:96] <= s_axi_wdata;

            endcase

        end

        //--------------------------------
        // Write Response
        //--------------------------------

        if(s_axi_bvalid && s_axi_bready)
            s_axi_bvalid <= 0;

    end

end

//------------------------------------
// AXI READ CHANNEL
//------------------------------------

always @(posedge clk)
begin

    if(rst)
    begin
        s_axi_arready <= 0;
        s_axi_rvalid  <= 0;
        s_axi_rdata   <= 0;
    end

    else
    begin

        s_axi_arready <= 0;

        //--------------------------------
        // Read Transaction
        //--------------------------------

        if(s_axi_arvalid)
        begin

            s_axi_arready <= 1;
            s_axi_rvalid  <= 1;

            case(s_axi_araddr)

                //--------------------------------
                // Control / Status
                //--------------------------------

                32'h00:
                    s_axi_rdata <= control_reg;

                32'h04:
                    s_axi_rdata <= status_reg;

                //--------------------------------
                // Plaintext
                //--------------------------------

                32'h08:
                    s_axi_rdata <= plaintext_reg[31:0];

                32'h0C:
                    s_axi_rdata <= plaintext_reg[63:32];

                32'h10:
                    s_axi_rdata <= plaintext_reg[95:64];

                32'h14:
                    s_axi_rdata <= plaintext_reg[127:96];

                //--------------------------------
                // Key
                //--------------------------------

                32'h18:
                    s_axi_rdata <= key_reg[31:0];

                32'h1C:
                    s_axi_rdata <= key_reg[63:32];

                32'h20:
                    s_axi_rdata <= key_reg[95:64];

                32'h24:
                    s_axi_rdata <= key_reg[127:96];

                //--------------------------------
                // Ciphertext
                //--------------------------------

                32'h28:
                    s_axi_rdata <= ciphertext_reg[31:0];

                32'h2C:
                    s_axi_rdata <= ciphertext_reg[63:32];

                32'h30:
                    s_axi_rdata <= ciphertext_reg[95:64];

                32'h34:
                    s_axi_rdata <= ciphertext_reg[127:96];

                default:
                    s_axi_rdata <= 32'h0;

            endcase

        end

        //--------------------------------
        // Read Response Complete
        //--------------------------------

        if(s_axi_rvalid && s_axi_rready)
            s_axi_rvalid <= 0;

    end

end
endmodule