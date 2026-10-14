`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// mat_mul.v
//
// Uppsala University
// Yuan Yao <yuan.yao@it.uu.se>
// For the course 1DT109 Accelerating System with Programmable Logic Components
//
//////////////////////////////////////////////////////////////////////////////////


module mat_mul #
    (
        parameter integer DIM_LOG = 1,     /* matrix dimension in log2; e.g. A[8][8] has the DIM of 8, DIM_LOG of 3, and SIZE of 64; change this as desired;
                                              you will need to set this parameter in the testbench and the ARM software in the SDK. */
        parameter integer DIM = 2**DIM_LOG,
        parameter integer SIZE = DIM*DIM,
        parameter integer SIZE_LOG = 2*DIM_LOG,
        parameter integer DATA_WIDTH = 32
    )
    (
        // Clock and Reset shared with the AXI-Lite Slave Port
        input wire  s00_axi_aclk,
        input wire  s00_axi_aresetn,
        
        // AXI-Stream Slave
        output wire  s00_axis_tready,
        input  wire  [DATA_WIDTH-1 : 0] s00_axis_tdata,
        input  wire  s00_axis_tlast,
        input  wire  s00_axis_tvalid,
        
        // AXI-Stream Master
        output wire  m00_axis_tvalid,
        output wire  [DATA_WIDTH-1 : 0] m00_axis_tdata,
        output wire  [(DATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
        output wire  m00_axis_tlast,
        input  wire  m00_axis_tready,
        
        // Matrix-select and Start signals coming from the AXI-Lite Slave Port
        input wire sel,
        input wire start
    );

//TODO
       
endmodule

module bram #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,  
    input wire en,
    input wire rw,
    input wire [SIZE_LOG-1 : 0] addr,
    input wire [DATA_WIDTH-1 : 0] data_in,
    output reg [DATA_WIDTH-1 : 0] data_out
);

//TODO

reg [DATA_WIDTH-1:0] matX [0:SIZE-1];

reg [DATA_WIDTH-1:0] delay_data_input;

// rw = 0 ----- read from BRAM
// rw = 1 ----- write into BRAM 

always @ (posedge s00_axi_aclk) begin
    if(!s00_axi_aresetn);
    //do nothing, unsure about the reset state
    else if(en == 0) begin
        delay_data_input <= data_in; 
        end
    else if(en == 1) begin
        if(rw)
            matX[addr] <= delay_data_input;
        else
            data_out <= matX[addr];
    end
        
end

endmodule

module MAC #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire clear, 
    input wire [DATA_WIDTH-1 : 0] data_A,
    input wire [DATA_WIDTH-1 : 0] data_B,
    output wire [DATA_WIDTH-1 : 0] data_R
);

//TODO

reg[DATA_WIDTH-1 : 0] data_A_reg;
reg[DATA_WIDTH-1 : 0] data_B_reg;
reg[DATA_WIDTH-1 : 0] data_R_reg;

//when the simulation begins
initial begin
       data_R_reg <= 0;
       data_A_reg <= 0;
       data_B_reg <= 0;
 end

//when clear is called we have to reset all the values, else the previous output could be available
always @ (posedge s00_axi_aclk) begin
    if(clear || !s00_axi_aresetn) begin
        data_R_reg <= 0;
        data_A_reg <= 0;
        data_B_reg <= 0;
     end
    
    else begin
    data_A_reg <= data_A;
    data_B_reg <= data_B;
    data_R_reg <= (data_A_reg * data_B_reg)+ data_R_reg;
    end

 end


endmodule

module AGU #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    
    // AXI-Stream Slave
    output reg  s00_axis_tready,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid,
        
    // AXI-Stream Master
    output reg  m00_axis_tvalid,
    output reg  m00_axis_tlast,
    input wire  m00_axis_tready,
    
    input wire sel,
    input wire start,
    
    output reg en_A,
    output reg en_B,
    output reg en_R,
    output reg rw_A,
    output reg rw_B,
    output reg rw_R,
    output reg [SIZE_LOG-1 : 0] addr_A,
    output reg [SIZE_LOG-1 : 0] addr_B,
    output reg [SIZE_LOG-1 : 0] addr_R
);

//TODO

localparam [4:0] S_IDLE    = 5'b00001;
localparam [4:0] S_LOAD_A = 5'b00010;
localparam [4:0] S_LOAD_B    = 5'b00100;
localparam [4:0] S_CALC    = 5'b01000;
localparam [4:0] S_OUTPUT    = 5'b10000;

reg [4:0] current_state;
reg [4:0] next_state;

reg [SIZE_LOG-1 : 0] load_addrA;
reg [SIZE_LOG-1 : 0] load_addrB;
reg [SIZE_LOG-1 : 0] load_addrR;

reg [DATA_WIDTH-1 : 0] temp_data;

 reg loaded;
 reg calculated;
 reg loaded_A;
 reg loaded_B;
 
 //flag to indicate matrix calculation is done and is ready to move from S_CALC to S_OUTPUT state
 reg done;

 reg[DIM_LOG -1: 0] ROW;
 reg[DIM_LOG -1: 0] COL;
 reg[DIM_LOG -1: 0] TEMP;
 


//calculate the next state, depends on the inputs and current state

 always @(*) begin
    
    next_state = current_state;
    
    case(current_state) 
    
    S_IDLE: begin
        if(!s00_axi_aresetn)
            next_state = S_IDLE;
        else if(!sel)
             next_state = S_LOAD_A;
        else if(sel)
             next_state = S_LOAD_B;
        else
            next_state = S_IDLE;
        end
    
    S_LOAD_A: begin
        if(!s00_axi_aresetn || loaded_A)
            next_state = S_IDLE;
        else if(start && loaded)
            next_state = S_CALC;
        else 
            next_state = S_LOAD_A;
            
        end
     
    S_LOAD_B: begin
        if(!s00_axi_aresetn || loaded_B)
            next_state = S_IDLE;
        else if(start && loaded)
            next_state = S_CALC;
        else
            next_state = S_LOAD_B;
        end
        
          
    S_CALC: begin
        if(!s00_axi_aresetn)
            next_state = S_IDLE;
        //else if(m00_axis_tready)
          //  next_state = S_CALC;
        else if(done)
            next_state = S_OUTPUT;
        else
            next_state = S_CALC;
        end  
        
     S_OUTPUT: begin
     if(!s00_axi_aresetn)
            next_state = S_IDLE;
     
     else if(calculated)
        next_state = S_IDLE;
        
     else
        next_state = S_OUTPUT;
     end
     
     default:
           next_state = S_IDLE;
        
  endcase
  
  end
  
  always @ (posedge s00_axi_aclk or negedge s00_axi_aresetn) begin
        if (!s00_axi_aresetn) begin
        current_state <= S_IDLE;
        end else begin
        current_state <= next_state;
        end
       end
       
 //output logic
 
 // OUTPUT block only sees the S_IDLE state change in the next clock cycle, but we want it to be reset whenever reset occurs. 
 // If we put loaded_A in S_IDLE, everytime it eneters IDLE, it resets loaded_A - incorrect behaviour 
 
    always @ (posedge s00_axi_aclk or negedge s00_axi_aresetn) begin
        if (!s00_axi_aresetn) begin
        s00_axis_tready <= 0;
        m00_axis_tvalid <= 0;
        m00_axis_tlast <= 0;
        loaded_A <= 0;
        loaded_B <= 0;
        loaded <= 0;
        calculated <= 0;
        done <= 0;   
        ROW <= 0;
        COL <= 0;
        TEMP <= 0;
        
        end 
        
        else begin
        case(current_state)
            S_IDLE: begin
                s00_axis_tready <= 0;
                m00_axis_tvalid <= 0;
                m00_axis_tlast <= 0;
                en_A <= 0;
                en_B <= 0;
                load_addrA <= 0;
                load_addrB <= 0;
                load_addrR <= 0;
                ROW <= 0;
                COL <= 0;
                TEMP <= 0;
                loaded <= 0;
                calculated <= 0;
                
            end
            
            S_LOAD_A: begin
                s00_axis_tready <= 1;
                rw_A <= 1;

                //cant use a for loop, since all the iterations run in a single simulation time units
                
                //s00_axis_tvalid && s00_axis_tready, sometimes valid = 0 and we would be ready, cant accept data then
                
                if(s00_axis_tvalid && s00_axis_tready) begin //accept the data
                addr_A <= load_addrA;  //one element 
                en_A <= 1;
                    if(s00_axis_tlast) begin 
                        loaded_A <= 1;
                        end  
                    else
                        load_addrA <= load_addrA + 1;        
                end
                
                else
                    en_A <=  0;

		        //if both matrices are loaded
		        if(loaded_A && loaded_B)
		          loaded <= 1;
                
                end
                
            
            S_LOAD_B: begin
                s00_axis_tready <= 1;
                rw_B <= 1;

                //cant use a for loop, since all the iterations run in a single simulation time units
                
                //s00_axis_tvalid && s00_axis_tready, sometimes valid = 0 and we would be ready, cant accept data then
                if(s00_axis_tvalid && s00_axis_tready) begin //accept the data
                addr_B <= load_addrB;
                en_B <= 1;
                    if(s00_axis_tlast) begin 
                        loaded_B <= 1;
                        end  
                    else
                        load_addrB <= load_addrB + 1;        
                end
                
                else
                    en_B <=  0;

		        //if both matrices are loaded
		        if(loaded_A && loaded_B)
		          loaded <= 1;             
                end
                
            S_CALC: begin
                en_A <= 1;
                en_B <= 1;
                en_R <= 1;
    
                rw_A <= 0;
                rw_B <= 0;
                rw_R <= 1;
    
                if (!done) begin
    
            // Generate addresses using the current counter values
                addr_A <= ROW  * DIM + TEMP;
                addr_B <= TEMP * DIM + COL;
                addr_R <= ROW  * DIM + COL;

                if (TEMP < DIM - 1) begin
                    TEMP <= TEMP + 1;
                end 
            // Here TEMP might be DIM - 1
                else begin
                    if (COL < DIM - 1) begin
                        TEMP <= 0;
                        COL  <= COL + 1;
                    end
        
                        // COL REACHED END
                        else begin
                            if (ROW < DIM - 1) begin
                                TEMP <= 0;
                                COL  <= 0;
                                ROW  <= ROW + 1;
                            end
                            else begin
                                done <= 1;
                            end
                            end
                        end
                    end     
        
                        else begin
                            en_A <= 0;
                            en_B <= 0;
                            en_R <= 0;
                            ROW <= 0;
                            COL <= 0;
                        end
                    end     
            
            //cannot do partial results since if you are writing to the same row, reading and writing into the same row cannot be done
            S_OUTPUT: begin
                rw_R <= 0; 
                en_R <= 1;
                
                if(!calculated) begin
                    m00_axis_tvalid <= 1;
                    if(m00_axis_tready)
                        addr_R <= ROW*DIM + TEMP;
                    
                    if(TEMP < DIM - 1)
                        TEMP <= TEMP + 1;
                    
                    else begin
                        
                        if(ROW < DIM - 1) begin
                        TEMP <= 0;
                        ROW <= ROW + 1;
                        end
                        
                        else begin //ROW REACHED THE END DIM-1 
                        m00_axis_tlast <= 1;
                    end
                end
               end
               
               else begin
                calculated <= 1;
                en_R <= 0;
               end
             end
            
        endcase
       end
end
       
endmodule
