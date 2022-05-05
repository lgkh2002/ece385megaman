module aimer(input [9:0] charX, charY, metalmanX, metalmanY, output logic [9:0]xvel, yvel);
	
	logic[9:0] xdiff;
	logic [9:0] ydiff;
	logic [9:0] xint;
	logic[9:0] yint;
	logic [9:0] totalspeed;
	
	
	always_comb
		begin
			ydiff=charY-metalmanY;
			if(charX>metalmanX)
				xdiff=charX-metalmanX;
			else
				xdiff=metalmanX-charX;
			
			xint[4:0]=xdiff[9:5];
			yint[4:0]=ydiff[9:5];
			
			totalspeed=xint*xint+yint*yint;
			
			
			if(totalspeed<25)
			begin
				yvel=yint+2;
					if(charX>metalmanX)
						xvel=xint+2;
					else
						xvel=-xint-2;
			end
			
			else
			begin
				yvel=yint;
				if(charX>metalmanX)
					xvel=xint;
				else
					xvel=-xint;
			end
	end
				


endmodule
