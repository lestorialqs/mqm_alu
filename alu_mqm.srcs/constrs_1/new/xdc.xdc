## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
 
## Switches (Conectados a 'entry[15:0]')
set_property PACKAGE_PIN V17 [get_ports {entry[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[0]}]
set_property PACKAGE_PIN V16 [get_ports {entry[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[1]}]
set_property PACKAGE_PIN W16 [get_ports {entry[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[2]}]
set_property PACKAGE_PIN W17 [get_ports {entry[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[3]}]
set_property PACKAGE_PIN W15 [get_ports {entry[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[4]}]
set_property PACKAGE_PIN V15 [get_ports {entry[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[5]}]
set_property PACKAGE_PIN W14 [get_ports {entry[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[6]}]
set_property PACKAGE_PIN W13 [get_ports {entry[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[7]}]
set_property PACKAGE_PIN V2 [get_ports {entry[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[8]}]
set_property PACKAGE_PIN T3 [get_ports {entry[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[9]}]
set_property PACKAGE_PIN T2 [get_ports {entry[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[10]}]
set_property PACKAGE_PIN R3 [get_ports {entry[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[11]}]
set_property PACKAGE_PIN W2 [get_ports {entry[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[12]}]
set_property PACKAGE_PIN U1 [get_ports {entry[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[13]}]
set_property PACKAGE_PIN T1 [get_ports {entry[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[14]}]
set_property PACKAGE_PIN R2 [get_ports {entry[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {entry[15]}]
 
## LEDs (Conectados a 'flags[4:0]') <-- MODIFICADO
set_property PACKAGE_PIN U16 [get_ports {flags[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {flags[0]}]
set_property PACKAGE_PIN E19 [get_ports {flags[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {flags[1]}]
set_property PACKAGE_PIN U19 [get_ports {flags[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {flags[2]}]
set_property PACKAGE_PIN V19 [get_ports {flags[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {flags[3]}]
set_property PACKAGE_PIN W18 [get_ports {flags[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {flags[4]}]
	## LED para ver el "latido" del clk_slow
set_property PACKAGE_PIN U15 [get_ports led_clk_slow]
    set_property IOSTANDARD LVCMOS33 [get_ports led_clk_slow]
    
    
    ## LEDs para mostrar el estado de la FSM (LD15 a LD12)
set_property PACKAGE_PIN L1 [get_ports {current_fsm_state[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {current_fsm_state[3]}]
set_property PACKAGE_PIN P1 [get_ports {current_fsm_state[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {current_fsm_state[2]}]
set_property PACKAGE_PIN N3 [get_ports {current_fsm_state[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {current_fsm_state[1]}]
set_property PACKAGE_PIN P3 [get_ports {current_fsm_state[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {current_fsm_state[0]}]
## Líneas de flags[8:5] eliminadas
	
	
## 7 segment display
## Cátodos (seg[6:0] -> catode[6:0])
set_property PACKAGE_PIN W7 [get_ports {catode[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[0]}]
set_property PACKAGE_PIN W6 [get_ports {catode[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[1]}]
set_property PACKAGE_PIN U8 [get_ports {catode[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[2]}]
set_property PACKAGE_PIN V8 [get_ports {catode[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[3]}]
set_property PACKAGE_PIN U5 [get_ports {catode[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[4]}]
set_property PACKAGE_PIN V5 [get_ports {catode[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[5]}]
set_property PACKAGE_PIN U7 [get_ports {catode[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[6]}]

## Punto decimal (dp -> catode[7])
set_property PACKAGE_PIN V7 [get_ports {catode[7]}]							
	set_property IOSTANDARD LVCMOS33 [get_ports {catode[7]}]

## Ánodos (an[3:0] -> anode[3:0])
set_property PACKAGE_PIN U2 [get_ports {anode[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]


## Buttons (Conectado a 'reset')
set_property PACKAGE_PIN U18 [get_ports reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset]