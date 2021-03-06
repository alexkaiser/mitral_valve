

data_file = '/Users/alex/Dropbox/stanford/research_stanford/aortic_working_2019/aortic_65595790_384_4495be5_circ_pt15_rad_pt54_2mm_radial_4mm_circ_circ_model_basic_updated_output_semifinal/aortic_65595790_384_4495be5_circ_pt15_rad_pt54_2mm_radial_4mm_circ_circ_model_basic_updated_output_semifinal_bc_data.mat'; 

outdir = '/Users/alex/data_to_remove/aortic_65595790_384_4495be5_circ_pt15_rad_pt54_2mm_radial_4mm_circ_circ_model_basic_updated_output_semifinal/movie_pressure_and_flow/'

dt = 0.001665; 
nframes = 1442; 
stride = 333; 
% scaling was working, but for some reason an arbitrary factor of .48 = 2250/1080 larger 
image_size = 4 * [690, 1080] * (1080/2250); 
basename = 'aortic_65595790_384_4495be5_flow'; 

plot_aortic_movie_files(data_file, stride, nframes, outdir, basename, image_size)





