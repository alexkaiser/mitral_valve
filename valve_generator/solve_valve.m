function [valve valve_with_reference pass_all] = solve_valve(valve, interactive, from_history)
% 
% Refines valve data structure to equilibrium 
% Applies auto-continuation to pressure and updates both leaflets 
% 

% Copyright (c) 2019, Alexander D. Kaiser
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

pass_all = true; 

if length(valve.leaflets) ~= 1
    error('running with single leaflet assumption for now'); 
end 

if ~exist('from_history', 'var')
    from_history = false; 
end 

if ~exist('interactive', 'var')
    interactive = false; 
end 



tol_global            = valve.tol_global; 
max_it                = valve.max_it; 
max_continuations     = valve.max_continuations; 
max_consecutive_fails = valve.max_consecutive_fails; 
max_total_fails       = valve.max_total_fails; 


if from_history
    if ~isfield(valve, 'tension_coeff_history')
        error('Must provide history to solve from history'); 
    end 
    
    [leaflet_current valve_current] = set_tension_coeffs(valve.leaflets(1), valve, valve.tension_coeff_history(1)); 
    valve = valve_current; 
    valve.leaflets(1) = leaflet_current; 
end 


for i=1:length(valve.leaflets)
    
    leaflet = valve.leaflets(i); 
    
    p_easy = 0; 
    p_goal    = leaflet.p_0; 

    [valve.leaflets(i) pass err] = solve_valve_pressure_auto_continuation(leaflet, tol_global, max_it, max_continuations, p_easy, p_goal, max_consecutive_fails, max_total_fails); 

    if pass
        fprintf('Global solve passed, err = %e\n\n', err); 
    else 
        fprintf('Global solve failed, err = %e\n\n', err); 
    end 
    
%     fig = figure; 
%     surf_plot(valve.leaflets(i), fig); 
%     pause(0.01);
    
    pass_all = pass_all && pass; 
    
end 


if from_history
    
    fig = figure; 
    valve_plot(valve, fig); 
    title('History mode valve')
    
    for history_step = 2:length(valve.tension_coeff_history)
        [leaflet_current valve_current] = set_tension_coeffs(valve.leaflets(1), valve, valve.tension_coeff_history(history_step)); 
        
        valve = valve_current; 
        valve.leaflets(1) = leaflet_current;

        try
            [valve.leaflets(1) pass err] = newton_solve_valve(valve.leaflets(1), tol_global, max_it, max_consecutive_fails, max_total_fails);  
        catch 
            fprintf('This iteration in history failed. Maybe by some miracle the next one will pass. Moving on...\n'); 
            continue; 
        end 
        
        if ~pass 
            fprintf('This iteration in history failed. Maybe by some miracle the next one will pass. Moving on...\n'); 
            continue; 
        end 

        fig = figure; 
        [az el] = view; 
        clf(fig); 
        valve_plot(valve, fig);
        title(sprintf('History mode valve, it %d\n', history_step)); 
        view(az,el);
        
    end 
end 



if interactive && pass_all
    fprintf('Solve passed, interactive mode enabled.\n'); 
    
    num_passed = 1; 
    if from_history
        num_passed = length(valve.tension_coeff_history) + 1; 
    end 
    valve.tension_coeff_history(num_passed) = valve.leaflets(1).tension_coeffs; 
    
    fig = figure; 
    valve_plot(valve, fig); 
    title('Valve in interactive mode'); 
    
    while true 
    
        fprintf('Current tension_coeffs struct, which includes all valid variables:\n')
        fprintf('tension_coeffs = \n\n')
        disp(valve.leaflets(1).tension_coeffs)
        
        fprintf('Current array variables:\n\n')
        fprintf('k_0_1 = \n\n')
        disp(valve.leaflets(1).tension_coeffs.k_0_1)
        fprintf('k_root = \n\n')
        disp(valve.leaflets(1).tension_coeffs.k_root)
        fprintf('c_dec_chordae_leaf = \n\n')
        disp(valve.leaflets(1).tension_coeffs.c_dec_chordae_leaf)
        fprintf('c_dec_chordae_root = \n\n')
        disp(valve.leaflets(1).tension_coeffs.c_dec_chordae_root)
        fprintf('\n\n'); 
        
        try 
            var_name = input('Enter the name of variable to change as a string (no quotes or whitespace, must match exactly):\n', 's'); 

            if ~ischar(var_name)
                fprintf('Must input a valid string for variable name.\n'); 
                continue; 
            end 

            if isempty(var_name)
                var_name = input('No variable name entered. Enter empty string again to leave interactive mode.\n', 's'); 
                if isempty(var_name)
                    break; 
                end 
            end 

            if isfield(valve.leaflets(1).tension_coeffs, var_name)

                tension_coeffs_current = valve.leaflets(1).tension_coeffs; 
                
                if length(tension_coeffs_current.(var_name)) > 1
                    fprintf('Found valid variable %s. You have selected an array variable. Contents of array are:', var_name);
                    tension_coeffs_current.(var_name)
                    idx = input('Enter the index you would like to change, ranges okay:\n');  
                    value = input('Input new value:\n'); 
                    tension_coeffs_current.(var_name)(idx) = value;
                else                    
                    value_old = tension_coeffs_current.(var_name);
                    fprintf('Found valid variable %s with old value %f.\n', var_name, value_old); 
                    value = input('Input new value:\n'); 
                    tension_coeffs_current.(var_name) = value;
                end 
                
                [leaflet_current valve_current] = set_tension_coeffs(valve.leaflets(1), valve, tension_coeffs_current); 

                try
                    [leaflet_current pass err] = newton_solve_valve(leaflet_current, tol_global, max_it, max_consecutive_fails, max_total_fails);  

                    if pass 
                        
                        % copy data from new version 
                        valve             = valve_current; 
                        valve.leaflets(1) = leaflet_current; 
                        
                        % save history 
                        num_passed = num_passed + 1; 
                        valve.tension_coeff_history(num_passed) = valve.leaflets(1).tension_coeffs; 
                        times = clock; 
                        save_name = sprintf('%s_tension_history_%d_%d_%d_%d.%d.%d.mat', valve.base_name, times(1), times(2), times(3), times(4), times(5), round(times(6))); 
                        history_tmp = valve.tension_coeff_history; 
                        save(save_name, 'history_tmp'); 

                        % update plot 
                        % if we do not have a figure add one 
                        if ~ishandle(fig)
                            fig = figure; 
                        end                         
                        [az el] = view; 
                        clf(fig); 
                        valve_plot(valve, fig);
                        view(az,el);
                        
                    else 
                        fprintf('New parameters failed. Keeping old tension structure. No pass flag.\n'); 
                    end
                catch 
                    fprintf('New parameters failed. Keeping old tension structure. Catch block, error called in Newton solve.\n'); 
                end 

            else 
                fprintf('Variable not found.\n'); 
            end 
            
         catch 
             fprintf('Error in interactive loop of some kind, restart loop.\n'); 
         end 
    end 
end 

if isfield(valve, 'targets_for_bcs') && valve.targets_for_bcs 
    valve.leaflets(1).target_length_check = true;     
    valve.leaflets(1).diff_eqns(valve.leaflets(1)); 
    valve.leaflets(1).target_length_check = false; 
end 
    
    

% constitutive law version 
valve_with_reference = valve; 

% kill off the old leaflet structure, new one has different fields, 
% which makes matlab complain about assigning it to a structure array 
valve_with_reference = rmfield(valve_with_reference, 'leaflets'); 

for i=1:length(valve.leaflets)
        
    valve_with_reference.leaflets(i) = set_rest_lengths_and_constants(valve.leaflets(i), valve); 
    
    if valve.targets_for_bcs_ref_only
        adjustment_length = 1e-5; 
        valve_with_reference = add_targets_for_bcs_to_valve_with_refernece(valve_with_reference, adjustment_length); 
    end 
        
    leaflet = valve_with_reference.leaflets(i); 
    
    p_easy = leaflet.p_0/10; 
    p_goal    =  0; 
    
    max_continuations_relaxed = 6; 

    [valve_with_reference.leaflets(i) pass err any_passed] = solve_valve_pressure_auto_continuation(leaflet, tol_global, max_it, max_continuations_relaxed, p_easy, p_goal, max_consecutive_fails, max_total_fails); 

    if isfield(valve_with_reference, 'targets_for_bcs') && valve_with_reference.targets_for_bcs 
        valve_with_reference.leaflets(1).target_length_check = true;     
        valve_with_reference.leaflets(1).diff_eqns(valve_with_reference.leaflets(1));     
        valve_with_reference.leaflets(1).target_length_check = false; 
    end 
    
    
    if pass
        fprintf('Global solve passed, err = %e\n\n', err); 
    else 
        if any_passed
            fprintf('Global solve passed but with pressure, err = %e\n\n', valve_with_reference.leaflets(i).p_0); 
        else 
            fprintf('Global solve failed, err = %e\n\n', err); 
        end 
    end 
    
%     fig = figure; 
%     surf_plot(valve.leaflets(i), fig); 
%     pause(0.01);
    
    pass_all = pass_all && pass; 
    
end 


