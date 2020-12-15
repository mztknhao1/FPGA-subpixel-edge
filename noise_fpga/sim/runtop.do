quit -sim
.main	clear

vlib work


vlog	./tb_noise.v
vlog	./altera_lib/*.v
vlog	./../quartus_prj/ipcore_dir/FIFO512.v
vlog	./../quartus_prj/ipcore_dir/div_lpm.v
vlog	./../design/*.v

vsim -voptargs=+acc  work.tb_noise


add		wave	-radix unsigned tb_noise/top_noise_inst/global_cnt
add		wave	-radix unsigned tb_noise/top_noise_inst/ab_start
add		wave    -radix unsigned tb_noise/top_noise_inst/compute_a_inst/*
add		wave	-radix unsigned tb_noise/top_noise_inst/compute_AB_inst/*
#add	wave	-radix unsigned	tb_noise/top_noise_inst/julge_state_inst/*
#add	wave	tb_top_subpixel/top_subpixel_inst/julge_state_inst/*
#add 	wave	tb_top_subpixel/top_subpixel_inst/compute_a_inst/*
#add 	wave	tb_top_subpixel/top_subpixel_inst/compute_a_inst/mydiv2_inst/*
#add 	wave	tb_top_subpixel/top_subpixel_inst/compute_a_inst/mydiv2_inst/div1_inst/*	
#add	wave	-radix unsigned tb_top_subpixel/top_subpixel_inst/*	
#add		wave	-radix unsigned	tb_noise/top_noise_inst/gout
#add		wave	-radix unsigned	tb_noise/top_noise_inst/cnt_window_7x7
#add		wave	-radix unsigned	tb_noise/top_noise_inst/window_7x7_start_r
#add		wave	-radix unsigned	tb_noise/top_noise_inst/gin
#add		wave    -radix unsigned tb_noise/top_noise_inst/data_window_7x7_inst/*



run	2ms
