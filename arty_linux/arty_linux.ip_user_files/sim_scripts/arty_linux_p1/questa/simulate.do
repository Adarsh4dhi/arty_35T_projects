onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib arty_linux_p1_opt

do {wave.do}

view wave
view structure
view signals

do {arty_linux_p1.udo}

run -all

quit -force
