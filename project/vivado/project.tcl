set part     "xc7z020clg400-2"
set syn_top  "axis_uart_top"
set sim_top  "axis_uart_top_tb"
set language "Verilog"

set project_dir [file normalize "project/vivado"]
set rtl_dir     [file normalize "rtl"]
set tb_dir      [file normalize "tb"]

create_project -force $syn_top $project_dir -part $part

set_property target_language $language [current_project]
set_property top $syn_top [current_fileset]
set_property top $sim_top [get_filesets sim_1]

add_files -norecurse $rtl_dir/axis_uart_rx.sv
add_files -norecurse $rtl_dir/axis_uart_tx.sv
add_files -norecurse $rtl_dir/axis_uart_top.sv
add_files -norecurse $rtl_dir/axis_fifo.sv
add_files -norecurse $rtl_dir/axis_if.sv

add_files -norecurse $tb_dir/axis_uart_top_if.sv
add_files -norecurse $tb_dir/axis_uart_top_tb.sv
add_files -norecurse $tb_dir/environment.sv

add_files -fileset constrs_1 -norecurse $project_dir/$syn_top.xdc

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

start_gui