onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/cpu/dp/ck
add wave -noupdate /cpu_tb/cpu/dp/rst
add wave -noupdate /cpu_tb/cpu/dp/pc
add wave -noupdate /cpu_tb/cpu/dp/DIEX/uinsDI.i
add wave -noupdate /cpu_tb/cpu/dp/EXMEM/uinsEX.i
add wave -noupdate /cpu_tb/cpu/dp/MEMER/uinsMEM.i
add wave -noupdate -expand /cpu_tb/Data_mem/RAM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2996 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
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
WaveRestoreZoom {4782 ns} {5012 ns}
