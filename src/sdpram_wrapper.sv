// System verilog source file
// Simple dual port RAM (SDPRAM) wrapper
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A wrapper for SDPRAM

`include "bicubic_global_settings.sv"

module sdpram
#(
    parameter MEMORY_SIZE = 4096,
    parameter ADDR_WIDTH_A = 6,
    parameter ADDR_WIDTH_B = 6,
    parameter DATA_WIDTH_A = 32,
    parameter DATA_WIDTH_B = 32,
    parameter CLOCKING_MODE = "independent_clock"
)
(
    // Clock & reset
    input logic a_clk,
    input logic b_clk,
    input logic sreset,

    // Port A
    input logic [ADDR_WIDTH_A - 1:0]a_addr,
    input logic [DATA_WIDTH_A - 1:0]a_data,
    input logic a_wren,

    // Port B
    input logic [ADDR_WIDTH_B - 1:0]b_addr,
    output logic [DATA_WIDTH_B - 1:0]b_data
);

`ifdef USE_XPM_MEMORY
xpm_memory_sdpram 
#(   
    .ADDR_WIDTH_A(ADDR_WIDTH_A),               
    .ADDR_WIDTH_B(ADDR_WIDTH_B),               
    .AUTO_SLEEP_TIME(0),            
    .BYTE_WRITE_WIDTH_A(DATA_WIDTH_A),        
    .CASCADE_HEIGHT(0),             
    .CLOCKING_MODE(CLOCKING_MODE), 
    .ECC_MODE("no_ecc"),            
    .MEMORY_INIT_FILE("none"),      
    .MEMORY_INIT_PARAM("0"),        
    .MEMORY_OPTIMIZATION("true"),   
    .MEMORY_PRIMITIVE("auto"),      
    .MEMORY_SIZE(MEMORY_SIZE),             
    .MESSAGE_CONTROL(0),            
    .READ_DATA_WIDTH_B(DATA_WIDTH_B),         
    .READ_LATENCY_B(1),             
    .READ_RESET_VALUE_B("0"),       
    .RST_MODE_A("SYNC"),            
    .RST_MODE_B("SYNC"),            
    .SIM_ASSERT_CHK(0),             
    .USE_EMBEDDED_CONSTRAINT(0),    
    .USE_MEM_INIT(1),               
    .WAKEUP_TIME("disable_sleep"),  
    .WRITE_DATA_WIDTH_A(DATA_WIDTH_A),        
    .WRITE_MODE_B("no_change")      
) xpm_sdpram_inst
(
    .dbiterrb(),
    .doutb(b_data),
    .sbiterrb(),
    .addra(a_addr),
    .addrb(b_addr),
    .clka(a_clk),
    .clkb(b_clk),
    .dina(a_data),
    .ena(1'b1),
    .enb(1'b1),
    .injectdbiterra(1'b0),
    .injectsbiterra(1'b0),
    .regceb(1'b1),
    .rstb(sreset),
    .sleep(1'b0),
    .wea(a_wren)
);
`else

`define max(a, b) {(a) > (b) ? (a) : (b)}
`define min(a, b) {(a) < (b) ? (a) : (b)}

localparam MAX_WIDTH = `max(DATA_WIDTH_A, DATA_WIDTH_B);
localparam MIN_WIDTH = `min(DATA_WIDTH_A, DATA_WIDTH_B);
localparam RATIO = MAX_WIDTH / MIN_WIDTH;
localparam LOG_RATIO = $clog2(RATIO);
localparam MEMORY_SIZE_BY_WIDTH = MEMORY_SIZE / MIN_WIDTH;

(* ram_style = "block" *) logic [MIN_WIDTH - 1:0] ram [0 : MEMORY_SIZE_BY_WIDTH - 1];
logic [DATA_WIDTH_B - 1:0] read_b;

assign b_data = read_b;

generate
    if (DATA_WIDTH_B > DATA_WIDTH_A) begin
        always_ff @(posedge a_clk) begin
            if (a_wren) begin
                ram[a_addr] <= a_data;
            end
        end

        always_ff @(posedge b_clk) begin
           reg [LOG_RATIO - 1:0]lsbaddr;
           
           for (int i = 0; i < RATIO; i++) begin
                lsbaddr = i;
                if (sreset) begin
                    read_b[(i + 1) * MIN_WIDTH - 1-:MIN_WIDTH] <= 'b0;
                end
                else begin
                    read_b[(i + 1) * MIN_WIDTH - 1-:MIN_WIDTH] <= ram[{b_addr, lsbaddr}];
                end
           end
        end
    end
    else if (DATA_WIDTH_B == DATA_WIDTH_A) begin
        always_ff @(posedge a_clk) begin
            if (a_wren) begin
                ram[a_addr] <= a_data;
            end
        end

        always_ff @(posedge b_clk) begin
            if (sreset) begin
                read_b <= 'b0; 
            end
            else begin
                read_b <= ram[b_addr];
            end
        end
    end
    else begin
        always_ff @(posedge b_clk) begin
            if (sreset) begin
                read_b <= 'b0; 
            end
            else begin
                read_b <= ram[b_addr];
            end
        end

        always_ff @(posedge a_clk) begin
           reg [LOG_RATIO - 1:0] lsbaddr;
           for (int i = 0; i < RATIO; i++) begin
              lsbaddr = i;
              if (a_wren) begin
                  ram[{a_addr, lsbaddr}] <= a_data[(i + 1) * MIN_WIDTH - 1-:MIN_WIDTH];
              end 
           end
        end
    end
endgenerate

`endif

endmodule
