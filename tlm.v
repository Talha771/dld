`timescale 1ns / 1ps    
module clk_div(clk,clk_d);
  parameter div_value=1;
  input clk;
  output clk_d;
  reg clk_d;
  reg count;
  initial
    begin 
      clk_d=0;
      count=0;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        count <=0;
      else
        count<=count+1;
    end
  always @(posedge clk)
    begin 
      if (count == div_value)
        clk_d <= ~ clk_d;
    end
endmodule

//--------------------------------------------------------------------------------------------------//
module h_counter(clock,hcount,trig_V);
  input clock;
  output [9:0] hcount;
  reg [9:0] hcount;
  output trig_V;
  reg trig_V;
  initial hcount=0;
  initial trig_V=0;
          always @ (posedge clock)
            begin 
              if (hcount <799)
               begin
                  hcount <= hcount + 1;                
                end  
                  
              else
               begin
                  hcount <=0;
                end
            end   
         always @ (posedge clock)
            begin 
              if (hcount ==799)
               begin
                  trig_V <= trig_V +1;     
                end  
                  
              else
               begin
                  trig_V <=0;
                end
            end   
               
endmodule

// -------------------------------------------------------------------------------------------//
module V_counter(clock,V_signal,Vcount);
  input clock,V_signal;
  output [9:0] Vcount;
  reg [9:0] Vcount;
  initial Vcount=0;
  
          always @ (posedge clock)
            begin 
              if (Vcount <524)
                begin
                  if (V_signal ==1)
                    begin
                      Vcount <= Vcount + 1;                
                    end
                  else
                    begin
                      Vcount<= Vcount;
                    end
                end  
              else
               begin
                  Vcount <=0;
                end
            end   
                    
endmodule

// ----------------------------------------------------------------------------------------//

module VGA_sync (h_count,v_count,h_sync,v_sync,video_on,x_log,y_log);
  input [9:0] h_count,v_count;
  output video_on;
  output h_sync,v_sync;
  output [9:0] x_log,y_log;
  
  //horizontal
  localparam h_border = 10;
  localparam HD = 640;
  localparam HF = 16;
  localparam HB = 48;
  localparam HR = 96;
  
  //vertical
  localparam v_border=10;
  localparam VD = 480;
  localparam VF = 10;
  
  
  localparam VR = 2;
  
  assign h_sync = h_count < (HD + HF) || h_count >= (HD+HF+HR);
  assign v_sync = v_count < (VD + VF) || v_count >= (VD+VF+VR);
  assign video_on = h_count < HD && v_count < VD;
  assign x_log = h_count;
  assign y_log = v_count;
endmodule

//-------------------------------------------------------------------------------------------//


module pixel_gen (clk_d,pixel_x,pixel_y,video_on,red,green,blue,white);
  input clk_d;
  input [9:0] pixel_x;
  input [9:0] pixel_y;
  input video_on;
  output reg [3:0] red=0;
  output reg [3:0]green=0;
  output reg [3:0] blue=0;
  output reg [3:0] white=0;
  localparam h_border = 10;
  localparam v_border=10;
  localparam VB = 33;
  
always @(posedge clk_d)
    begin
      if ((pixel_x ==0)|| (pixel_x ==639)||(pixel_y ==0)||(pixel_y ==639))
       begin
          red <=4'hF;
          green <=4'hF;
          blue <=4'hF;
        end
      else 
        begin 
        if (video_on)
            begin 
            if ((pixel_y<53) ||(pixel_y>427) || (pixel_x<53) || (pixel_x>587))
                begin 
                red<=4'h0;
                green <=4'h0;
                blue <=4'h0;
                end
            else 
                begin 
                red <=4'hF;
                green <=4'hF;
                blue <=4'hF;
                end
          end 
          else 
               begin 
               red <=4'h0;
               green <=4'h0;
               blue <=4'h0;
               end
        end
        end
    endmodule
//--------------------------------------------------------------------------------------------//

module Top_Level_Module(CLK,h_sync,v_sync,red,green,blue);
  input CLK;
  output [3:0] red,green,blue;
  output h_sync,v_sync;
  wire clk_d,trig_V,VD_ON;
  wire [9:0]XL, YL;
  wire [9:0]hcount,Vcount;
  
  clk_div C1(.clk(CLK),.clk_d(clk_d));
  h_counter H1(.clock(clk_d),.hcount(hcount),.trig_V(trig_V));
  V_counter V1(.clock(clk_d),.V_signal(trig_V),.Vcount(Vcount));
  VGA_sync VG1(.h_count(hcount),.v_count(Vcount),.h_sync(h_sync),.v_sync(v_sync),.video_on(VD_ON),.x_log(XL),.y_log(YL));
  pixel_gen P1(.clk_d(clk_d),.pixel_x(XL),.pixel_y(YL),.video_on(VD_ON),.red(red),.green(green),.blue(blue));
endmodule
