function [] = solve_valve_script_four_leaflet(restart_number)


if restart_number ~= 0
    data_str = sprintf('data_iteration_%d', restart_number); 
    load(data_str); 
    start_it = restart_number; 
    
else 

    % symmetric for now 
    commissure_angle = pi/3; 
    
    a = 1; 
    r = 1.5;
    h = 2; 
    N = 32; 

    min_angle_posterior = -(pi/2 - commissure_angle/2); 
    max_angle_posterior =  (pi/2 - commissure_angle/2); 

    filter_params_posterior.a = a; 
    filter_params_posterior.r = r; 
    filter_params_posterior.h = h;
    filter_params_posterior.N = N;
    filter_params_posterior.min_angle = min_angle_posterior;
    filter_params_posterior.max_angle = max_angle_posterior;

    % reference and initial surfaces are the same 
    R = build_reference_surface(filter_params_posterior); 

    X = R; 
    alpha     =  1.0; % spring constants in two directions 
    beta      =  1.0;
    p_0       = -30.0; 
    ref_frac  =  0.5; 

    params_posterior = pack_params(X,alpha,beta,N,p_0,R,ref_frac); 

    fig = surf_plot(params_posterior, filter_params_posterior); 
    title('Reference configuration of posterior surface'); 
    
    'initial difference equation norm'
    err = total_global_err(params_posterior, filter_params_posterior)
    
    tol_global = 1e-12; 
    max_it_global = 100000; 
    
    plot_and_save_freq = 10; 
    start_it = 0; 
    
    err_over_time_posterior = zeros(max_it_global,1); 
    
    
    % anterior 
    min_angle_anterior = -(pi/2 - commissure_angle/2); 
    max_angle_anterior =  (pi/2 - commissure_angle/2); 

    filter_params_anterior.a = a; 
    filter_params_anterior.r = r; 
    filter_params_anterior.h = h;
    filter_params_anterior.N = N;
    filter_params_anterior.min_angle = min_angle_anterior;
    filter_params_anterior.max_angle = max_angle_anterior;

    % reference and initial surfaces are the same 
    R = build_reference_surface(filter_params_anterior); 
    X = R; 

    params_anterior = pack_params(X,alpha,beta,N,p_0,R,ref_frac); 

    fig = surf_plot(params_anterior, filter_params_anterior); 
    title('Reference configuration of anterior surface'); 
    
    'initial difference equation norm'
    err = total_global_err(params_anterior, filter_params_anterior)
    
    err_over_time_anterior = zeros(max_it_global,1); 
    
    
    
    % left commissural leaflet
    % total hack on dimensions here for now 
    N_left = floor(N/2) + 1; 
    center = -pi/2; 
    min_angle_left = center - commissure_angle/2; 
    max_angle_left = center + commissure_angle/2;
    left = true; 
    
    filter_params_left.a = a; 
    filter_params_left.r = r; 
    filter_params_left.h = h;
    filter_params_left.N = N_left;
    filter_params_left.min_angle = min_angle_left;
    filter_params_left.max_angle = max_angle_left;
    
    R = build_reference_surface_commissure(filter_params_left, left);
    X = R; 
    params_left = pack_params(X,alpha,beta,N_left,p_0,R,ref_frac); 
    
    fig = surf_plot_commissure(params_left, filter_params_left, left); 
    title('Reference configuration of surface'); 
    
    'initial difference equation norm'
    err = total_global_err_commissure(params_left, filter_params_left, left);
    
    err_over_time_left = zeros(max_it_global,1); 
    
    % right commissural leaflet
    % total hack on dimensions here for now 
    N_right = floor(N/2) + 1; 
    center = pi/2; 
    min_angle_right = center - commissure_angle/2; 
    max_angle_right = center + commissure_angle/2;
    left = false; 
    
    filter_params_right.a = a; 
    filter_params_right.r = r; 
    filter_params_right.h = h;
    filter_params_right.N = N_right;
    filter_params_right.min_angle = min_angle_right;
    filter_params_right.max_angle = max_angle_right;
    
    R = build_reference_surface_commissure(filter_params_right, left);
    X = R; 
    params_right = pack_params(X,alpha,beta,N_right,p_0,R,ref_frac); 
    
    fig = surf_plot_commissure(params_right, filter_params_right, left); 
    title('Reference configuration of surface'); 
    
    'initial difference equation norm'
    err = total_global_err_commissure(params_right, filter_params_right, left);
    
    err_over_time_right = zeros(max_it_global,1); 
end 




[params_posterior pass err_over_time_posterior it] = solve_valve(params_posterior, filter_params_posterior, tol_global, max_it_global, plot_and_save_freq, start_it, err_over_time_posterior); 

'difference equation norm'
err_posterior = total_global_err(params_posterior, filter_params_posterior)

% reflect posterior to actually have two leaflets
params_posterior.X(1,:,:) = -params_posterior.X(1,:,:); 

if pass 
    disp('Global solve passed posterior')
else 
    disp('Global solve failed')
end


[params_anterior pass err_over_time_anterior it] = solve_valve(params_anterior, filter_params_anterior, tol_global, max_it_global, plot_and_save_freq, start_it, err_over_time_anterior); 

'difference equation norm'
err_anterior = total_global_err(params_anterior, filter_params_anterior)

if pass 
    disp('Global solve passed anterior')
else 
    disp('Global solve failed')
end 

left = true; 
[params_left pass err_over_time_left it] = solve_commissure_leaflet(params_left, filter_params_left, tol_global, max_it_global, plot_and_save_freq, start_it, err_over_time_left, left); 


if pass 
    disp('Global solve passed')
else 
    disp('Global solve failed')
end 

'difference equation norm left'
err_left = total_global_err_commissure(params_left, filter_params_left, left)


left = false; 
[params_right pass err_over_time_right it] = solve_commissure_leaflet(params_right, filter_params_right, tol_global, max_it_global, plot_and_save_freq, start_it, err_over_time_right, left); 


if pass 
    disp('Global solve passed')
else 
    disp('Global solve failed')
end 

'difference equation norm right'
err_right = total_global_err_commissure(params_right, filter_params_right, left)



fig = figure; 
fig = surf_plot(params_posterior, filter_params_posterior, fig);
hold on 
fig = surf_plot(params_anterior, filter_params_anterior, fig);

left = true; 
fig = surf_plot_commissure(params_left, filter_params_left, left, fig); 

left = false;
fig = surf_plot_commissure(params_right, filter_params_right, left, fig); 

title(sprintf('Final time difference equation solution, p = %f, ref_frac = %f' , params_posterior.p_0, params_posterior.ref_frac )); 
name = sprintf('surf_p_%f', params_posterior.p_0); 
printfig(fig, strcat(name, '.eps'));
saveas(fig, strcat(name, '.fig'),'fig'); 


fig = figure; 
semilogy(err_over_time_posterior, '*-'); 
hold on 
semilogy(err_over_time_anterior, 's-'); 
semilogy(err_over_time_left, 'o-'); 
semilogy(err_over_time_right, '+-'); 

legend('posterior', 'anterior', 'left', 'right', 'location', 'SouthWest'); 
xlabel('iteration')
ylabel('log(err)')

title(sprintf('error through iterations, p = %f, ref frac = %f', params_posterior.p_0, params_posterior.ref_frac))
name = sprintf('error_p_%f', params_posterior.p_0)
printfig(fig, strcat(name, '.eps')); 
saveas(fig, strcat(name, '.fig'),'fig'); 









