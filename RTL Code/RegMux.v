module RegMux (x , out  , clk , rst , cen );
parameter  WIDTH_INPUT = 18 ;
parameter RSTTYPE = "SYNC" ;
parameter SELECT = 0 ;
input [WIDTH_INPUT-1 : 0 ] x ;
input rst , clk , cen ;
output reg  [WIDTH_INPUT-1 : 0] out ;
reg [WIDTH_INPUT-1 : 0] x_reg ;
generate
    if (RSTTYPE == "SYNC") begin 
         always @(posedge clk ) begin
             if ( rst )begin 
                 x_reg <= 0 ;
             end 
             else if (cen) begin 
                 x_reg <= x ;
             end  
             end
             end 
    else  begin 
         always @(posedge clk , posedge rst ) begin
             if ( rst )begin 
                 out <= 0 ;
             end 
             else if (cen) begin 
                 x_reg <= x ;
             end  
             end
             end  
endgenerate
always @(*) begin
     if (SELECT) begin 
           out = x_reg ;
     end 
     else begin 
           out = x ;
     end 
end
endmodule