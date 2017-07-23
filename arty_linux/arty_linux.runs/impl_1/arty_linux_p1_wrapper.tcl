proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}


start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  open_checkpoint arty_linux_p1_wrapper_routed.dcp
  set_property webtalk.parent_dir /home/ramprasad/arty_projects_10-7-2017/arty_linux/arty_linux.cache/wt [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
  add_files /home/ramprasad/arty_projects_10-7-2017/arty_linux/arty_linux.srcs/sources_1/bd/arty_linux_p1/ip/arty_linux_p1_microblaze_0_0/data/mb_bootloop_le.elf
  set_property SCOPED_TO_REF arty_linux_p1 [get_files -all /home/ramprasad/arty_projects_10-7-2017/arty_linux/arty_linux.srcs/sources_1/bd/arty_linux_p1/ip/arty_linux_p1_microblaze_0_0/data/mb_bootloop_le.elf]
  set_property SCOPED_TO_CELLS microblaze_0 [get_files -all /home/ramprasad/arty_projects_10-7-2017/arty_linux/arty_linux.srcs/sources_1/bd/arty_linux_p1/ip/arty_linux_p1_microblaze_0_0/data/mb_bootloop_le.elf]
  catch { write_mem_info -force arty_linux_p1_wrapper.mmi }
  catch { write_bmm -force arty_linux_p1_wrapper_bd.bmm }
  write_bitstream -force arty_linux_p1_wrapper.bit 
  catch { write_sysdef -hwdef arty_linux_p1_wrapper.hwdef -bitfile arty_linux_p1_wrapper.bit -meminfo arty_linux_p1_wrapper.mmi -file arty_linux_p1_wrapper.sysdef }
  catch {write_debug_probes -no_partial_ltxfile -quiet -force debug_nets}
  catch {file copy -force debug_nets.ltx arty_linux_p1_wrapper.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

