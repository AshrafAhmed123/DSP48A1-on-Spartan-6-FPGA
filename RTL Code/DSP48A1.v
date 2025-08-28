module DSP48A1(A,B,C,D,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,
CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
// define all ports and parameters 
parameter A0REG = 0 ; 
parameter A1REG = 1 ;
parameter B0REG = 0 ;
parameter B1REG = 1 ;
parameter CREG  = 1 ;
parameter DREG  = 1 ;
parameter MREG  = 1 ;  
parameter PREG  = 1 ;
parameter CARRYINREG = 1 ; 
parameter CARRYOUTREG = 1 ;
parameter OPMODEREG = 1 ;
parameter CARRYINSEL = "OPMODE5" ;
parameter B_INPUT = "DIRECT" ;
parameter RSTTYPE = "SYNC" ; 
input [17:0] A , B , D ;
input [47:0] C ;
input CLK , CARRYIN ;
input [7:0] OPMODE ;
input [17:0] BCIN ;
input RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE ;
input CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE ;
input [47:0] PCIN ;
output [17:0] BCOUT ;
output [47:0] PCOUT , P ;
output [35:0] M ;
output CARRYOUT,CARRYOUTF ;
// define internal signal 
wire [17:0] s1 , s2 , s3 , s4 , s6 ,s7 ;
wire [47:0] s5 ;
wire [7:0] out_OPMODE ;
wire [17:0] PRE_out_addsub1  ; 
reg  [47:0] POST_out_addsub2 ;
wire [35:0] out_Multiply , s8 ;
wire M1 , out_carryin ;
reg carry_out ;
reg  [47:0] outx , outz ;
RegMux #(.WIDTH_INPUT(18),.RSTTYPE(RSTTYPE),.SELECT(DREG)) B1(.x(D),.clk(CLK),.rst(RSTD),.cen(CED),.out(s1));  // Block (D)
assign s2 = (B_INPUT == "DIRECT" ) ? B : (B_INPUT == "CASCADE") ? BCIN : 18'b0 ;
RegMux #(.WIDTH_INPUT(18),.RSTTYPE(RSTTYPE),.SELECT(B0REG)) B2 (.x(s2),.clk(CLK),.rst(RSTB),.cen(CEB),.out(s3)); // Block (B0)
RegMux #(.WIDTH_INPUT(18),.RSTTYPE(RSTTYPE),.SELECT(A0REG)) B3 (.x(A),.clk(CLK),.rst(RSTA),.cen(CEA),.out(s4)); // Block (A0)
RegMux #(.WIDTH_INPUT(48),.RSTTYPE(RSTTYPE),.SELECT(CREG)) B4 (.x(C),.clk(CLK),.rst(RSTC),.cen(CEC),.out(s5)); // Block (C)
// Block the OPMODE [7:0]
RegMux #(.WIDTH_INPUT(8),.RSTTYPE(RSTTYPE),.SELECT(OPMODEREG)) OPM6 (.x(OPMODE),.clk(CLK),.rst(RSTOPMODE),.cen(CEOPMODE),.out(out_OPMODE));
assign PRE_out_addsub1 = (out_OPMODE[6]==1'b0) ? (s1 + s3 ) : (s1 - s3 ) ;
// Addtion / Subtract Process 
assign s6 = (out_OPMODE[4] == 1'b0 ) ? s3 : PRE_out_addsub1;
// Block (B1) 
RegMux #(.WIDTH_INPUT(18),.RSTTYPE(RSTTYPE),.SELECT(B1REG)) B5 (.x(s6),.clk(CLK),.rst(RSTB),.cen(CEB),.out(BCOUT));
// BLOCK (A1)
RegMux #(.WIDTH_INPUT(18),.RSTTYPE(RSTTYPE),.SELECT(A1REG)) B6 (.x(s4),.clk(CLK),.rst(RSTA),.cen(CEA),.out(s7));
// Multiplication Process 
assign out_Multiply = BCOUT * s7 ;
RegMux #(.WIDTH_INPUT(36),.RSTTYPE(RSTTYPE),.SELECT(MREG)) B7 (.x(out_Multiply),.clk(CLK),.rst(RSTM),.cen(CEM),.out(s8)); // Block (M)
genvar i ;
generate
      for(i=0 ; i < 36 ; i=i+1 )begin 
        buf (M[i],s8[i]);               // buffer M 
      end 
endgenerate
// Carry Cascade 
assign M1 = (CARRYINSEL == "OPMODE5") ? out_OPMODE[5] : ((CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0 );
// Block The CY1 
RegMux #(.WIDTH_INPUT(1),.RSTTYPE(RSTTYPE),.SELECT(CARRYINREG)) B9 (.x(M1),.clk(CLK),.rst(RSTCARRYIN),.cen(CECARRYIN),.out(out_carryin));
assign PCOUT = P ;
// MUX X 
always @(*) begin
    case (out_OPMODE[1:0])
        0 :  outx = 48'b0 ;
        1 :  outx = {12'b0 , s8} ;
        2 :  outx = P ;
        3 :  outx = {s1[11:0],s7,BCOUT} ;
        default  : outx = 48'b0 ;
    endcase
end 
// MUX Z
always @(*) begin
    case (out_OPMODE[3:2])
        0 :  outz = 48'b0 ;
        1 :  outz = PCIN ;
        2 :  outz = P ;
        3 :  outz = s5 ;
        default : outz = 48'b0 ;
    endcase
end 
// Last Addition or subtraction Process 
always @ (*) begin
    if (out_OPMODE[7] == 1'b0) begin 
          {carry_out,POST_out_addsub2} = outx + outz + out_carryin ; 
    end 
    else begin 
          {carry_out,POST_out_addsub2} = outz - (outx + out_carryin);
    end 
end
// Final output PREG
RegMux #(.WIDTH_INPUT(48),.RSTTYPE(RSTTYPE),.SELECT(PREG)) B11 (.x(POST_out_addsub2),.clk(CLK),.rst(RSTP),.cen(CEP),.out(P));
// Carryout Cascade (CYO)
RegMux #(.WIDTH_INPUT(1),.RSTTYPE(RSTTYPE),.SELECT(CARRYOUTREG)) B12 (.x(carry_out),.clk(CLK),.rst(RSTCARRYIN),.cen(CECARRYIN),.out(CARRYOUT));
assign CARRYOUTF = CARRYOUT ;  
endmodule 