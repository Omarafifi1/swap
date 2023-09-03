`timescale 1ns / 1ps

module swap_reg_file_tb;

  
    
    parameter address_width = 7;
    parameter data_width = 8;
    reg clk, rst_n;
    reg we;
    reg [address_width - 1: 0] address_w, address_r;
    reg [data_width - 1: 0] data_w;
    wire [data_width - 1: 0] data_r;    
    reg [address_width - 1: 0] address_a, address_b;
    reg swap;
    integer i;
    
    // Instantiate unit under test
    swap_reg #(.address_width(address_width), .data_width(data_width)) uut(
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .address_w(address_w),
        .address_r(address_r),
        .data_w(data_w),
        .data_r(data_r),
        .address_a(address_a),
        .address_b(address_b),
        .swap(swap)
    );
    
    // Generate stimuli
    
    // Generating a clk signal
    localparam T = 10;
    always
    begin
        clk = 1'b0;
        #(T / 2);
        clk = 1'b1;
        #(T / 2);
    end
        
    initial
    begin
        // issue a quick reset for 2 ns
        rst_n = 1'b0;
        #2  
        rst_n = 1'b1;
        swap = 1'b0;

    
        // fill locations 20 to 30 with some numbers
        for (i = 20; i < 30; i = i + 1)
        begin
            @(negedge clk);
            address_w = i;
            data_w = i;
            we = 1'b1;            
        end
        
        we = 1'b0;
        
        // Swap 2 locations several times
        @(negedge clk)
        address_a = 'd22;
        address_b = 'd28;
        swap = 1'b1;
        repeat(3) @(negedge clk);
        swap = 1'b0;
        
        #25 $stop;
        
        
    end    
    
endmodule

