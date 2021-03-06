import os 

def update_bounding_box(file_name, box = None):
	'''
	Looks for a line of the form 
	    %%BoundingBox:    xmin ymin xmax ymax
	in file_name

	Adjusts current box to take the largest available box 
	'''

	file = open(file_name,'r')
	found = False 
	for line in file:
		if line.startswith('%%BoundingBox:'): 
			found = True 
			split = line.split()

			xmin = int(split[1])
			ymin = int(split[2])
			xmax = int(split[3])
			ymax = int(split[4])
			break 

	xwidth  = xmax - xmin
	xcenter = xmin + xwidth/2
	ywidth  = ymax - ymin
	ycenter = ymin + ywidth/2
	print 'File ', file_name 
	print 'box = ', box
	print 'xwidth, ywidth = ', xwidth, ', ', ywidth
	print 'xcenter, ycenter = ', xcenter, ', ', ycenter

	file.close()

	assert found 

	if box is None:
		box_new = [xmin, ymin, xmax, ymax]
	else:
		xmin = min(xmin, box[0]) 
		ymin = min(ymin, box[1]) 
		xmax = max(xmax, box[2]) 
		ymax = max(ymax, box[3]) 
		box_new = [xmin, ymin, xmax, ymax]

	return box_new


def crop(file_name, box, file_name_new=None):
	'''
	Manually crop eps to specified 
	'''

	if file_name_new is None:
		if file_name.endswith('_uncropped.eps'):
			base_name = file_name.split('_uncropped.eps')[0]
			file_name_new = base_name + '.eps'
		else:
			assert False  

	'''
	if zero_box:
		'set box to zero outside'
		box[2] -= box[0]
		box[3] -= box[1]
		box[0]  = 0
		box[1]  = 0
	''' 

	file = open(file_name, 'r')
	new_file = open(file_name_new, 'w')
	
	for line in file:
		if line.startswith('%%BoundingBox:'): 
			new_file.write('%%BoundingBox:' + str(box[0]) + ' ' + str(box[1]) + ' ' + str(box[2]) + ' ' + str(box[3]) + '\n')
		else:
			new_file.write(line)

	file.close()
	new_file.close()



if __name__ == '__main__':

	do_one_family = False
	if do_one_family:

		one_family_plots = ['anterior_tension_plot_circ_uncropped.eps',
							'anterior_tension_plot_radial_uncropped.eps',
							'posterior_tension_plot_circ_uncropped.eps',
							'posterior_tension_plot_radial_uncropped.eps']

		box = None
		for plot in one_family_plots:
			box = update_bounding_box(plot, box)

		for plot in one_family_plots:
			crop(plot, box)

	'''
	one_family_plots_export = ['anterior_tension_plot_circ_export_uncropped.eps',
							   'posterior_tension_plot_circ_export_uncropped.eps',
                               'anterior_tension_plot_radial_export_uncropped.eps',	
                               'posterior_tension_plot_radial_export_uncropped.eps']

	box = None
	for plot in one_family_plots_export:
		box = update_bounding_box(plot, box)

	for plot in one_family_plots_export:
		crop(plot, box)
	'''

	do_two_family_surf_test = False
	if do_two_family_surf_test:
		surf_plots = ['COARSE_total_tension_fig_posterior_uncropped.eps',
					  'COARSE_total_tension_fig_anterior_uncropped.eps']

		box = None
		for plot in surf_plots:
			box = update_bounding_box(plot, box)

		for plot in surf_plots:
			crop(plot, box)

		print 'Final box = ', box


	do_two_family_surf = False
	if do_two_family_surf:

		# box = [162, 66, 457, 390]

		surf_plots = ['total_tension_fig_posterior_uncropped.eps',
					  'total_tension_fig_anterior_uncropped.eps']

		box = None
		for plot in surf_plots:
			box = update_bounding_box(plot, box)

		for plot in surf_plots:
			crop(plot, box)

	do_tree_detail = False
	if do_tree_detail:
		# 266   239   797   732 
		
		# good values on left tree 
		# box = [370, 239, 770, 530] 

		# for right tree
		# box = [340, 300, 590, 500] 

		# something funny with monitors/screen resolution and 
		box = [360, 180, 580, 340] 

		tree_detail = ['tree_detail_tension_fig_anterior_uncropped.eps']

		for plot in tree_detail:
			crop(plot, box)

	do_free_edge_detail = False
	if do_free_edge_detail:
		# orig box 
		# 109    85   471   349
		box = [170, 130, 415, 230]	

		ant_circ = 'anterior_tension_plot_circ_uncropped.eps'
		new_name = 'anterior_tension_free_edge_detail.eps'

		crop(ant_circ, box, new_name)


	do_one_family_surf = True
	if do_one_family_surf:

		one_family_plots = ['anterior_tension_plot_circ_surf_uncropped.eps',
							'anterior_tension_plot_radial_surf_uncropped.eps',
							'posterior_tension_plot_circ_surf_uncropped.eps',
							'posterior_tension_plot_radial_surf_uncropped.eps']

		box = None
		for plot in one_family_plots:
			box = update_bounding_box(plot, box)

		for plot in one_family_plots:
			crop(plot, box)


	do_free_edge_detail_surf = True
	if do_free_edge_detail_surf:
		# orig box 
		# 109    85   471   349
		box = [170, 130, 415, 230]	

		ant_circ = 'anterior_tension_plot_circ_surf_uncropped.eps'
		new_name = 'anterior_tension_free_edge_surf_detail.eps'

		crop(ant_circ, box, new_name)

