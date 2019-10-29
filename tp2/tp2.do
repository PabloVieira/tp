onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/cpu/dp/ck
add wave -noupdate /cpu_tb/cpu/dp/rst
add wave -noupdate -color Red /cpu_tb/cpu/dp/i_address
add wave -noupdate -color Red /cpu_tb/cpu/dp/instruction
add wave -noupdate /cpu_tb/cpu/dp/d_address
add wave -noupdate /cpu_tb/cpu/dp/data
add wave -noupdate /cpu_tb/cpu/dp/mdr_int
add wave -noupdate /cpu_tb/cpu/dp/MDR
add wave -noupdate /cpu_tb/cpu/dp/uinsEX.i
add wave -noupdate /cpu_tb/cpu/dp/uinsMEM.i
add wave -noupdate /cpu_tb/cpu/dp/uinsER.i
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(0)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(4)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(8)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(12)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(16)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(20)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(24)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(28)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(32)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(36)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(40)
add wave -noupdate -expand -group Memory /cpu_tb/Data_mem/RAM(44)
add wave -noupdate /cpu_tb/Data_mem/RAM(48)
add wave -noupdate -expand -group Regs -color Gold -label {$at} /cpu_tb/cpu/dp/REGS/reg(1)
add wave -noupdate -expand -group Regs -color Gold -label {$t0} /cpu_tb/cpu/dp/REGS/reg(8)
add wave -noupdate -expand -group Regs -color Gold -label {$t1} /cpu_tb/cpu/dp/REGS/reg(9)
add wave -noupdate -expand -group Regs -color Gold -label {$t2} /cpu_tb/cpu/dp/REGS/reg(10)
add wave -noupdate -expand -group Regs -color Gold -label {$t3} /cpu_tb/cpu/dp/REGS/reg(11)
add wave -noupdate -group ula -color Blue /cpu_tb/cpu/dp/inst_alu/op1
add wave -noupdate -group ula -color Blue /cpu_tb/cpu/dp/inst_alu/op2
add wave -noupdate -group ula -color Blue /cpu_tb/cpu/dp/inst_alu/outalu
add wave -noupdate /cpu_tb/cpu/dp/uinsMEM.ce
add wave -noupdate /cpu_tb/cpu/dp/uinsMEM.rw
add wave -noupdate /cpu_tb/cpu/dp/uinsMEM.bw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1067 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 232
configure wave -valuecolwidth 73
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
WaveRestoreZoom {894 ns} {1111 ns}
