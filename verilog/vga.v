`include "defines.v"

module vga(
    input wire clk,
    input wire rst,
    input wire we,
    input wire[8:0] mem_addr,
    input wire[15:0] mem_data,
    input wire mainclk,
	 
//	 output wire[3:0] debug_cl,
//	 output wire[9:0] debug_x,
//	 output wire[9:0] debug_y,
//	 output wire[8:0] debug_cp,
//	 output wire[9:0] debug_px,
//	 output wire[15:0] debug_elem,
    
    output reg vs,
    output reg hs,
    output reg[2:0] r,
    output reg[2:0] g,
    output reg[2:0] b

);

reg[9:0] vector_x;
reg[9:0] vector_y;
reg[9:0] next_x;
reg[9:0] next_y;
reg hs1;
reg vs1;
reg[2:0] r1;
reg[2:0] g1;
reg[2:0] b1;

// video memory: 15-7 r/g/b 6-0 char
reg[15:0] video_memory[511:0];
reg[8:0] addr_to_write;
reg[15:0] data_to_write;
reg write_enable;

// screen display elements
reg[15:0] elem;
reg[6:0] char;
reg[9:0] char_pixel_pos;
reg[8:0] current_pos;
reg[3:0] current_line;
wire mask;

//assign debug_cl = current_line;
//assign debug_cp = current_pos;
//assign debug_px = char_pixel_pos;
//assign debug_x = vector_x;
//assign debug_y = vector_y;
//assign debug_elem = elem;

// change x and y at time edge
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        vector_x <= 10'd0;
        vector_y <= 10'd0;
        hs <= 1'b0;
        vs <= 1'b0;
        r <= 3'b000;
        g <= 3'b000;
        b <= 3'b000;
    end else begin
        vector_x <= next_x;
        vector_y <= next_y;
        hs <= hs1;
        vs <= vs1;
        r <= r1;
        g <= g1;
        b <= b1;
    end
end

always @(posedge mainclk) begin
    if (write_enable == `Enable) begin
        video_memory[addr_to_write] <= data_to_write;
    end
end

// calc next x and y
always @(*) begin
    if (vector_x == 10'd799) begin
        // next row
        next_x = 0;
        if (vector_y == 10'd524) begin
            // return to start
            next_y = 0;
        end else begin
            next_y = vector_y + 1;
        end
    end else begin
        // next pos
        next_y = vector_y;
        next_x = vector_x + 1;
    end
end

// calc vs1 and hs1, vs and hs will change at next time step
always @(*) begin
    if (vector_x >= 10'd655 && vector_x < 10'd751)
        hs1 = 0;
    else hs1 = 1;
    if (vector_y >= 10'd489 && vector_y < 10'd491)
        vs1 = 0;
    else vs1 = 1;
end

// calc current showing line number
always @(*) begin
    if (vector_y >= 6 && vector_y < 42)
        current_line = 0;
    else if (vector_y >= 42 && vector_y < 78)
        current_line = 1;
    else if (vector_y >= 78 && vector_y < 114)
        current_line = 2;
    else if (vector_y >= 114 && vector_y < 150)
        current_line = 3;
    else if (vector_y >= 150 && vector_y < 186)
        current_line = 4;
    else if (vector_y >= 186 && vector_y < 222)
        current_line = 5;
    else if (vector_y >= 222 && vector_y < 258)
        current_line = 6;
    else if (vector_y >= 258 && vector_y < 294)
        current_line = 7;
    else if (vector_y >= 294 && vector_y < 330)
        current_line = 8;
    else if (vector_y >= 330 && vector_y < 366)
        current_line = 9;
    else if (vector_y >= 366 && vector_y < 402)
        current_line = 10;
    else if (vector_y >= 402 && vector_y < 438)
        current_line = 11;
    else if (vector_y >= 438 && vector_y < 480)
        current_line = 12;
    else current_line = 0;
end

// calculation temp vars
wire[9:0] temp1 = current_line * 6'd39;
wire[9:0] temp2 = vector_x[3:0] * 6'd36;
wire[9:0] temp3 = current_line * 6'd36;

// get correct video memory pos
always @(*) begin
    if (vector_x < 624 && vector_y > 5 && vector_y < 480) begin
        // character width is 16, so x >> 4 should exactly be index of row 
        current_pos = temp1 + vector_x[9:4];
    end else begin
        current_pos = 9'b111111111;
    end
end

// visit video memory
always @(current_pos, write_enable, data_to_write, addr_to_write) begin
    if (write_enable == `Enable && current_pos == addr_to_write)
        elem = data_to_write;
    else
        elem = video_memory[current_pos];
end

// get current rom visiting params
always @(*) begin
    char = elem[6:0];
    char_pixel_pos = temp2 + (vector_y[9:0] - temp3) - 6;
end

// get output rgb
always @(*) begin
    r1 = 3'b000;
    g1 = 3'b000;
    b1 = 3'b000;
    if (mask == 1) begin
        r1 = elem[15:13];
        g1 = elem[12:10];
        b1 = elem[9:7];
    end
    if (vs1 != 1 || hs1 != 1) begin
        r1 = 3'b000;
        g1 = 3'b000;
        b1 = 3'b000;
    end
end

// write video memory
always @(*) begin
    write_enable = we;
    addr_to_write = mem_addr;
    data_to_write = mem_data;
end

vga_rom vga_rom0(
    .ch(char), .pos(char_pixel_pos), .mask(mask)
);

endmodule // vga