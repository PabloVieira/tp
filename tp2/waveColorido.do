onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -label Clock /cpu_tb/cpu/dp/ck
add wave -noupdate -color Red -label Reset /cpu_tb/cpu/dp/rst
add wave -noupdate -color {Violet Red} -label PC /cpu_tb/cpu/dp/pc
add wave -noupdate -color {Lime Green} -label DIEX.i /cpu_tb/cpu/dp/DIEX/controlSignalsIN.i
add wave -noupdate -color {Cadet Blue} -label EXMEM.i /cpu_tb/cpu/dp/EXMEM/controlSignalsIN.i
add wave -noupdate -color {Dark Orchid} -label MEMER.i /cpu_tb/cpu/dp/MEMER/controlSignalsIN.i
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
WaveRestoreZoom {0 ns} {416 ns}
