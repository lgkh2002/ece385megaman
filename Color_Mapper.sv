//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input onchipmemclk, pixel_clk, blank, flip, frame_clk, Clk,
							  input [3:0] spritestate, metalsprite,
							  input [1:0] pbotuse, screenstate,
							  input [11:0] screenscroll, pbotX[2],
							  input [9:0] DrawX, DrawY, shapeX,shapeY, lemonx[6], metalmanX,metalmanY, moleX[10],
							  input [9:0] lemony[6], bladex[6], bladey[6], pbotY[2], moleY[10], moleuse,
							  input [5:0] lemonuse, bladeuse, megahealth,
							  input [6:0] invinciblecount,
							  input [4:0] metalhealth,
							  input metalmanuse, godmode,
							  output logic[3:0] Red, Green, Blue,
							  output logic[9:0] nearestleft, nearestright,nearesttop,nearestbottom,
							  output logic[1:0] conveyorstate);
    
    logic draw_on, draw_on_metal, draw_on_health, draw_on_metalhealth, draw_on_title, draw_on_enter, draw_on_go, draw_on_god;
	 logic [5:0] draw_on_lemon, draw_on_blade;
	 logic [1:0] draw_on_pbot;
	 logic [9:0] draw_on_mole;
	 logic [2:0] conveyorflip;
	 logic [4:0] enemyflip;
	 logic [9:0] lemxindex [6], bladexindex[6];
	 logic [9:0] lemyindex [6], bladeyindex[6];
	 logic [13:0] spriteaddr;
	 logic [13:0] metaladdr;
	 logic [13:0] enemyaddr;
	 logic [2:0] spritedata;
	 logic [3:0] metaldata;
	 logic [3:0] enemydata;
	 logic [9:0] xindex, metalxindex, molexindex[10], titlexindex, enterxindex, goxindex, godxindex;
	 logic [9:0] yindex, metalyindex, pbotyindex[2], moleyindex[10], titleyindex, enteryindex, goyindex, godyindex;
	 logic [12:0] backaddr;
	 logic [11:0] trueX, pbotxindex[2];
	 logic [4:0] backdata;
	 logic [18:0] leveladdr, textaddr;
	 logic [4:0] leveldata, textdata;
	 logic [4:0] backdatainput;
	 logic [3:0] tilexindex;
	 logic [3:0] tileyindex;
	 logic [2:0] i;
	 logic [1:0] j;
	 logic [3:0] k;
	 logic slowclocksave;
	 logic [4:0] metalhealthsave;
	 
	 logic [11:0] megapalette[7];
	 
	 logic [11:0] enemypalette[10];
	 
	 logic [11:0] palette[23];
	 
	 
	 
	 assign palette[0]=12'h000;
	 assign palette[1]=12'hfea;
	 assign palette[2]=12'h4d4;
	 assign palette[3]=12'hc41;
	 assign palette[4]=12'h6d5;
	 assign palette[5]=12'ha01;
	 assign palette[6]=12'hf93;
	 assign palette[7]=12'he05;
	 assign palette[8]=12'hbbb;
	 assign palette[9]=12'h4c4;
	 assign palette[10]=12'h982;
	 assign palette[11]=12'hc40;
	 assign palette[12]=12'h892;
	 assign palette[13]=12'h5c4;
	 assign palette[14]=12'h6e5;
	 assign palette[15]=12'ha61;
	 assign palette[16]=12'h07e;
	 assign palette[17]=12'h0ed;
	 assign palette[18]=12'hfea;
	 assign palette[19]=12'hc03;
	 assign palette[20]=12'hfc3;
	 assign palette[21]=12'hfff;
	 assign palette[22]=12'h000;
	 
	 assign megapalette[0]=12'h000;	//black
	 assign megapalette[1]=12'h07e;	//dark blue
	 assign megapalette[2]=12'h0ed;	//light blue
	 assign megapalette[3]=12'hfea;	//skin color
	 assign megapalette[4]=12'hfff;	// white
	 assign megapalette[5]=12'h000;  //blank
	 assign megapalette[6]=12'hff3; //lemon yellow
	 
	 assign enemypalette[0]= 12'h000;	//black
	 assign enemypalette[1]= 12'hfff;	//white
	 //assign enemypalette[2]= 12'he05;	//metalman red
	 assign enemypalette[3]= 12'hfc4;	//metalman yellow / pierobot hat top
	 assign enemypalette[4]= 12'hf5a;	//pierobot main
	 assign enemypalette[5]= 12'hbcc;	//pierobot alt/mole light grey
	 assign enemypalette[6]= 12'hfbf;	//pierobot stripes
	 assign enemypalette[7]= 12'hfdb;	//mole shine
	 assign enemypalette[8]= 12'h788;	//mole dark grey / pierobot gear main
	 assign enemypalette[9]= 12'h000;	//blank
	 
	 
	 
	 
	 
	 assign xindex = DrawX-shapeX;
	 assign yindex = DrawY-shapeY;
	 assign metalxindex = DrawX-metalmanX;
	 assign metalyindex = DrawY-metalmanY;
	 assign lemxindex[0]=DrawX-lemonx[0];
	 assign lemxindex[1]=DrawX-lemonx[1];
	 assign lemxindex[2]=DrawX-lemonx[2];
	 assign lemxindex[3]=DrawX-lemonx[3];
	 assign lemxindex[4]=DrawX-lemonx[4];
	 assign lemxindex[5]=DrawX-lemonx[5];
	 assign lemyindex[0]=DrawY-lemony[0];
	 assign lemyindex[1]=DrawY-lemony[1];
	 assign lemyindex[2]=DrawY-lemony[2];
	 assign lemyindex[3]=DrawY-lemony[3];
	 assign lemyindex[4]=DrawY-lemony[4];
	 assign lemyindex[5]=DrawY-lemony[5];
	 
	 assign bladexindex[0]=DrawX-bladex[0];
	 assign bladexindex[1]=DrawX-bladex[1];
	 assign bladexindex[2]=DrawX-bladex[2];
	 assign bladexindex[3]=DrawX-bladex[3];
	 assign bladexindex[4]=DrawX-bladex[4];
	 assign bladexindex[5]=DrawX-bladex[5];
	 assign bladeyindex[0]=DrawY-bladey[0];
	 assign bladeyindex[1]=DrawY-bladey[1];
	 assign bladeyindex[2]=DrawY-bladey[2];
	 assign bladeyindex[3]=DrawY-bladey[3];
	 assign bladeyindex[4]=DrawY-bladey[4];
	 assign bladeyindex[5]=DrawY-bladey[5];
	 
	 assign pbotxindex[0]=trueX-pbotX[0];
	 assign pbotxindex[1]=trueX-pbotX[1];
	 assign pbotyindex[0]=DrawY-pbotY[0];
	 assign pbotyindex[1]=DrawY-pbotY[1];
	 
	 assign molexindex[0]=DrawX-moleX[0];
	 assign molexindex[1]=DrawX-moleX[1];
	 assign molexindex[2]=DrawX-moleX[2];
	 assign molexindex[3]=DrawX-moleX[3];
	 assign molexindex[4]=DrawX-moleX[4];
	 assign molexindex[5]=DrawX-moleX[5];
	 assign molexindex[6]=DrawX-moleX[6];
	 assign molexindex[7]=DrawX-moleX[7];
	 assign molexindex[8]=DrawX-moleX[8];
	 assign molexindex[9]=DrawX-moleX[9];
	 assign moleyindex[0]=DrawY-moleY[0];
	 assign moleyindex[1]=DrawY-moleY[1];
	 assign moleyindex[2]=DrawY-moleY[2];
	 assign moleyindex[3]=DrawY-moleY[3];
	 assign moleyindex[4]=DrawY-moleY[4];
	 assign moleyindex[5]=DrawY-moleY[5];
	 assign moleyindex[6]=DrawY-moleY[6];
	 assign moleyindex[7]=DrawY-moleY[7];
	 assign moleyindex[8]=DrawY-moleY[8];
	 assign moleyindex[9]=DrawY-moleY[9];
	 
	 assign titlexindex=DrawX-170;	//X and Y position of title
	 assign titleyindex=DrawY-100;
	 assign enterxindex=DrawX-220;
	 assign enteryindex=DrawY-250;
	 assign goxindex=DrawX-250;
	 assign goyindex=DrawY-230;
	 assign godxindex=DrawX-195;
	 assign godyindex=DrawY-310;
	 
	 assign trueX=screenscroll+DrawX;
	 assign tilexindex=trueX[3:0];
	 assign tileyindex=DrawY[3:0];
	 assign backaddr = 256*backdatainput+tilexindex+16*tileyindex;
	 assign leveladdr=DrawY[9:4]+30*trueX[11:4];
	 

	 
	 
	 megaman_rom megaman(.addr(spriteaddr), .data(spritedata));
	 metalman_rom  metalman(.addr(metaladdr), .data(metaldata));
	 enemy_rom enemies(.addr(enemyaddr), .data(enemydata));
	 background_ram(.Clk(onchipmemclk), .read_address(backaddr), .data_Out(backdata));
	 level_ram(.Clk(onchipmemclk), .read_address(leveladdr), .data_Out(leveldata));
	 text_ram(.Clk(onchipmemclk), .read_address(textaddr), .data_Out(textdata));
	 
	 always_ff @ (posedge frame_clk)
	 begin
		conveyorflip<=conveyorflip+1;
		enemyflip<=enemyflip+1;
		metalhealthsave<=metalhealth;
		
		if(metalhealthsave!=metalhealth)
				enemypalette[2]=12'h6f6;
		else
				enemypalette[2]=12'he05;
		
	 end
	 
	 always_comb//splite selecting and flipping
	 begin
	 
				if(leveldata==0 || leveldata==1)
					backdatainput=conveyorflip[2];
				else
					backdatainput=leveldata;
					
					
					
					
				if(DrawX>=112 && DrawX<=127 && DrawY>=48 && DrawY<=104)
					draw_on_health=1;
				else
					draw_on_health=0;
					
				if(DrawX>=144 && DrawX<=159 && DrawY>=48 && DrawY<=104 && screenscroll==2576)
					draw_on_metalhealth=1;
				else
					draw_on_metalhealth=0;
				
	 
				
				
				
				if(draw_on_lemon[0])
					begin
						spriteaddr=lemyindex[0]*8+lemxindex[0];
					end
				
				else if(draw_on_lemon[1])
					begin
						spriteaddr=lemyindex[1]*8+lemxindex[1];
					end
				
				else if(draw_on_lemon[2])
					begin
						spriteaddr=lemyindex[2]*8+lemxindex[2];
					end
				
				else if(draw_on_lemon[3])
					begin
						spriteaddr=lemyindex[3]*8+lemxindex[3];
					end
					
				else if(draw_on_lemon[4])
					begin
						spriteaddr=lemyindex[4]*8+lemxindex[4];
					end
					
				else if(draw_on_lemon[5])
					begin
						spriteaddr=lemyindex[5]*8+lemxindex[5];
					end
						
				else
					begin
						if (flip==0)
							spriteaddr=(yindex*31+xindex)+spritestate[3:0]*930+48;
						else
							spriteaddr=(yindex*31+30-xindex)+spritestate[3:0]*930+48;
					end
					
					
					
				
				
				if(draw_on_blade[0])
					begin
						metaladdr=bladeyindex[0]*16+256*conveyorflip[2]+bladexindex[0];
					end
				
				else if(draw_on_blade[1])
					begin
						metaladdr=bladeyindex[1]*16+256*conveyorflip[2]+bladexindex[1];
					end
				
				else if(draw_on_blade[2])
					begin
						metaladdr=bladeyindex[2]*16+256*conveyorflip[2]+bladexindex[2];
					end
				
				else if(draw_on_blade[3])
					begin
						metaladdr=bladeyindex[3]*16+256*conveyorflip[2]+bladexindex[3];
					end
					
				else if(draw_on_blade[4])
					begin
						metaladdr=bladeyindex[4]*16+256*conveyorflip[2]+bladexindex[4];
					end
					
				else if(draw_on_blade[5])
					begin
						metaladdr=bladeyindex[5]*16+256*conveyorflip[2]+bladexindex[5];
					end
						
				else if(shapeX<metalmanX)
					metaladdr=metalxindex+metalyindex*29+metalsprite*1044+512;
				else
					metaladdr=(metalyindex*29+28-metalxindex)+metalsprite*1044+512;
					
					
				if(draw_on_pbot[0])
					enemyaddr=pbotxindex[0]+pbotyindex[0]*32+384+1952*enemyflip[4];
				else if(draw_on_pbot[1])
					enemyaddr=pbotxindex[1]+pbotyindex[1]*32+384+1952*enemyflip[4];
				else if(draw_on_mole[0])
					enemyaddr=23-molexindex[0]+moleyindex[0]*24+192*enemyflip[4];
				else if(draw_on_mole[1])
					enemyaddr=23-molexindex[1]+moleyindex[1]*24+192*enemyflip[4];
				else if(draw_on_mole[2])
					enemyaddr=23-molexindex[2]+moleyindex[2]*24+192*enemyflip[4];
				else if(draw_on_mole[3])
					enemyaddr=23-molexindex[3]+moleyindex[3]*24+192*enemyflip[4];
				else if(draw_on_mole[4])
					enemyaddr=23-molexindex[4]+moleyindex[4]*24+192*enemyflip[4];
				else if(draw_on_mole[5])
					enemyaddr=23-molexindex[5]+moleyindex[5]*24+192*enemyflip[4];
				else if(draw_on_mole[6])
					enemyaddr=23-molexindex[6]+moleyindex[6]*24+192*enemyflip[4];
				else if(draw_on_mole[7])
					enemyaddr=23-molexindex[7]+moleyindex[7]*24+192*enemyflip[4];
				else if(draw_on_mole[8])
					enemyaddr=23-molexindex[8]+moleyindex[8]*24+192*enemyflip[4];
				else
					enemyaddr=23-molexindex[9]+moleyindex[9]*24+192*enemyflip[4];
					
					
				if(draw_on_title&& screenstate==0)
					textaddr=titlexindex+titleyindex*300+12600;
				else if(draw_on_enter &&screenstate==0)
					textaddr=enterxindex+enteryindex*200;
				else if (draw_on_go &&screenstate==1)
					textaddr=goxindex+goyindex*180+9000;
				else if(draw_on_god && screenstate==0 && godmode==1)
					textaddr=godxindex+godyindex*250+4000;
				else
					textaddr=0;
					
					
				
					
	 end
	 

	 
    
    always_comb
    begin:cursor_on
        if (xindex>=0 && xindex <= 30 && yindex>=0 && yindex<=29 && invinciblecount[0]==0)
            draw_on = 1'b1;
        else 
            draw_on = 1'b0;
				
		  for(i=0; i<6 ; i= i+1)
				begin
					
					if (lemxindex[i]>=0 && lemxindex[i] <=7 && lemyindex[i]>=0 && lemyindex[i]<=5 && lemonuse[i])
						draw_on_lemon[i]=1;
					else
						draw_on_lemon[i]=0;
						
					if(bladexindex[i]>=0 && bladexindex[i]<=15 && bladeyindex[i]>=0 && bladeyindex[i]<=16 && bladeuse[i])
						draw_on_blade[i]=1;
					else
						draw_on_blade[i]=0;
				
				end
				
			if(metalxindex>=0 && metalxindex<=28 && metalyindex>=0 && metalyindex<=35 && metalmanuse==1)
				draw_on_metal=1'b1;
			else
				draw_on_metal=1'b0;
				
			for(j=0;j<2;j++)
				begin
					if(pbotxindex[j]>=0 && pbotxindex[j]<=31 && pbotyindex[j]>=0 && pbotyindex[j]<=60 && pbotuse[j])
						draw_on_pbot[j]=1;
					else
						draw_on_pbot[j]=0;
				end
				
				
			for(k=0;k<10;k++)
				begin
					if(molexindex[k]>=0 && molexindex[k]<=23 && moleyindex[k]>=0 && moleyindex[k]<=7 && moleuse[k])
						draw_on_mole[k]=1;
					else
						draw_on_mole[k]=0;
				end
				
			if(titlexindex>=0 && titlexindex<=299 && titleyindex>=0 && titleyindex<=94)
				draw_on_title=1;
			else
				draw_on_title=0;
			
			if(enterxindex>=0 && enterxindex<=199 && enteryindex>=0 && enteryindex<=19)
				draw_on_enter = 1;
			else
				draw_on_enter = 0;
				
			if(goxindex>=0 && goxindex<=179 && goyindex>=0 && goyindex<=19)
				draw_on_go = 1;
			else
				draw_on_go = 0;
				
			if(godxindex>=0 && godxindex<=249 && godyindex>=0 && godyindex<=19)
				draw_on_god = 1;
			else
				draw_on_god = 0;
     end 
       
    always_ff @ (posedge pixel_clk)
    begin:RGB_Display
	 
	 
		if(blank==1)
		begin
		
			if(screenstate==2)
				begin
			
		
					if(draw_on_health)	//drawing healthbar
						begin
							if(DrawY[0]==0|| DrawX==112 || DrawX==127)
								begin
									Red<=4'b0000;
									Green<=4'b0000;
									Blue<=4'b0000;
								end
				
							else
								begin
									if((DrawY<=104-megahealth*2)||megahealth>28)
										begin
											Red<=4'b0000;
											Green<=4'b0000;
											Blue<=4'b0000;
										end
									else
										begin
											Red<=4'b0000;
											Green<=4'b0100;
											Blue<=4'b1101;
										end
					
							end
			
						end
			
					else if(draw_on_metalhealth)	//drawing metalman healthbar
						begin
							if(DrawY[0]==0|| DrawX==144 || DrawX==159)
								begin
									Red<=4'b0000;
									Green<=4'b0000;
									Blue<=4'b0000;
								end
				
							else
								begin
									if(DrawY<=104-metalhealth*2)
										begin
											Red<=4'b0000;
											Green<=4'b0000;
											Blue<=4'b0000;
										end
									else
										begin
											Red<=4'b1111;
											Green<=4'b0000;
											Blue<=4'b0000;
										end
					
								end
			
						end
			
			
			
			
			//drawing megaman and his lemons gets priority after healthbars
			
					else if((draw_on||draw_on_lemon!=6'b0) && (spritedata!=5))	
						begin 
							Red <= megapalette[spritedata][11:8];
							Green <= megapalette[spritedata][7:4];
							Blue <= megapalette[spritedata][3:0];
						end 
			
			//draw metal man
			
					else if((draw_on_metal||draw_on_blade!=6'b0) && (metaldata !=9))
						begin
							Red <= enemypalette[metaldata][11:8];
							Green <= enemypalette[metaldata][7:4];
							Blue <= enemypalette[metaldata][3:0];
						end
			
			
			//draw enemies
					else if(draw_on_pbot!=0 && enemydata!=9)
						begin
							Red <= enemypalette[enemydata][11:8];
							Green <= enemypalette[enemydata][7:4];
							Blue <= enemypalette[enemydata][3:0];
						end
			
					else if(draw_on_mole!=0 && enemydata!=9)
						begin
							Red <= enemypalette[enemydata][11:8];
							Green <= enemypalette[enemydata][7:4];
							Blue <= enemypalette[enemydata][3:0];
						end
			
					else
						begin
							if(leveldata!=24)
								begin
									Red <= palette[backdata][11:8]; 
									Green <= palette[backdata][7:4];
									Blue <= palette[backdata][3:0];
								end
				
							else 
								begin
									Red<=4'b0000;
									Green<=4'b0000;
									Blue<=4'b0000;
								end
				
						end
			
				end
				
			else if(screenstate==0 &&(draw_on_title||draw_on_enter||(draw_on_god&&godmode==1)))
				begin
				
					Red <= palette[textdata][11:8]; 
					Green <= palette[textdata][7:4];
					Blue <= palette[textdata][3:0];
					
				end
				
			else if(screenstate==1 && draw_on_go)
				begin
					Red <= palette[textdata][11:8]; 
					Green <= palette[textdata][7:4];
					Blue <= palette[textdata][3:0];
				end
			
			else
				begin
					Red <= 4'b0;
					Green <= 4'b0;
					Blue <= 4'b0;
				end
					
			
		end
		
		else	//draw black on blanking interval
			begin
				Red <= 4'b0;
				Green <= 4'b0;
				Blue <= 4'b0;
			end
			
		end
			
		
		
		always_ff @ (posedge pixel_clk)   //get slow clock and collision detection
		begin
	
			slowclocksave<=frame_clk;
			
			
			if(frame_clk==1 && slowclocksave==0)
			begin
			
					nearestleft<=0;
					nearestright<=640;
					nearesttop<=5;
					nearestbottom<=480;
					conveyorstate<=2'b00;
			
			end
			
			else
				begin
				
					
					if(blank==1)
					begin
					
						
			
		//find nearest collidable pixels
			//left
						if(DrawY>shapeY+6 && DrawY<shapeY+30 && DrawX<shapeX+15 && leveldata!=24 && leveldata!=14 && DrawX>nearestleft)
							nearestleft<=DrawX;
			//right
						if(DrawY>shapeY+6 && DrawY<shapeY+30 && DrawX>shapeX+15 && leveldata!=24 && leveldata!=14 && DrawX<nearestright)
							nearestright<=DrawX;
			
			//top
						if(DrawX>shapeX+7 && DrawX<shapeX+24 && DrawY<shapeY+15 && leveldata!=24 && leveldata!=14 && DrawY>nearesttop)
							nearesttop<=DrawY;
			
			//bottom
						if(DrawX>shapeX+7 && DrawX<shapeX+24 && DrawY>shapeY+15 && leveldata!=24 && leveldata!=14 && DrawY<nearestbottom)
						begin
						
							nearestbottom<=DrawY;
							
								if(leveldata==0 || leveldata == 15)
									conveyorstate<= 2'b01;
								else if(leveldata==1 || leveldata == 13)
									conveyorstate<= 2'b11;
								else
									conveyorstate<=2'b00;
						end
			
					end
				
				end
		
		end
	 
	 
	
	 
	 
    
endmodule
