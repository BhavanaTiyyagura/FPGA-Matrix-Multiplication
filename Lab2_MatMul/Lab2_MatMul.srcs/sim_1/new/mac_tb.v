`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2026 04:12:03 PM
// Design Name: 
// Module Name: mac_tb
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



module mac_tb;
    parameter DATA_WIDTH = 32;

    // Inputs to MAC → reg in testbench
    reg clk;
    reg resetn;
    reg clear;
    reg [DATA_WIDTH-1:0] data_A;
    reg [DATA_WIDTH-1:0] data_B;

    // Output from MAC → wire in testbench
    wire [DATA_WIDTH-1:0] data_R;


    
        MAC #(.DATA_WIDTH(DATA_WIDTH)) 
        dut (
        .s00_axi_aclk(clk),
        .s00_axi_aresetn(resetn),
        .clear(clear),
        .data_A(data_A),
        .data_B(data_B),
        .data_R(data_R)
    );
    
        always #10 clk = ~clk;
            initial begin
        clk = 1;
        resetn = 1;
        clear = 1;
        data_A = 0;
        data_B = 0;

        @(posedge clk);
        clear = 0;
        data_A = 2;
        data_B = 5;
        
        @(posedge clk);
        data_A = 3;
        data_B = 6;
        
        @(posedge clk);
        data_A = 4;
        data_B = 8;    
        @(negedge clk);
        @(posedge clk);
        $stop;
        end
    
    endmodule