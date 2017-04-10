function [valve] = initialize_valve_data_structures_radial_bead_slip(N, attached, leaflet_only, optimization, repulsive_potential, decreasing_tension)
% 
% Initializes data structures for full solve.  
% 
% Parameters are declared here.
% Should be a script, but want to return in the structures 
% 
% Input: 
%     N   Size parameter used throughout 
% 


% Main data structure with everything 
valve.N = N; 
valve.max_it                = 4000; 
valve.max_it_continuation   = 2000; 

% Parameters for quick exit on line search 
valve.max_consecutive_fails = 5;  
valve.max_total_fails       = 40; 

if exist('attached', 'var') 
    valve.attached = attached; 
else 
    valve.attached = false; 
end 

% Valve skeleton parameters 
valve.r = 1.606587877768772; 

% original, supposedly diastolic but we have been using as systolic 
% valve.left_papillary  = [ -0.972055648767080; -1.611924550017006; -2.990100960298683]; 
% valve.right_papillary = [ -1.542417595752084;  1.611924550017006; -3.611254871967348]; 

valve.left_papillary  = [ -0.972055648767080; -1.611924550017006; -2.990100960298683] + [0; 0; -0.0];
valve.right_papillary = [ -1.542417595752084;  1.611924550017006; -3.611254871967348] + [0; 0; -0.0]; 


% Places papillary attachments in linear interpolant between single point tips 

split_papillary = true; 

% vector pointing along line from left to right papillary 
l_to_r_papillary = (valve.right_papillary - valve.left_papillary); 
l_to_r_papillary = l_to_r_papillary / norm(l_to_r_papillary);


valve.papillary_radius = 0.25; 
 
valve.left_papillary_center  = valve.left_papillary  + valve.papillary_radius * l_to_r_papillary; 
valve.right_papillary_center = valve.right_papillary - valve.papillary_radius * l_to_r_papillary; 


diastolic_increment = [0; 0; 0.0]; 
valve.left_papillary_diastolic  = valve.left_papillary  + diastolic_increment; 
valve.right_papillary_diastolic = valve.right_papillary + diastolic_increment; 


valve.split_papillary = split_papillary; 
valve.radial_and_circumferential = true; 
valve.bead_slip = true; 
valve.leaflet_only = leaflet_only; 
valve.optimization = optimization; 
valve.repulsive_potential = repulsive_potential; 
valve.repulsive_power     = 1; 

if repulsive_potential
 
    % good total value (not including mesh parameters) at N=32
    repulsive_coeff_32 = 0.002238985441466; 
    
    repulsive_coeff_base = repulsive_coeff_32 * 32^2; 
    
    % scale so that when multiplied by above value gives the correct value 
    % valve.repulsive_coeff = repulsive_coeff_32 * 32^2; 
    
    valve.c_repulsive_circumferential = 2.0 * repulsive_coeff_base; 
    valve.c_repulsive_radial          = 6.0 * repulsive_coeff_base; 
    valve.c_repulsive_chordae         = 1.0 * repulsive_coeff_base; 
else 
    valve.repulsive_coeff  = 0.0; 
end 


valve.decreasing_tension = decreasing_tension; 

if decreasing_tension
 
    % good total value (not including mesh parameters) at N=32
    dec_tension_coeff_32 = 0.002238985441466; 
    
    dec_tension_coeff_base = dec_tension_coeff_32 * 32^2; 
    
    valve.c_dec_tension_circumferential = 1.0 * dec_tension_coeff_base; 
    valve.c_dec_tension_radial          = 2.0 * dec_tension_coeff_base; 
    valve.c_dec_tension_chordae         = 1.0 * dec_tension_coeff_base; 
else 
    valve.dec_tension  = 0.0; 
end 


valve.diff_eqns = @difference_equations_bead_slip; 
valve.jacobian  = @build_jacobian_bead_slip;
        

% general solve parameters

% name 
valve.base_name = sprintf('mitral_tree_%d', N); 

% box width 
valve.L = 2.5; 

MMHG_TO_CGS      = 1333.22368;
valve.p_physical = 110 * MMHG_TO_CGS; 

% Pressure on each leaflet is constant, negative since normal is outward facing 
p_0 = -valve.p_physical; 

% scaling for target points 
valve.target_multiplier = 40/128; 

% number of lagrangian tracers in each dimension 
% arranged in a mesh near the origin
% z direction is doubled 
valve.n_lagrangian_tracers = 0; 

% Uses configuration of X 
valve.X_config_is_reference = true; 

% places this many exact copies of the leaflet downward in z 
% spring constants are all reduced by num_copies 
% spacing is always half a mesh width 
valve.num_copies = 1; 

% Uses collagen spring function implemented in IBAMR 
% Spring constants are different here 
valve.collagen_constitutive = true; 

% no reflections in this version 
reflect_x = false; 

% Radial and circumferential fibers 
% Or diagonally oriented fibers 
% Always true in this version 
radial_and_circumferential = true; 

% physical units create a scalar multiple of the old 
% this multiple is large number, so we want to scale the old tolerance accordingly 
% 8.3326e-04 is a good number here
valve.tol_global = 1e-3;






% Base constants, individual pieces are tuned relative to these values

% pressure / tension coefficient ratio
% this tension coefficient is the maximum tension that a fiber can support
valve.pressure_tension_ratio = 0.075; % 0.11 * 0.975; 


% base constant for tensions, derived quantity 
valve.tension_base = valve.p_physical / valve.pressure_tension_ratio; 


% Tension coefficients in two directions 
alpha    = 1.0 * valve.tension_base;  % circumferential 
beta     = 1.0 * valve.tension_base;  % radial

% Leaf tensions are all modified 
valve.leaf_tension_base = 0.5 * valve.tension_base; 

% Base total root tension 
% The value 0.5905 works well on each tree when using separate solves and two leaflets 
% Controls constant tension at the root of the tree 
valve.root_tension_base = 0.6 * valve.tension_base; 


% places this many periodic rings above 
n_rings_periodic = max(1,N/16); 













% Anterior leaflet parameters 
total_angle_anterior = 5*pi/6; 
angles_anterior = [-total_angle_anterior/2, total_angle_anterior/2]; 

tension_base_anterior = valve.tension_base; 

N_anterior = N/2; 

n_trees_anterior = 4; 

k_0_1_anterior = 1.2 * valve.leaf_tension_base / n_trees_anterior; 

% vector version 
k_0_1_anterior = k_0_1_anterior * [1; 1; 1; 1]; 



k_root_anterior = 0.9 * valve.root_tension_base / n_trees_anterior; 

k_root_anterior = k_root_anterior * [1; 1; 1; 1]; 

% controls initial guess tree vertex placement 
tree_frac = 0.5;


papillary_anterior = zeros(3,n_trees_anterior); 

n_points = n_trees_anterior/2; 

right_papillary_range = 1:(n_trees_anterior/2); 
left_papillary_range  = right_papillary_range + (n_trees_anterior/2);

papillary_anterior(:,right_papillary_range) = get_papillary_coords(valve.left_papillary_center,  valve.papillary_radius, n_points,  0*pi/4,    pi/4); 
papillary_anterior(:,left_papillary_range)  = get_papillary_coords(valve.right_papillary_center, valve.papillary_radius, n_points,   -pi/4, -0*pi/4); 

n_leaves_anterior  = N_anterior/n_trees_anterior * ones(n_trees_anterior, 1); 
tree_direction_anterior = [-1; -1; 1; 1];






total_angle_posterior = 7*pi/6; 
angles_posterior = [pi - total_angle_posterior/2, pi + total_angle_posterior/2]; 

N_posterior = N/2; 

n_trees_posterior = 8; 

k_0_1_posterior  = 0.2 * valve.leaf_tension_base; 
k_0_1_posterior  = k_0_1_posterior * ones(n_trees_posterior,1); 


k_root_posterior = 0.8 * valve.root_tension_base / n_trees_posterior; 

k_root_posterior = k_root_posterior * ones(n_trees_posterior,1); 



papillary_posterior = zeros(3,n_trees_posterior); 

n_points = n_trees_posterior/2; 

right_papillary_range = 1:(n_trees_posterior/2); 
left_papillary_range  = right_papillary_range + (n_trees_posterior/2); 

papillary_posterior(:,right_papillary_range) = get_papillary_coords(valve.right_papillary_center, valve.papillary_radius, n_points,    pi/4,  5*pi/4); 
papillary_posterior(:,left_papillary_range)  = get_papillary_coords(valve.left_papillary_center,  valve.papillary_radius, n_points, -5*pi/4,   -pi/4);

% this is generally pretty good 
n_leaves_posterior = N_posterior/n_trees_posterior * ones(n_trees_posterior, 1); 
tree_direction_posterior = [-1; 1; -1; -1; 1; 1; -1; 1]; 



% fix this 
left_papillary_posterior_diastolic  = valve.left_papillary_diastolic; 
right_papillary_posterior_diastolic = valve.right_papillary_diastolic;



% concatenate all relevant arrays
angles             = [-pi/2; 2*pi - pi/2]; 
papillary          = [papillary_anterior, papillary_posterior]; 
n_leaves           = [n_leaves_anterior; n_leaves_posterior];
tree_direction     = [tree_direction_anterior; tree_direction_posterior]; 
k_0_1              = [k_0_1_anterior; k_0_1_posterior]; 
k_root             = [k_root_anterior; k_root_posterior]; 
ring_to_ring_range = 0; 





valve.leaflet = initialize_leaflet_bead_slip(N,                      ...
                                reflect_x,                           ... 
                                angles,                              ...    
                                valve.r,                             ... 
                                papillary,                           ... 
                                n_leaves,                            ...
                                tree_direction,                      ...
                                left_papillary_posterior_diastolic,  ...
                                right_papillary_posterior_diastolic, ...
                                radial_and_circumferential,          ...  
                                alpha,                               ... 
                                beta,                                ... 
                                p_0,                                 ... 
                                k_0_1,                               ... 
                                k_root,                              ... 
                                tree_frac,                           ... 
                                leaflet_only,                        ...
                                ring_to_ring_range,                  ...
                                n_rings_periodic,                    ...
                                valve);  

    
    

valve_plot(valve); 

disp('Done with initialize.'); 


