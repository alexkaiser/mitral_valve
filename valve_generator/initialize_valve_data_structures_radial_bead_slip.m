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
valve.max_it = 4000; 

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
if split_papillary 
    % vector pointing along line from left to right papillary 
    l_to_r_papillary = (valve.right_papillary - valve.left_papillary); 
    l_to_r_papillary = l_to_r_papillary / norm(l_to_r_papillary);
    papillary_increment = 0.1; 
else 
    l_to_r_papillary = zeros(3,1); 
    papillary_increment = 0.0;
end 


valve.left_papillary_diastolic  = valve.left_papillary  + [0; 0; 1.0]; 
valve.right_papillary_diastolic = valve.right_papillary + [0; 0; 1.0]; 

valve.split_papillary = false; 
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
    valve.c_dec_tension_radial          = 1.0 * dec_tension_coeff_base; 
    valve.c_dec_tension_chordae         = 1.0 * dec_tension_coeff_base; 
else 
    valve.dec_tension  = 0.0; 
end 



% function pointers 
if attached 
    valve.diff_eqns = @difference_equations_bead_slip_attached; 
    valve.jacobian  = @build_jacobian_bead_slip_attached; 
    
    if leaflet_only
        error('leaflet_only not implemented for attached')
    end 
        
else 
    if leaflet_only
        valve.diff_eqns = @difference_equations_bead_slip_leaflet_only; 
        valve.jacobian  = @build_jacobian_bead_slip_leaflet_only;
    else 
        valve.diff_eqns = @difference_equations_bead_slip; 
        valve.jacobian  = @build_jacobian_bead_slip;
        
    end 
end 

% general solve parameters

% name 
valve.base_name = sprintf('mitral_tree_%d', N); 

% box width 
valve.L = 2.5; 

% pressure / tension coefficient ratio
% this tension coefficient is the maximum tension that a fiber can support 
valve.pressure_tension_ratio = 0.11; % 0.11 * 0.975; % good value without commissural leaflets


% original spring constants were for N = 32 debug width
% spring constants get multiplied by 32/N, so they are halfed if N==64
% use this refintement number accordingly 
valve.refinement = N/32.0; 

MMHG_TO_CGS = 1333.22368;
valve.p_physical = 110 * MMHG_TO_CGS; 

% scaling for target points 
valve.target_multiplier = 40; 

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
valve.collagen_springs_leaflet = false; 


% anterior leaflet data structure 
reflect_x = false; 
total_angle_anterior = 5*pi/6; 
angles_anterior = [-total_angle_anterior/2, total_angle_anterior/2]; 

% Radial and circumferential fibers 
% Or diagonally oriented fibers 
radial_and_circumferential = true; 

% base constant for tensions 
valve.tension_base = valve.p_physical / valve.pressure_tension_ratio; 

% physical units create a scalar multiple of the old 
% this multiple is large number, so we want to scale the old tolerance accordingly 
% 8.3326e-04 is a good number here
valve.tol_global = 1e-3; 


% Spring constants in two directions 
alpha    = 1.0 * valve.tension_base;  % circumferential 
beta     = 1.0 * valve.tension_base;  % radial
p_0      =      -valve.p_physical; 

ref_frac =  1.0;  % generic spring constants reduced by this much 


% Places this many extra fibers from ring to ring 
% Must be 0 <= N_ring_to_ring <= (N/2)
ring_to_ring_anterior_range  = 0; %[1, (3*N/8)];
ring_to_ring_posterior_range = 0; %[1, (3*N/8)];


% Add energy function for zero pressure case 
if (p_0 == 0.0) && (~leaflet_only)
    valve.energy = @energy_bead_slip; 
end 


% Chordae parameters 

% tree has half as many leaves as total number of radial fibers N
N_tree = N/2; 

% base constant for force scaling
% this is the total force, in current units, 
% in the leaf generation of the chordae tree 
% this is an arbitrary constant determined by guess and check 

% good basic value = 1.8 * 0.5 * (alpha + beta) = 1.8 * tension_base
k_0_1 = 1.0 * valve.tension_base; 

% force on each leaf in the chordae tree 
k_0   = k_0_1 / N_tree; 

% constant tension at the root of the tree 
% this is determined by hand tuning k_multiplier at coarse resolution 
% then taking the k_root 

% base good value, old program units  
% k_root = 1.889568000000001e+01 / 32; 

% adjust accordingly
% note that 1.889568000000001e+01 / 32 = 0.5905
k_root = 1.0 * (1.889568000000001e+01 / 32) * valve.tension_base; 

% multiplier necessary to maintain constant root tension 
% and constant total leaf tension 
k_multiplier = 2.0 * (k_root/k_0_1)^(1/log2(N_tree)); 


tree_frac    = 0.5;

% double tree strength in attached version 
if attached 
    k_0 = k_0 * 2.0; 
end 

left_papillary_anterior  = valve.left_papillary; 
right_papillary_anterior = valve.right_papillary;


valve.anterior = initialize_leaflet_bead_slip(N,                  ... 
                                    reflect_x,                    ... 
                                    angles_anterior,              ...    
                                    valve.r,                      ... 
                                    left_papillary_anterior,      ... 
                                    right_papillary_anterior,     ... 
                                    radial_and_circumferential,   ...  
                                    alpha,                        ... 
                                    beta,                         ... 
                                    p_0,                          ... 
                                    ref_frac,                     ...  
                                    k_0,                          ... 
                                    k_multiplier,                 ... 
                                    tree_frac,                    ... 
                                    leaflet_only,                 ...
                                    ring_to_ring_anterior_range,  ...
                                    valve);  

                   

if valve.attached 
    valve.posterior = generate_opposite_leaflet(valve.anterior); 
    
else 
    
    total_angle_posterior = 3*pi/6; 
    
    
    angles_posterior = [pi + total_angle_posterior/2, pi - total_angle_posterior/2]; 
    reflect_x = true; 
    
    % reflect pressure also 
    if reflect_x
        p_0 = -p_0; 
    end 
    
    left_papillary_posterior  = valve.left_papillary  + 3*papillary_increment*l_to_r_papillary; 
    right_papillary_posterior = valve.right_papillary - 3*papillary_increment*l_to_r_papillary; 
    
    valve.posterior = initialize_leaflet_bead_slip(N,             ...
                                    reflect_x,                    ... 
                                    angles_posterior,             ...    
                                    valve.r,                      ... 
                                    left_papillary_posterior,     ... 
                                    right_papillary_posterior,    ... 
                                    radial_and_circumferential,   ...  
                                    alpha,                        ... 
                                    beta,                         ... 
                                    p_0,                          ... 
                                    ref_frac,                     ...  
                                    k_0,                          ... 
                                    k_multiplier,                 ... 
                                    tree_frac,                    ... 
                                    leaflet_only,                 ...
                                    ring_to_ring_posterior_range, ...
                                    valve);  

    
    
end 



valve.commissural_leaflets = true; 

if valve.commissural_leaflets 

    % parameters for both 
    reflect_x = false; 
    total_angle_each_commissural = 3*pi/6; 
    N_comm = N; 
    valve.commissural_tension_base = 0.5 * valve.tension_base; 
    
    % Spring constants in two directions 
    
    alpha    = 1.0 * valve.commissural_tension_base;  % circumferential 
    beta     = 1.0 * valve.commissural_tension_base;  % radial

    % tree has half as many leaves as total number of radial fibers N
    N_tree = N_comm/2; 

    % base constant for force scaling
    k_0_1 = 1.0 * valve.commissural_tension_base; 

    % force on each leaf in the chordae tree 
    k_0   = k_0_1 / N_tree; 

    % root tension 
    k_root = 0.7 * (1.889568000000001e+01 / 32) * valve.commissural_tension_base; 

    % multiplier necessary to maintain constant root tension 
    % and constant total leaf tension 
    k_multiplier = 2.0 * (k_root/k_0_1)^(1/log2(N_tree)); 
    
    
    % left parameters  
    center_left = -pi/2 - pi/6; 
    angels_left_comm = [center_left - total_angle_each_commissural/2, center_left + total_angle_each_commissural/2]; 
    ring_to_ring_left_comm = 0; 
    
    left_papillary_comm_left  = valve.left_papillary  + 2*papillary_increment*l_to_r_papillary; 
    right_papillary_comm_left = valve.left_papillary  + 1*papillary_increment*l_to_r_papillary; 
        
    % both trees anchored to left papillary here 
    valve.comm_left = initialize_leaflet_bead_slip(N_comm,        ...
                                    reflect_x,                    ... 
                                    angels_left_comm,             ...    
                                    valve.r,                      ... 
                                    left_papillary_comm_left,     ... 
                                    right_papillary_comm_left,    ... 
                                    radial_and_circumferential,   ...  
                                    alpha,                        ... 
                                    beta,                         ... 
                                    p_0,                          ... 
                                    ref_frac,                     ...  
                                    k_0,                          ... 
                                    k_multiplier,                 ... 
                                    tree_frac,                    ... 
                                    leaflet_only,                 ...
                                    ring_to_ring_left_comm,       ...
                                    valve); 
    
    
    
    % Even though N may be different, the mesh spacing paramters should be the same
    valve.comm_left.du = valve.anterior.du; 
    valve.comm_left.dv = valve.anterior.du; 
    
    % right parameters 
    center_right = pi/2 + pi/6; 
    angels_right_comm = [center_right - total_angle_each_commissural/2, center_right + total_angle_each_commissural/2]; 
    ring_to_ring_right_comm = 0; 
    
    left_papillary_comm_right  = valve.right_papillary - 1*papillary_increment*l_to_r_papillary; 
    right_papillary_comm_right = valve.right_papillary - 2*papillary_increment*l_to_r_papillary; 
    
    % both trees anchored to left papillary here 
    valve.comm_right = initialize_leaflet_bead_slip(N_comm,       ...
                                    reflect_x,                    ... 
                                    angels_right_comm,            ...    
                                    valve.r,                      ... 
                                    left_papillary_comm_right,    ... 
                                    right_papillary_comm_right,   ... 
                                    radial_and_circumferential,   ...  
                                    alpha,                        ... 
                                    beta,                         ... 
                                    p_0,                          ... 
                                    ref_frac,                     ...  
                                    k_0,                          ... 
                                    k_multiplier,                 ... 
                                    tree_frac,                    ... 
                                    leaflet_only,                 ...
                                    ring_to_ring_right_comm,      ...
                                    valve); 
    
    
    % Even though N may be different, the mesh spacing paramters should be the same 
    valve.comm_right.du = valve.anterior.du; 
    valve.comm_right.dv = valve.anterior.du;
    
end 

valve_plot(valve); 
disp('Done with initialize.'); 


