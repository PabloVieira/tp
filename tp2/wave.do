onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/cpu/clock
add wave -noupdate /cpu_tb/cpu/reset
add wave -noupdate /cpu_tb/cpu/i_address
add wave -noupdate /cpu_tb/cpu/dp/DIEX/controlSignalsIN.ULAOp
add wave -noupdate /cpu_tb/cpu/dp/EXMEM/controlSignalsIN.ULAOp
add wave -noupdate /cpu_tb/cpu/dp/MEMER/controlSignalsIN.ULAOp
add wave -noupdate /cpu_tb/cpu/dp/incpc
add wave -noupdate /cpu_tb/cpu/dp/pc
add wave -noupdate /cpu_tb/cpu/dp/npc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16136 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {226 ns}
