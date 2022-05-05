/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  level_ram
(
		input [4:0] data_In,
		input [18:0] write_address, read_address,
		input we,Clk,

		output logic [4:0] data_Out
		);

logic [8:0] mem [0:6029];

initial
begin
	 $readmemh("levellayout.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
	
	
end

endmodule
