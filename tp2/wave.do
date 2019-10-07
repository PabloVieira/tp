onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/cpu/dp/BIDI/ck
add wave -noupdate /cpu_tb/cpu/dp/DIEX/controlSignalsIN.i
add wave -noupdate /cpu_tb/cpu/dp/EXMEM/controlSignalsIN.i
add wave -noupdate /cpu_tb/cpu/dp/MEMER/controlSignalsIN.i
add wave -noupdate /cpu_tb/cpu/dp/dtpc
add wave -noupdate /cpu_tb/cpu/dp/pc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3358 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2514 ns} {3394 ns}
