module mux_4x1 #(parameter address_width=7 )(

input [address_width-1:0]w0,w1,w2,w3,
input [1:0]sel,
output reg [address_width-1:0] y

);
always @(*)
begin
  case(sel)
    
      2'b00:y=w0;
      2'b01:y=w1;
      2'b10:y=w2;
      2'b11:y=w3;   
    endcase
  end
endmodule




module mux_2x1 #(parameter data_width=8 )(

input [data_width-1:0]w0,w1,
input sel,
output reg [data_width-1:0] z

);
always @(*)
begin
  case(sel)
    
      1'b0:z=w0;
      1'b1:z=w1;
        
    endcase
  end
endmodule



module mux_2x1_1bit (

input w0,w1,
input sel,
output reg  f

);

always @(*)
begin
  case(sel)
    
      1'b0:f=w0;
      1'b1:f=w1;
        
    endcase
  end
endmodule









module reg_file
    #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 8)(
    input clk,
    input we,
    input [ADDR_WIDTH - 1: 0] address_w, address_r,
    input [DATA_WIDTH - 1: 0] data_w,
    output [DATA_WIDTH - 1: 0] data_r    
    );
    
    reg [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];
    
    always @(posedge clk)
    begin
        // Synchronous write port
        if (we)
            memory[address_w] <= data_w;                              
    end
    
    // Asynchronous read port
    assign data_r = memory[address_r];

endmodule




module fsm_control_unit(
input swap,clk,rst_n,
output reg we,
output reg[1:0]sel
);
reg [1:0]current_state,next_state;
localparam s0=0,s1=1,s2=2,s3=3;

always@(posedge clk,negedge rst_n)
begin
  if(!rst_n)
    current_state<=s0;
  else
    current_state<=next_state;
end



always@(*)
begin
  next_state=current_state;
  case(current_state)
    s0:
       if(!swap)
         next_state=s0;
       else
         next_state=s1;
    s1:
        next_state=s2;
    s2:
        next_state=s3;
    s3:
        next_state=s0;
    default:next_state=s0;
  endcase
  
  
  
end




always@(*)
begin
  we=~(current_state==s0);
  sel=current_state;
  
end

endmodule








module swap_reg
#(parameter address_width=7,data_width=8)(
input swap,
input [address_width-1:0]address_a,address_b,
input [address_width-1:0]address_w,address_r,
input we,
input [data_width-1:0]data_w,data_r,
input clk,
input rst_n



);

wire [address_width-1:0]mux_write,mux_read;
wire [1:0]s;
wire w_enable;
wire mux_we;
wire [data_width-1:0]mux_data_write;

 mux_4x1 #(.ADDR_WIDTH(address_width)) mux0(
 .w0(address_w),
 .w1(0),
 .w2(address_a),
 .w3(address_b), 
 .sel(s),
.y(mux_write)      

 
 
 );
 mux_4x1 #(.ADDR_WIDTH(address_width)) mux1(
 .w0(address_r),
 .w1(address_a),
 .w2(address_b),
 .w3(0), 
 .sel(s),
.y(mux_read)     
 
 
 );
fsm_control_unit FSM(
.swap(swap),
.clk(clk),
.rst_n(rst_n),   
.we(w_enable),          
.sel(s)      

);
reg_file #(.ADDR_WIDTH(address_width),.DATA_WIDTH(data_width))RF(
.clk(clk),
.we(mux_we),
.address_w(mux_write),
 .address_r(mux_read),
.data_w(mux_data_write),
 .data_r (data_r)   
 
 /*reg_file #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) REG_FILE(
        .clk(clk),
        .we(w? 1'b1: we),  // implememt mux2x1
        .address_w(MUX_WRITE_f),
        .address_r(MUX_READ_f),
        .data_w(w? data_r: data_w),  // implememt mux2x1
        .data_r(data_r)
    );
    */



);
mux_2x1_1bit  mux2(
.w0(we),
.w1(1),
.sel(w_enable),
.f(mux_we)




);
mux_2x1 #(.DATA_WIDTH(data_width)) mux3(

.w0(data_w),
.w1(data_r),
.sel(w_enable),
.z(mux_data_write)


);
endmodule











