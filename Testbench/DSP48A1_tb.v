module DSP48A1_tb ();
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
reg [17:0] A , B , D ;
reg [47:0] C ;
reg CLK , CARRYIN ;
reg  [7:0] OPMODE ;
reg [17:0] BCIN ;
reg RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE ;
reg CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE ;
reg [47:0] PCIN ;
wire  [17:0] BCOUT ;
wire  [47:0] PCOUT , P ;
wire  [35:0] M ;
wire  CARRYOUT,CARRYOUTF ;
integer  i ;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// instantiate the Module Under Test (DSP48A1) 
DSP48A1  #(.A0REG(A0REG),.A1REG(A1REG),.B0REG(B0REG),.B1REG(B1REG),.CREG(CREG),.DREG(DREG),.MREG(MREG),.PREG(PREG),
.CARRYINREG(CARRYINREG),.CARRYOUTREG(CARRYOUTREG),.OPMODEREG(OPMODEREG),.CARRYINSEL(CARRYINSEL),.B_INPUT(B_INPUT),.RSTTYPE(RSTTYPE))
DUT (.A(A),.B(B),.D(D),.C(C),.CLK(CLK),.CARRYIN(CARRYIN),.OPMODE(OPMODE),.BCIN(BCIN),.RSTA(RSTA),.RSTB(RSTB),.RSTM(RSTM),
.RSTP(RSTP),.RSTC(RSTC),.RSTD(RSTD),.RSTCARRYIN(RSTCARRYIN),.RSTOPMODE(RSTOPMODE),.CEA(CEA),.CEB(CEB),.CEM(CEM)
,.CEP(CEP),.CEC(CEC),.CED(CED),.CECARRYIN(CECARRYIN),.CEOPMODE(CEOPMODE),.PCIN(PCIN),.BCOUT(BCOUT),.PCOUT(PCOUT),.P(P),.M(M)
,.CARRYOUT(CARRYOUT),.CARRYOUTF(CARRYOUTF));
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// generate the clock signal 
initial begin
    CLK = 0 ;
    forever begin
     #1    CLK = ~ CLK ;
    end
end    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
initial begin 
BCIN = 18'b1 ;
OPMODE = 8'b00011101 ; // Test the case (D+B)*A+C
{CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE} = 8'b11111111; // Test clock enable 
{RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE} = 8'b00000000 ; 
CARRYIN = 0 ;
for(i=0 ; i<20  ; i=i+1) begin 
        A = $urandom_range(1,10) ; 
        B = $urandom_range(1,10) ; 
        C = $urandom_range(1,10) ; 
        D = $urandom_range(1,10) ; 
        repeat(4) @(negedge CLK ) ;
        if(P != ((D+B)*A+C) && BCOUT != (D+B) && M != ((D+B)*A) && PCOUT != ((D+B)*A+C) && CARRYOUT != 0 && CARRYOUTF != 0 ) begin 
            $display("Error : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
            $stop ;
        end 
        else begin 
            $display("Success : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
        end 
end 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
{RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE} = 8'b11111111 ; // Test the signal reset 
for(i=0 ; i<20  ; i=i+1) begin 
        A = $urandom_range(1,10) ; 
        B = $urandom_range(1,10) ; 
        C = $urandom_range(1,10) ; 
        D = $urandom_range(1,10) ; 
repeat(4) @(negedge CLK) ;
if(P != 0 && BCOUT != 0 && M != 0  && PCOUT != 0 && CARRYOUT != 0 && CARRYOUTF != 0 ) begin 
            $display("Error : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
            $stop ;
        end
else begin 
            $display("Success : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
        end 
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
{CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE} = 8'b11111111;  
{RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE} = 8'b10000000 ; // Test Reset A >>> P = C 
 for(i=0 ; i<20  ; i=i+1) begin 
        A = $urandom_range(1,10) ; 
        B = $urandom_range(1,10) ; 
        C = $urandom_range(1,10) ; 
        D = $urandom_range(1,10) ; 
repeat(4) @(negedge CLK) ;
if(P != C ) begin 
            $display("Error : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
            $stop ;
        end
else begin 
            $display("Success : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF ) ;
        end 
end         
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
OPMODE = 8'b01010101 ; // Test the case P >>> (D-B)*A + PCIN 
{RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE} = 8'b00000000 ; 
for(i=0 ; i< 30  ; i=i+1) begin 
        A = $urandom_range(10,1) ; 
        B = $urandom_range(10,1) ; 
        C = $urandom_range(10,1) ; 
        D = $urandom_range(20,11) ; 
        PCIN = $urandom_range(10,1) ;
repeat(4) @(negedge CLK) ;
if(P != ((D-B)*A + PCIN) ) begin 
            $display("Error : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d , PCIN=%0d"
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF,PCIN ) ;
            $stop ;
        end
else begin 
            $display("Success : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d , PCIN=%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF,PCIN ) ;
        end 
end 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
OPMODE = 8'b01110101 ; // Test the case P >>> (D-B)*A + PCIN + CIN
{RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE} = 8'b00000000 ; 
for(i=0 ; i< 30  ; i=i+1) begin 
        A = $urandom_range(10,1) ; 
        B = $urandom_range(10,1) ; 
        C = $urandom_range(10,1) ; 
        D = $urandom_range(20,11) ; 
        PCIN = $urandom_range(10,1) ;
repeat(4) @(negedge CLK) ;
if(P != ((D-B)*A + PCIN + OPMODE[5]) ) begin 
            $display("Error : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d , PCIN=%0d , CIN=%0d"
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF,PCIN,OPMODE[5]) ;
            $stop ;
        end
else begin 
            $display("Success : A=%0d , B=%0d , C=%0d , D=%0d , BCOUT =%0d , M =%0d , P=%0d , PCOT=%0d , CARRYOUT=%0d , CARRYOUTF =%0d , PCIN=%0d , CIN=%0d "
             ,A,B,C,D,BCOUT , M , P ,PCOUT ,CARRYOUT,CARRYOUTF,PCIN ,OPMODE[5]) ;
        end 
end 
$stop ;
end 
endmodule 