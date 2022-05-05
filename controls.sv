module controls (input frame_clk, reset, onchipmemclk,
					  input [7:0] keycode0, keycode1, keycode2, keycode3,
					  input [9:0] nearesttop, nearestbottom, nearestleft, nearestright,
					  input [1:0] conveyorstate,
					  
					  output logic [11:0] screenscroll, pbotX[2],
					  output logic [9:0] charX, lemonx[6], metalmanX, bladex[6], moleX[10], pbotY[2],
					  output logic [1:0] pbotuse,
					  output logic [9:0]charY,lemony[6], metalmanY, bladey[6], moleY[10], moleuse,
					  output logic [3:0] spritestate, metalsprite,
					  output logic [5:0] lemonuse, bladeuse,
					  output logic [6:0] invinciblecount,
					  output logic [5:0] megahealth,
					  output logic [4:0] metalhealth,
					  output logic flip, metalmanuse, godmode,
					  output logic [1:0] screenstate);
					  
//screenstate == 0 -> title
//screenstate == 1 - > death
//screenstate == else -> gameplay


					  
// variables for character / boss movement
logic [9:0] xnext, metalxnext;
logic [9:0] xcheck;
logic[9:0] ynext, metalynext;
logic[8:0] returncount;
logic[5:0] megahealthnext,metalhealthnext;
logic[5:0] metalhit;
logic[9:0] yvel, metalyvel;
logic[1:0] yvelcount, metalyvelcount;
logic[1:0] yvelcountnext, metalyvelcountnext;
logic[9:0] yvelnext, metalyvelnext;
logic[1:0] horizontal;
logic metaljumpleft, metaljumpright, metaljumpheight;
logic hitbymetalman;
logic[10:0] hitbymole;
logic [1:0] hitbypbot;
logic[6:0] metaljumpcount, metaljumpcountnext;
logic[2:0] godstate;
logic[2:0] godstatenext;

//sprite control
logic[3:0] state;
logic[4:0] nextstate;
logic[1:0] runsprite, metalrun;
logic[4:0] runcount, metalruncount;
logic[3:0] guncount;
logic nextflip;
logic [3:0] spritestatenext;


//lemon movement
logic[9:0] lemonxnext[6];
logic[9:0] lemonynext[6];
logic[5:0] lemonusenext;
logic [5:0] lemondir;
logic [5:0] lemondirnext;
logic [2:0] nextlemonup;
logic [3:0] lemoncount;

//blade movement
logic [9:0] bladexnext[6], bladeynext[6], aimerx, aimery;
logic [5:0] bladeusenext;
logic [9:0] bladexvel[6], bladeyvel[6], bladexvelnext[6], bladeyvelnext[6];
logic [2:0] nextbladeup;
logic [5:0] bladehit;

//enemy movement
logic [9:0] pbotynext[2];
logic [9:0]	pbotyvel;
logic [9:0] pbotyvelnext;
logic [1:0] pbotyvelcount, pbotusenext;
logic [1:0] pbotyvelcountnext;
logic [9:0] moleusenext;
logic [5:0] molecount;
logic [3:0] nextmoleup;
logic [9:0] molexnext [10];
logic [9:0] moleynext [10];
logic [5:0] molehit[10];
logic [5:0] pbothit[2];

//others
logic [11:0] screenscrollnext;
logic [11:0] screenscrollcheck;
logic [7:0] controlcount;
logic oscillator, typewait;
logic [6:0] invinciblecountnext;
logic [1:0] screenstatenext;
logic [3:0] typecount,typecountnext;

//conveyors and collision
logic [11:0] groundmove;
logic rightcollide, leftcollide, conveyorcounter;

//for loop vars
logic[2:0] i;
logic[2:0] j;
logic[2:0] k;
logic[2:0] m;
logic[3:0] n;
logic[3:0] p;
logic[3:0] q;
logic[1:0] r;
logic[3:0] s;
logic[1:0] t;

//state[0] 0=>grounded	1=>airborne
//state[1] 0=>still 1=>moving horizontally
//state[2] 0=>normal 1=> hurt
//state[3] 0=>rest	1=>gun out


//screenscroll max = x780
//teleport when charX>=614
//boss scroll = 2576
//moles appear for screenscroll between 640 and 1860

assign pbotX[0]=272;
assign pbotX[1]=1728;


aimer blades(.xvel(aimerx), .yvel(aimery), .*);


always_ff @ (posedge reset or posedge frame_clk or posedge returncount[8]) //update positions, mega man state, run cycle, gun position
begin

if(reset || returncount[8])
begin

charX<=98;
charY<=1;
invinciblecount<=0;
yvel<=0;
metalmanX<=454;
metalmanY<=900;
megahealth<=28;
metalhealth<=28;
pbotY[0]<=291;
pbotY[1]<=195;
pbotuse=2'b11;
moleuse=10'b0;
state<=4'b0000;
flip<=0;
screenscroll<=0;
screenstate<=0;
returncount<=0;
godstate<=0;
end


else
begin

//megaman position update
charX<=xcheck;
if(screenstate==2)
	begin
		charY<=ynext;
		yvel<=yvelnext;
	end
yvelcount<=yvelcountnext;
screenscroll<=screenscrollcheck;
screenstate<=screenstatenext;

//metalman position update
metalmanX<=metalxnext;
metalmanY<=metalynext;
metaljumpcount<=metaljumpcountnext;
metalyvel<=metalyvelnext;
metalyvelcount<=metalyvelcountnext;

//healthbar updates
metalhealth<=metalhealthnext;
megahealth<=megahealthnext;

//enemy updates
pbotY[0]<=pbotynext[0];
pbotY[1]<=pbotynext[1];
pbotyvel<=pbotyvelnext;
pbotyvelcount<=pbotyvelcountnext;
moleuse<=moleusenext;
pbotuse<=pbotusenext;

if(molecount<36)
	molecount<=molecount+1;
else
	molecount<=0;

for(n=0;n<10;n++)
begin
	moleX[n]<=molexnext[n];
	moleY[n]<=moleynext[n];
end

typecount<=typecountnext;
godstate<=godstatenext;
state<=nextstate;
spritestate<=spritestatenext;

invinciblecount<=invinciblecountnext;

flip<=nextflip;

//projectile updates
lemonuse<=lemonusenext;
lemondir<=lemondirnext;
bladeuse<=bladeusenext;
oscillator=~oscillator;

for(j=0; j<6; j++)
begin
	lemonx[j]<=lemonxnext[j];
	lemony[j]<=lemonynext[j];
	bladex[j]<=bladexnext[j];
	bladey[j]<=bladeynext[j];
	bladexvel[j]<=bladexvelnext[j];
	bladeyvel[j]<=bladeyvelnext[j];
end


if(state==4'b0010 || state==4'b1010)
	runcount<=runcount+1;

else
	runcount<=0;
	
if(metalmanY==332)
	metalruncount<=metalruncount+1;
	
else
	metalruncount<=0;
	
	
if(keycode3==8'h1d||keycode2==8'h1d||keycode1==8'h1d||keycode0==8'h1d)
		guncount<=15;
	
else if(guncount>0)
	guncount<=guncount-1;
	
	
if((keycode3==8'h1d||keycode2==8'h1d||keycode1==8'h1d||keycode0==8'h1d)&&nextlemonup!=6&&lemoncount==0)
		lemoncount<=15;
		
else if(lemoncount>0)
	lemoncount<=lemoncount-1;
	
if(charX>=614)
	controlcount<=180;
else if(controlcount>0)
	controlcount<=controlcount-1;
	
if(screenstate==1||(screenstate==2 &&screenscroll==2576 && metalhealth==0))
	returncount<=returncount+1;
else
	returncount<=0;
	

	
end
	
	
end



always_comb//screen control
begin
	if(screenstate==0 && (keycode0==8'h28||keycode1==8'h28||keycode2==8'h28||keycode3==8'h28))
		screenstatenext=2;
	else if(screenstate==2 && ((megahealth==0 || megahealth>28)||(charY>=450 && charY<600)))
		screenstatenext=1;
	else
		screenstatenext=screenstate;
end


always_comb //godmode
begin
	if(screenstate==0 && typecount==0)
	begin
		if(godstate==0)
			begin
				if(keycode0==8'h08)
					begin
						godstatenext=1;
						typewait=1;
					end
				else if (keycode0!=8'h08 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=0;
					end
			end
		
		else if(godstate==1)
			begin
				if(keycode0==8'h06)
					begin
						godstatenext=2;
						typewait=1;
					end
				else if (keycode0!=8'h06 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=1;
					end
			end
			
		else if(godstate==2)
			begin
				if(keycode0==8'h08)
					begin
						godstatenext=3;
						typewait=1;
					end
				else if (keycode0!=8'h08 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=0;
					end
			end
			
		else if(godstate==3)
			begin
				if(keycode0==8'h20)
					begin
						godstatenext=4;
						typewait=1;
					end
				else if (keycode0!=8'h20 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=0;
					end
			end
			
		else if(godstate==4)
			begin
				if(keycode0==8'h25)
					begin
						godstatenext=5;
						typewait=1;
					end
				else if (keycode0!=8'h25 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=0;
					end
			end
			
		else if(godstate==5)
			begin
				if(keycode0==8'h22)
					begin
						typewait=1;
						godstatenext=6;
					end
				else if (keycode0!=8'h22 && keycode0!=0)
					begin
						godstatenext=0;
						typewait=1;
					end
				else
					begin
						godstatenext=godstate;
						typewait=0;
					end
			end
			
		else
			begin
			godstatenext=godstate;
			typewait=0;
			end
	end
	
	else
		begin
			godstatenext=godstate;
			typewait=0;
		end
		
		
	if(godstate==6)
		godmode=1;
	else
		godmode=0;
		
	if(typewait==1)
		typecountnext=8;
	else if(typecountnext!=0)
		typecountnext=typecount-1;
	else
		typecountnext=0;
			


end



always_comb //sprite controller
begin
		
	if(runcount<10)
		runsprite=0;
		
	else if((runcount>=10&&runcount<16)||(runcount>=26))
		runsprite=1;
	
	else if(runcount>=16&&runcount<26)
		runsprite=2;
	
	else
		runsprite=0;
		
		
		
		
	if(metalruncount<10)
		metalrun=0;
		
	else if((metalruncount>=10&&metalruncount<16)||(metalruncount>=26))
		metalrun=1;
	
	else if(metalruncount>=16&&metalruncount<26)
		metalrun=2;
	
	else
		metalrun=0;	
		
		
		
		
	if(guncount>0 && controlcount ==0)
		nextstate[3]=1;
	else
		nextstate[3]=0;
		
		


	case(state)
		4'b0000:
			spritestatenext=0;
		4'b0001, 4'b0011:
			spritestatenext=1;
		4'b0010:
			spritestatenext=runsprite+2;
		4'b1000:
			spritestatenext=5;
		4'b1001, 4'b1011:
			spritestatenext=6;
		4'b1010:
			spritestatenext=runsprite+7;
		default:
			spritestatenext=10;
			
	endcase

end





always_comb //metal man sprite control
begin

	if(screenscroll==2576 && metalhealth!=0)
		metalmanuse=1;
	else
		metalmanuse=0;
		
		
		
	if(controlcount<120&&controlcount>100)
		metalsprite=1;
	else if(controlcount<=100 && controlcount!=0)
		metalsprite=2;
	else if(metalmanY==332)
		if(controlcount==0)
			metalsprite=3+metalrun;
		else
			metalsprite=0;
			
	else if(((((metaljumpcount>=43&&metaljumpcount<51)||(metaljumpcount>=63 && metaljumpcount<71)||
				(metaljumpcount>=83 && metaljumpcount<91))&&metaljumpheight==0)||
				(((metaljumpcount>=35&&metaljumpcount<43)||(metaljumpcount>=55 && metaljumpcount<63))&&metaljumpheight==1))&& 
				(metaljumpleft==0 && metaljumpright==0 && controlcount==0))
		metalsprite=7;
		
	else if(metaljumpcount>=36 && metaljumpcount<44 && (metaljumpleft==1 || metaljumpright==1) && controlcount==0)
		metalsprite=7;
		
	else if(((((metaljumpcount>=51&&metaljumpcount<61)||(metaljumpcount>=71&&metaljumpcount<81)||(metaljumpcount>=91&&metaljumpcount<101))&&metaljumpheight==0)||
				(((metaljumpcount>=43&&metaljumpcount<53)||(metaljumpcount>=63&&metaljumpcount<73))&&metaljumpheight==1))&&
			  	  (metaljumpleft==0 && metaljumpright==0 && controlcount==0))
		metalsprite=8;
	
	else if(metaljumpcount>=44 && metaljumpcount<54 && (metaljumpleft==1 || metaljumpright==1) && controlcount==0)
		metalsprite=8;
	
	else
		metalsprite=6;

end









always_comb		//left/right collision
begin

	
	
	if(charX+3<nearestleft || screenstate<2)
		begin
			leftcollide=1;
		end
		
	else	
			leftcollide=0;
			
	if(charX+27>nearestright || screenstate<2)
		begin
			rightcollide=1;
		end
		
	else
			rightcollide=0;
		
	
	
end


///////////////////////////////////////////////////////////////////////////////
				//MEGA MAN CONTROLS
///////////////////////////////////////////////////////////////////////////////


always_comb //horizontal movement and screenscrolling
begin

if(conveyorstate==2'b01 && state[0]==0)
	groundmove=12'b00000000001;
else if(conveyorstate==2'b11 && state[0]==0)
	groundmove=12'b111111111111;
else
	groundmove=0;



if(keycode3==8'h50 || keycode3==8'h4f)
	begin
	horizontal[1]=1;
	horizontal[0]=keycode3[0];
	end
	
else if(keycode2==8'h50 || keycode2==8'h4f)
	begin
	horizontal[1]=1;
	horizontal[0]=keycode2[0];
	end
	
else if(keycode1==8'h50 || keycode1==8'h4f)
	begin
	horizontal[1]=1;
	horizontal[0]=keycode1[0];
	end
	
else if(keycode0==8'h50 || keycode0==8'h4f)
	begin
	horizontal[1]=1;
	horizontal[0]=keycode0[0];
	end

else
	horizontal=2'b0;
	


		
		
case (horizontal)


					2'b10 : begin //left
								if(leftcollide==0 && controlcount==0 && invinciblecount<60)
								begin
									if(charX>150 || screenscroll==0 || screenscroll>= 4094 || screenscroll==2576)
										begin
										
												xnext=charX-2+groundmove;
												screenscrollnext=screenscroll;

										end
										
									else
										begin
											screenscrollnext=screenscroll-2+groundmove;
											xnext=charX;
										end
								end
								
								else
									begin
										xnext=charX;
										screenscrollnext=screenscroll;
									end
									
								if(controlcount==0)
									begin
										nextstate[1]=1;
										nextflip=1;
									end
									
								else
									begin
										nextstate[1]=0;
										nextflip=0;
									end
									
							  end
					        
					2'b11 : begin //right
								
								if(rightcollide==0 && controlcount==0 && invinciblecount<60)
								begin
								
									if(charX<300 || (screenscroll>=1920 && screenscroll<1925) || screenscroll==2576)
										begin
											xnext=charX+2+groundmove;
											screenscrollnext=screenscroll;
										end
									else
										begin
											screenscrollnext=screenscroll+2+groundmove;
											xnext=charX;
										end
								end
								else
									begin
										xnext=charX;
										screenscrollnext=screenscroll;
									end
								
								if(controlcount==0)
									nextstate[1]=1;
								else
									nextstate[1]=0;
									
							  nextflip=0;
							  end
							  

							  
					default: 
							begin
								if(((groundmove==1 && charX>=300 && rightcollide==0) || (groundmove==12'b111111111111 && charX<=150 && leftcollide ==0)) && screenscroll!=2576 && controlcount==0)
									begin
										xnext=charX;
										screenscrollnext=screenscroll+groundmove;
									end
								
								else if(((groundmove==1 && rightcollide==0) || (groundmove== 12'b111111111111 &&leftcollide==0)) && controlcount==0)
									begin
										xnext=charX+groundmove;
										screenscrollnext=screenscroll;

									end
								else
								begin
									xnext=charX;
									screenscrollnext=screenscroll;
								end
								nextstate[1]=0;
								nextflip=flip;
							end
						
endcase	

		
		if(charX<614)
		begin
		
			if(xnext>=1022)
				xcheck=0;
			else
				xcheck=xnext;
			
			
			if(screenscrollnext>=4094)
				screenscrollcheck=0;
			else if(screenscrollnext>1920 && screenscrollnext<1925)
				screenscrollcheck=1920;
			else
				screenscrollcheck=screenscrollnext;
		end
		
		else
			begin
			screenscrollcheck=2576;
			xcheck=150;
			end

	
end





always_comb	//jumping and gravity
begin

// if grounded
if(state[0]==0)
	begin
	
	if(((keycode3==8'h1b||keycode2==8'h1b||keycode1==8'h1b||keycode0==8'h1b)&&invinciblecount<60&&controlcount==0) || nearestbottom>charY+30)
		begin
		
		nextstate[0]=1;
		if(keycode3==8'h1b||keycode2==8'h1b||keycode1==8'h1b||keycode0==8'h1b)
			yvelnext=-5;
		else 
			yvelnext = 0;
		
		end
		
	else
		begin	
		
		nextstate[0]=0;
		yvelnext=0;
		
		end
		
	ynext=charY+yvel;
	yvelcountnext=0;
		
	end
	
//if airborne
else
	begin
	
		ynext=charY+yvel;
		
		if(ynext+31>nearestbottom && ynext+31<600)
		begin
			yvelnext=0;
			ynext=nearestbottom-30;
			nextstate[0]=0;
			yvelcountnext=0;
		end
		
		else if(ynext-1<nearesttop && yvel>10'b1000000000)
		begin
			yvelnext=0;
			nextstate[0]=1;
			ynext=nearesttop+1;
			yvelcountnext=0;
		end
		
		else
		begin
		
		//if(yvel<3)
		if(yvelcount==3)
			yvelnext=yvel+1;
		else
			yvelnext=yvel;
		
		yvelcountnext=yvelcount+1;
		
		ynext=yvel+charY;
		nextstate[0]=1;
			
		end
	
	end
	

end






always_comb //shooting
begin
		if(lemonuse[0]==0)
			nextlemonup=0;
		else if(lemonuse[1]==0)
			nextlemonup=1;
		else if(lemonuse[2]==0)
			nextlemonup=2;
		else if(lemonuse[3]==0)
			nextlemonup=3;
		else if(lemonuse[4]==0)
			nextlemonup=4;
		else if(lemonuse[5]==0)
			nextlemonup=5;
		else
			nextlemonup=6;	
			
			
		for(i=0; i<6; i++)
			begin
			
				if(lemonuse[i])
					begin
						if(lemondir[i]==0)
							lemonxnext[i]=lemonx[i]+5;
						else
							lemonxnext[i]=lemonx[i]-5;
				
						lemonynext[i]=lemony[i];
						lemondirnext[i]=lemondir[i];
				
					end
			
				else	
					begin
						lemonxnext[i]=700;
						lemonynext[i]=0;
						lemondirnext[i]=0;
					end
				
				if(lemonuse[i] && metalmanuse && lemonx[i]+7>=metalmanX && lemonx[i]<metalmanX+28 && lemony[i]+5>metalmanY+10 && lemony[i]<metalmanY+35)
					begin
						lemonusenext[i]=0;
						metalhit[i]=1;
					end
					
				else if(lemonxnext[i]>680 && lemonxnext[i]<1016)
					begin
						lemonusenext[i]=0;
						metalhit[i]=0;
					end
					
				else
					begin
						lemonusenext[i]=lemonuse[i];
						metalhit[i]=0;
					end
					
				for(q=0;q<10;q++)
					begin
						if(lemonuse[i] && moleuse[q] && lemonx[i]+7>=moleX[q] && lemonx[i]<moleX[q]+23 && lemony[i]+5>moleY[q] && lemony[i]<moleY[q]+7)
							begin
								lemonusenext[i]=0;
								molehit[q][i]=1;
							end
						else
							begin
								if(lemonusenext[i]==1)
									lemonusenext[i]=1;
								else
									lemonusenext[i]=0;
									
								molehit[q][i]=0;
							end
					end
					
				for(r=0;r<2;r++)
					begin
						if(lemonuse[i] && pbotuse[r] && lemonx[i]+7>=pbotX[r]-screenscroll+9 && lemonx[i]<pbotX[r]-screenscroll+27 && lemony[i]+5>pbotY[r]+5 && lemony[i]<pbotY[r]+28) 
							begin
								lemonusenext[i]=0;
								pbothit[r][i]=1;
							end
						else
							begin
								if(lemonusenext[i]==1)
									lemonusenext[i]=1;
								else	
									lemonusenext[i]=0;
								
								pbothit[r][i]=0;
							end
					end
			end
			
			
			if(metalhit!=0)
				metalhealthnext=metalhealth-2;
			else
				metalhealthnext=metalhealth;
			
			
			
			if((keycode3==8'h1d||keycode2==8'h1d||keycode1==8'h1d||keycode0==8'h1d)&&nextlemonup!=6&&lemoncount==0&&controlcount==0&&invinciblecount<60&& screenstate>1)
					begin
						lemonusenext[nextlemonup]=1;
						lemondirnext[nextlemonup]=flip;
						lemonynext[nextlemonup]=charY+15;
						if(flip)
							lemonxnext[nextlemonup]=charX-8;
						else
							lemonxnext[nextlemonup]=charX+31;
						
					end
			else
				begin
					lemonusenext[nextlemonup]=0;
					lemondirnext[nextlemonup]=0;
					lemonxnext[nextlemonup]=700;
					lemonynext[nextlemonup]=0;
				end
			
end



always_comb		//Damage to megaman
begin

		if(charX+26>=metalmanX+4 && charX+4<=metalmanX+26 && charY+30>=metalmanY+12 && charY+8<=metalmanY+36 && metalmanuse==1 && invinciblecount==0 && godmode==0)
			begin
				hitbymetalman=1;
			end
		else
			begin
				hitbymetalman=0;
			end
			
		
		for(m=0;m<6;m++)
			begin
				if(charX+26>=bladex[m] && charX+4<=bladex[m]+15 && charY+30>=bladey[m] && charY+8<=bladey[m]+15 && bladeuse[m]==1 && invinciblecount==0 && godmode==0)
					bladehit[m]=1;
				else
					bladehit[m]=0;
			end
			
		for(s=0;s<10;s++)
			begin
				if(charX+26>=moleX[s] && charX+4<=moleX[s]+24 && charY+30>=moleY[s] && charY<=moleY[s]+7 && moleuse[s] && invinciblecount==0 && godmode==0)
					hitbymole[s]=1;
				else
					hitbymole[s]=0;
			end
			
		for(t=0;t<2;t++)
			begin
				if(charX+26>=pbotX[t]-screenscroll+6 && charX+4<=pbotX[t]-screenscroll+27 && charY<=pbotY[t]+61 && charY+30>=pbotY[t]+5 && pbotuse[t] && invinciblecount==0 && godmode==0)
					hitbypbot[t]=1;
				else
					hitbypbot[t]=0;
			end
		
		if(bladehit!=0)
			begin
				megahealthnext=megahealth-4;
				invinciblecountnext=120;
			end
		else if(hitbymetalman)
			begin
				megahealthnext=megahealth-6;
				invinciblecountnext=120;
			end
		else if(hitbymole!=0)
			begin
				megahealthnext=megahealth-2;
				invinciblecountnext=120;
			end
		else if(hitbypbot!=0)
			begin
				megahealthnext=megahealth-3;
				invinciblecountnext=120;
			end
		else
			begin
				megahealthnext=megahealth;
				if(invinciblecount!=0)
					invinciblecountnext=invinciblecount-1;
				else
					invinciblecountnext=0;
			end
		
			
		if(invinciblecount<60)
			nextstate[2]=0;
		else
			nextstate[2]=1;


end





///////////////////////////////////////////////////////////////////////
							//METAL MAN CONTROLS
///////////////////////////////////////////////////////////////////////


//small jump frame data

//Throw 1
//start: frame 35
//throw: frame 43

//Throw 2
//start: frame 55
//throw: frame 63



//big jump frame data

//Throw 1
//start: frame 43
//throw: frame 51

//Throw 2
//start: frame 63
//throw: frame 71

//Throw 3
//start: frame 83
//throw: frame 91



always_latch	//metal man movement
begin
		
		//VERTICAL MOVEMENT
	if(screenscroll==2576)
		begin

			if(metalmanY<332 || metalmanY>480 || metalyvel!=0)	//airborne
				begin
	
					metalynext=metalmanY+metalyvel+1;
	

					if(metalynext<332 || metalynext>480)
						begin
							if(((metaljumpheight==0 &&(metaljumpcount==51 || metaljumpcount==71 || metaljumpcount==91))||
								 (metaljumpheight==1 && (metaljumpcount==43 || metaljumpcount==63))) && 
								 (metaljumpleft==0 && metaljumpright==0 && controlcount==0))
								metalyvelnext=0;
							else if(metalyvelcount==3)
								metalyvelnext=metalyvel+1;
							else
								metalyvelnext=metalyvel;
								
							metalyvelcountnext=metalyvelcount+1;
							metalynext=metalmanY+metalyvel;
							
						end
					else
						begin
							metalyvelnext=0;
							metalynext=332;
							metalyvelcountnext=0;
						end
					
				metaljumpcountnext=metaljumpcount+1;	
					
				end
	
	
			else //grounded
				begin
					if((charX+30>384 && metalmanX>320)||(charX<256 && metalmanX<320)||
						((keycode3==8'h1d||keycode2==8'h1d||keycode1==8'h1d||keycode0==8'h1d)
						&&nextlemonup!=6&&lemoncount==0&&controlcount==0&&invinciblecount<60))
							begin
								
								if(charX+30>384 && metalmanX>320)
									begin
										metaljumpleft=1;
										metaljumpright=0;
										metalyvelnext=-9;
									end
								else if(charX<256 && metalmanX<320)
									begin
										metaljumpright=1;
										metaljumpleft=0;
										metalyvelnext=-9;
									end
								else
									begin
										metaljumpleft=0;
										metaljumpright=0;
										if(oscillator)
											begin
											metalyvelnext=-10;
											metaljumpheight=1;
											end
										else
											begin
											metalyvelnext=-8;
											metaljumpheight=0;
											end
										
									end
							end
						
					else
						begin
							metalyvelnext=0;
							metaljumpleft=0;
							metaljumpright=0;
						end
						
					metalynext=metalmanY+metalyvel;
					metalyvelcountnext=0;
					metaljumpcountnext=0;
				end
		
		
	
	//HORIZONTAL MOVEMENT
			if(metaljumpleft==1)
				metalxnext=metalmanX-4;
			else if(metaljumpright==1)
				metalxnext=metalmanX+4;
			else
				metalxnext=metalmanX;

		end

	else
		begin
			metalxnext=metalmanX;
			metalyvelnext=metalyvel;
			metalynext=metalmanY+metalyvel;
			metalyvelcountnext=0;
			metaljumpcountnext=0;
			metaljumpleft=0;
			metaljumpright=0;
		end
		
		


end


always_comb //blades
begin

		if(bladeuse[0]==0)
			nextbladeup=0;
		else if(bladeuse[1]==0)
			nextbladeup=1;
		else if(bladeuse[2]==0)
			nextbladeup=2;
		else if(bladeuse[3]==0)
			nextbladeup=3;
		else if(bladeuse[4]==0)
			nextbladeup=4;
		else if(bladeuse[5]==0)
			nextbladeup=5;
		else
			nextbladeup=6;
		
		
			
		for(k=0;k<6;k++)
			begin
				if(bladeuse[k]==1)
					begin
						bladexnext[k]=bladex[k]+bladexvel[k];
						bladeynext[k]=bladey[k]+bladeyvel[k];
						bladexvelnext[k]=bladexvel[k];
						bladeyvelnext[k]=bladeyvel[k];
					end
				else
					begin
						bladexnext[k]=700;
						bladeynext[k]=0;
						bladexvelnext[k]=0;
						bladeyvelnext[k]=0;
					end
					
				if((bladex[k]>680 && bladex[k] < 1008) || (bladey[k]>480 && bladey[k]<1008))
					bladeusenext[k]=0;
				else
					bladeusenext[k]=bladeuse[k];
			
			
			
			
			
			if(((((metaljumpcount==51||metaljumpcount==71||metaljumpcount==91)&&metaljumpheight==0)||
				((metaljumpcount==43||metaljumpcount==63)&&metaljumpheight==1))&&
			  	  (metaljumpleft==0 && metaljumpright==0 && controlcount==0 && metalhealth!=0))||
				  (metaljumpcount==44 && (metaljumpleft==1 || metaljumpright==1) && controlcount==0 && metalhealth!=0))
				begin
					bladeusenext[nextbladeup]=1;
					bladeynext[nextbladeup]=metalmanY+25;
					bladexvelnext[nextbladeup]=aimerx;
					bladeyvelnext[nextbladeup]=aimery;
					if(metalmanX<charX)
						begin
							bladexnext[nextbladeup]=metalmanX+25;
						end
					else
						begin
							bladexnext[nextbladeup]=metalxnext-15;
						end
				end
			
			else
				begin
					bladeusenext[nextbladeup]=0;
					bladeynext[nextbladeup]=0;
					bladexnext[nextbladeup]=700;
					bladexvelnext[nextbladeup]=0;
					bladeyvelnext[nextbladeup]=0;
				end
			
			
		end

end


always_comb //enemy movement
begin
	
	//PBOTS
	
	pbotynext[0]=pbotY[0]+pbotyvel;

	if(pbotynext[0]>=291)
		begin
			pbotynext[0]=291;
			pbotynext[1]=195;
			pbotyvelnext=-5;
			pbotyvelcountnext=0;
		end
	else
		begin
			if(pbotyvelcount==3)
				pbotyvelnext=pbotyvel+1;
			else
				pbotyvelnext=pbotyvel;
				
			pbotynext[0]=pbotY[0]+pbotyvel;
			pbotynext[1]=pbotY[1]+pbotyvel;
			pbotyvelcountnext=pbotyvelcount+1;
		end
		
	if(pbothit[0]!=0)
		pbotusenext[0]=0;
	else
		pbotusenext[0]=pbotuse[0];
	if(pbothit[1]!=0)
		pbotusenext[1]=0;
	else
		pbotusenext[1]=pbotuse[1];
	
		
	//MOLES
	
	if(moleuse[0]==0)
		nextmoleup=0;
	else if(moleuse[1]==0)
		nextmoleup=1;
	else if(moleuse[2]==0)
		nextmoleup=2;
	else if(moleuse[3]==0)
		nextmoleup=3;
	else if(moleuse[4]==0)
		nextmoleup=4;
	else if(moleuse[5]==0)
		nextmoleup=5;
	else if(moleuse[6]==0)
		nextmoleup=6;
	else if(moleuse[7]==0)
		nextmoleup=7;
	else if(moleuse[8]==0)
		nextmoleup=8;
	else if(moleuse[9]==0)
		nextmoleup=9;
	else
		nextmoleup=10;
	
	
	for(p=0;p<10;p++)
	begin
	
		if(moleuse[p]==1)
			begin
				molexnext[p]=moleX[p]-2+screenscroll-screenscrollnext;
				moleynext[p]=moleY[p];
			end
		else
			begin
				molexnext[p]=700;
				moleynext[p]=0;
			end
			
		if(moleX[p]<980 && moleX[p]>680)
			moleusenext[p]=0;
		else if(molehit[p]!=0)
			moleusenext[p]=0;
		else
			moleusenext[p]=moleuse[p];
	
	
	//moles appear for screenscroll between 640 and 1860

	
		if(screenscroll>=640 && screenscroll<=1860 && nextmoleup!=11 && molecount==2)
			begin
				moleusenext[nextmoleup]=1;
				molexnext[nextmoleup]=680;
				moleynext[nextmoleup]=charY;
			end
		else
			begin
				moleusenext[nextmoleup]=0;
				molexnext[nextmoleup]=700;
				moleynext[nextmoleup]=0;
			end
				

	end

end




endmodule
