function [valve] = initialize_valve_data_structures_radial_bead_slip(N, attached, leaflet_only, optimization, decreasing_tension)
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
valve.max_consecutive_fails = 1;  
valve.max_total_fails       = 1; 

if exist('attached', 'var') 
    valve.attached = attached; 
else 
    valve.attached = false; 
end 


split_papillary = true; 
valve.split_papillary = split_papillary; 
valve.radial_and_circumferential = true; 
valve.bead_slip = true; 
valve.leaflet_only = leaflet_only; 
valve.optimization = optimization; 

valve.decreasing_tension = decreasing_tension; 

if decreasing_tension
    dec_tension_coeff_base      = 4.6;  
    valve.c_dec_tension_chordae = 1.0 * dec_tension_coeff_base; 
else 
    valve.dec_tension  = 0.0; 
end 


valve.diff_eqns = @difference_equations_bead_slip; 
valve.jacobian  = @build_jacobian_bead_slip;
        

% general solve parameters

% name 
valve.base_name = sprintf('mitral_tree_%d', N); 

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

% Constant strain of pressurized configuration 
valve.strain = .16; 

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


% controls initial guess tree vertex placement 
tree_frac = 0.5;

% name of structure 
name = 'leaflet'; 

% ring to ring fibers, always zero for now 
ring_to_ring_range = 0; 


left_papillary_idx  = 1; 
right_papillary_idx = 2; 


commissural_leaflets = true; 

if commissural_leaflets 

    valve.dip_anterior_systole = true; 
    valve.r_dip = 0.75; 
    valve.total_angle_dip = pi; 
    
    valve.L = 3.0; 
    valve.skeleton = valve_points_ct_systole(); 
    valve.diastolic_increment = [1; 0; 0]; 


    % Base constants, individual pieces are tuned relative to these values

    % pressure / tension coefficient ratio
    % this tension coefficient is the maximum tension that a fiber can support
    valve.pressure_tension_ratio = 0.05; % 0.11 * 0.975; 


    % base constant for tensions, derived quantity 
    valve.tension_base = valve.p_physical / valve.pressure_tension_ratio; 


    % tension coefficients 
    tension_coeffs.alpha_anterior       = 1.0 * valve.tension_base;  % circumferential 
    tension_coeffs.beta_anterior        = 1.1 * valve.tension_base;  % radial
    tension_coeffs.alpha_posterior      = 1.0 * valve.tension_base;  % circumferential 
    tension_coeffs.beta_posterior       = 1.1 * valve.tension_base;  % radial
    tension_coeffs.alpha_commissure     = 0.5 * valve.tension_base;  % circumferential 
    tension_coeffs.beta_commissure      = 1.0 * valve.tension_base;  % radial
    tension_coeffs.alpha_hoops          = 0.5 * valve.tension_base;  % circumferential hoops 


    % decreasing tension coefficients 
    tension_coeffs.c_circ_dec_anterior        = 1.0 * dec_tension_coeff_base;  % circumferential 
    tension_coeffs.c_rad_dec_anterior         = 1.5 * dec_tension_coeff_base;  % radial
    tension_coeffs.c_circ_dec_posterior       = 1.0 * dec_tension_coeff_base;  % circumferential 
    tension_coeffs.c_rad_dec_posterior        = 1.5 * dec_tension_coeff_base;  % radial
    tension_coeffs.c_circ_dec_commissure      = 2.0 * dec_tension_coeff_base;  % circumferential 
    tension_coeffs.c_rad_dec_commissure       = 1.0 * dec_tension_coeff_base;  % radial 
    
    % dec tension coefficients in hoops 
    tension_coeffs.c_circ_dec_hoops           = 2.0 * dec_tension_coeff_base;  % circumferential hoops
    tension_coeffs.c_rad_dec_hoops_anterior   = 0.5 * dec_tension_coeff_base;  % radial hoops, anterior part 
    tension_coeffs.c_rad_dec_hoops_posterior  = 0.5 * dec_tension_coeff_base;  % radial hoops, posterior part 
    tension_coeffs.c_rad_dec_hoops_commissure = 0.5 * dec_tension_coeff_base;  % radial hoops, posterior part 


    % places this many periodic rings above 
    n_rings_periodic = max(2,N/64); 


    % No explicit commissural leaflet here 
    N_anterior = N/4; 
    angles.anterior = 4*pi/6 - pi/12; 

    % Posterior takes whatever is left 
    N_posterior = N/4;
    angles.posterior = 4*pi/6 - pi/12; 
    
    N_commissure = N/4; 
    

    % store these 
    valve.N_anterior   = N_anterior; 
    valve.N_posterior  = N_posterior;
    valve.commissural_leaflets = true; 
    valve.N_commissure = N_commissure; 

    N_per_direction   = [N_anterior/2, N_anterior/2, ...
                         N_commissure/4, N_commissure/4, N_commissure/4, N_commissure/4, ... 
                         N_posterior/2, N_posterior/2, ...
                         N_commissure/4, N_commissure/4, N_commissure/4, N_commissure/4]; 

    % Anterior goes down then up 
    leaflet_direction = [-1, 1]; 

    % Commissure down, flat, flat, up 
    leaflet_direction = [leaflet_direction, -1, 0, 0, 1]; 
    
    % Posterior goes down then up 
    leaflet_direction = [leaflet_direction, -1, 1]; 

    % Commissure down, flat, flat, up 
    leaflet_direction = [leaflet_direction, -1, 0, 0, 1]; 
    
    % No offset, starting at commissure 
    leaflet_N_start = 0; 


    % Leaf tensions are all modified 
    valve.leaf_tension_base = .5 * valve.tension_base; 

    % Base total root tension 
    % The value 0.5905 works well on each tree when using separate solves and two leaflets 
    % Controls constant tension at the root of the tree 
    valve.root_tension_base = .5 * 0.5905 * valve.tension_base; 

    % tree constants 
    n_trees_anterior   = 2; 
    k_0_1_anterior     = 1.0 * valve.leaf_tension_base / n_trees_anterior; 
    k_0_1_anterior     = k_0_1_anterior * [1; 1]; 
    k_root_anterior    = 1.0 * valve.root_tension_base / n_trees_anterior; 
    k_root_anterior    = k_root_anterior * [1; 1]; 
    n_leaves_anterior  = N_anterior/n_trees_anterior * ones(n_trees_anterior, 1); 

    n_trees_posterior  = 2; 
    k_0_1_posterior    = 1.0 * valve.leaf_tension_base / n_trees_posterior; 
    k_0_1_posterior    = k_0_1_posterior * [1; 1]; 
    k_root_posterior   = 1.0 * valve.root_tension_base / n_trees_posterior; 
    k_root_posterior   = k_root_posterior * [1; 1]; 
    n_leaves_posterior = N_posterior/n_trees_posterior * ones(n_trees_posterior, 1); 

    n_trees_comm       = 2; 
    k_0_1_comm         = 0.8 * valve.leaf_tension_base / n_trees_comm; 
    k_0_1_comm         = k_0_1_comm * [1; 1]; 
    k_root_comm        = 0.8 * valve.root_tension_base / n_trees_comm; 
    k_root_comm        = k_root_comm * [1; 1]; 
    n_leaves_comm      = N_commissure/n_trees_comm * ones(n_trees_comm, 1);
    
    
    
    % concatenate all relevant arrays
    n_leaves           = [n_leaves_anterior; n_leaves_comm; n_leaves_posterior; n_leaves_comm];
    k_0_1              = [k_0_1_anterior; k_0_1_comm; k_0_1_posterior; k_0_1_comm]; 
    k_root             = [k_root_anterior; k_root_comm; k_root_posterior; k_root_comm];  
    
    
    % Count all trees and pull papillary locations 
    total_trees = length(n_leaves);  
    
    % get all points needed from left and right papillary locations 
    % these are all placed counterclockwise with respect to the entire setup 
    trees_per_side = total_trees/2; 
    
    papillary_left_min_angle = -pi; %-5*pi/4; 
    papillary_left_max_angle = 0; %pi/4; 
    
    papillary_left  = get_papillary_coords(valve, left_papillary_idx,  trees_per_side,  papillary_left_min_angle,  papillary_left_max_angle); 
    
    % right takes reflected angles 
    papillary_right = get_papillary_coords(valve, right_papillary_idx, trees_per_side, -papillary_left_max_angle, -papillary_left_min_angle);
    
    % number of trees on left starting at one index 
    trees_anterior_to_midline_on_left = 1;
    papillary = papillary_left(:, (trees_per_side - trees_anterior_to_midline_on_left + 1): trees_per_side); 
    
    % then all the right trees 
    papillary = [papillary, papillary_right]; 
    
    % then remaining left trees 
    papillary = [papillary, papillary_left(:, 1:(trees_per_side - trees_anterior_to_midline_on_left))]; 
    
    
else 

    valve.dip_anterior_systole = true; 
    valve.r_dip = 0.75; 
    valve.total_angle_dip = pi; 

    sytole_skeleton = true; 
    if sytole_skeleton 
        % box width 
        valve.L = 3.0; 
        valve.skeleton = valve_points_ct_systole(); 
        valve.diastolic_increment = [0; 0; 0]; 
    else
        % box width 
        valve.L = 2.5; 
        valve.skeleton = valve_points_ct_diastole(); 
        valve.diastolic_increment = [0; 0; 0]; 
    end 
    
    zero_radius = true; 
    if zero_radius
        for i = 1:length(valve.skeleton)
            valve.skeleton(i).radius = 0; 
        end 
    end 
    

    % Base constants, individual pieces are tuned relative to these values

    % pressure / tension coefficient ratio
    % this tension coefficient is the maximum tension that a fiber can support
    valve.pressure_tension_ratio = 0.05; % 0.11 * 0.975; 


    % base constant for tensions, derived quantity 
    valve.tension_base = valve.p_physical / valve.pressure_tension_ratio; 


    % tension coefficients 
    tension_coeffs.alpha_anterior       = 1.0 * valve.tension_base;  % circumferential 
    tension_coeffs.beta_anterior        = 1.1 * valve.tension_base;  % radial
    tension_coeffs.alpha_posterior      = 1.0 * valve.tension_base;  % circumferential 
    tension_coeffs.beta_posterior       = 1.0 * valve.tension_base;  % radial
    tension_coeffs.alpha_hoops          = 0.5 * valve.tension_base;  % circumferential hoops 


    % decreasing tension coefficients 
    tension_coeffs.c_circ_dec_anterior       = 1.0 * dec_tension_coeff_base;  % circumferential 
    tension_coeffs.c_rad_dec_anterior        = 1.5 * dec_tension_coeff_base;  % radial
    tension_coeffs.c_circ_dec_posterior      = 1.0 * dec_tension_coeff_base;  % circumferential 
    tension_coeffs.c_rad_dec_posterior       = 1.5 * dec_tension_coeff_base;  % radial
    tension_coeffs.c_circ_dec_hoops          = 2.0 * dec_tension_coeff_base;  % circumferential hoops
    tension_coeffs.c_rad_dec_hoops_anterior  = 0.5 * dec_tension_coeff_base;  % radial hoops, anterior part 
    tension_coeffs.c_rad_dec_hoops_posterior = 0.5 * dec_tension_coeff_base;  % radial hoops, posterior part 


    % places this many periodic rings above 
    n_rings_periodic = max(2,N/64); 


    % No explicit commissural leaflet here 
    N_anterior = N/2; 

    angles.anterior = 5*pi/6; 

    % Posterior takes whatever is left 
    N_posterior = N - N_anterior; 

    % store these 
    valve.N_anterior   = N_anterior; 
    valve.N_posterior  = N_posterior;
    valve.commissural_leaflets = false; 
    valve.N_commissure = 0; 


    N_per_direction   = [N_anterior/2, N_anterior/2, N_posterior/2, N_posterior/2]; 

    % Anterior goes down then up 
    leaflet_direction = [-1, 1]; 

    % Posterior goes down then up 
    leaflet_direction = [leaflet_direction, -1, 1]; 

    % No offset, starting at commissure 
    leaflet_N_start = 0; 


    % Leaf tensions are all modified 
    valve.leaf_tension_base = .9 * valve.tension_base; 

    % Base total root tension 
    % The value 0.5905 works well on each tree when using separate solves and two leaflets 
    % Controls constant tension at the root of the tree 
    valve.root_tension_base = .9 * 0.5905 * valve.tension_base; 


    n_trees_anterior = 2; 

    k_0_1_anterior  = 1.1 * valve.leaf_tension_base / n_trees_anterior; 
    k_0_1_anterior  = k_0_1_anterior * [1; 1]; 
    k_root_anterior = 1.1 * valve.root_tension_base / n_trees_anterior; 
    k_root_anterior = k_root_anterior * [1; 1]; 


    papillary_anterior = zeros(3,n_trees_anterior); 

    n_points = n_trees_anterior/2; 

    left_papillary_range = 1:(n_trees_anterior/2); 
    right_papillary_range  = left_papillary_range + (n_trees_anterior/2);

    papillary_anterior(:,left_papillary_range)  = get_papillary_coords(valve, left_papillary_idx,  n_points,  0*pi/4,    pi/4); 
    papillary_anterior(:,right_papillary_range) = get_papillary_coords(valve, right_papillary_idx, n_points,   -pi/4, -0*pi/4); 

    n_leaves_anterior  = N_anterior/n_trees_anterior * ones(n_trees_anterior, 1); 

    n_trees_posterior = 2; 

    k_0_1_posterior  = 0.9 * valve.leaf_tension_base / n_trees_posterior; 
    k_0_1_posterior  = k_0_1_posterior * [1; 1]; 
    k_root_posterior = 0.9 * valve.root_tension_base / n_trees_posterior; 
    k_root_posterior = k_root_posterior * [1; 1]; 

    papillary_posterior = zeros(3,n_trees_posterior); 

    n_points = n_trees_posterior/2; 

    right_papillary_range = 1:(n_trees_posterior/2); 
    left_papillary_range  = right_papillary_range + (n_trees_posterior/2); 

    papillary_posterior(:,right_papillary_range) = get_papillary_coords(valve, right_papillary_idx, n_points,    pi/4,  5*pi/4); 
    papillary_posterior(:,left_papillary_range)  = get_papillary_coords(valve, left_papillary_idx,  n_points, -5*pi/4,   -pi/4);

    % this is generally pretty good 
    n_leaves_posterior = N_posterior/n_trees_posterior * ones(n_trees_posterior, 1); 


    % concatenate all relevant arrays
    n_leaves           = [n_leaves_anterior; n_leaves_posterior];
    papillary          = [papillary_anterior, papillary_posterior]; 
    k_0_1              = [k_0_1_anterior; k_0_1_posterior]; 
    k_root             = [k_root_anterior; k_root_posterior];  

end 


valve.r        = valve.skeleton.r; 

% Approximate Lagrangian mesh spacing at ring 
% Used for later splitting of springs 
% If any spring is placed at more than double this length an extra vertex is placed
valve.ds = 2*pi*valve.r / N; 


leaflet = initialize_leaflet_bead_slip(name,                         ... 
                                N,                                   ...
                                reflect_x,                           ... 
                                angles,                              ...
                                papillary,                           ... 
                                n_leaves,                            ...
                                leaflet_direction,                   ...
                                leaflet_N_start,                     ...
                                N_per_direction,                     ...
                                radial_and_circumferential,          ...  
                                tension_coeffs,                      ... 
                                p_0,                                 ... 
                                k_0_1,                               ... 
                                k_root,                              ... 
                                tree_frac,                           ... 
                                leaflet_only,                        ...
                                ring_to_ring_range,                  ...
                                n_rings_periodic,                    ...
                                valve);  

valve.leaflets(1) = leaflet; 
    
% valve_plot(valve); 
% pause(.1); 

disp('Done with initialize.'); 


