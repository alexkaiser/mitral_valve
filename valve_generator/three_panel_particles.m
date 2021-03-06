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

set(0, 'DefaultFigureRenderer', 'painters');

data_dir = './' ; 
%data_dir =  '/Users/alex/mitral_fully_discrete/plots_and_session_files/mitral_1647284_512_git_5855699_two_leaflet_mean_reverting'; 

max_velocity = 150; 


min_frame = 0; 
max_frame = 1440; 

% colorbar_name = 'colorbar_movie.jpg'; 

PATH = getenv('PATH');
setenv('PATH', [PATH ':/usr/local/bin']);

eps_format = false; 
if eps_format 
    format_extension = '.eps'; 
    format_string = '-depsc'; 
else 
    format_extension = '.jpg'; 
    format_string = '-djpeg'; 
end 

if min_frame ~= 0
    error('assumes minimum frame is one'); 
end

line_width_leaflet = 2; 
line_width_tails = 16; 
dot_size = 0; 
colored_heads = true; 

dt_sim = 1.5e-6; 
output_frequency = 1111; 
dt = dt_sim * output_frequency; 



cleanup = true; 

rng('shuffle');

% range = randperm(max_frame + 1) - 1;

for i=0:max_frame
    
    file_name = sprintf('mitral_tree_512_%.6d.m', i); 
    output_base_name = sprintf('particle_views_%.6d', i); 

    start_name = sprintf('%s_start.txt', output_base_name); 
    end_name = sprintf('%s_complete.txt', output_base_name); 

    fprintf('  Checking file_name %s...\n', file_name)

    % short stop to discourage writing same frames twice
    pause(4 * rand()); 
    if exist(start_name, 'file') || exist(end_name, 'file') 
        fprintf('Start or end file exists, moving on\n')
        continue; 
    end      

%         if cleanup && exist(end_name, 'file')
%             fprintf('On cleanup, end file exists, moving on\n')
%             continue; 
%         end 

    system(sprintf('touch %s', start_name)); 

    fprintf('Writing frames assoc with file_name %s\n', file_name)

    time = i * dt; 
    colorbar_name = strcat(output_base_name, '_colorbar', format_extension); 
    make_movie_colorbar(max_velocity, format_string, time, colorbar_name); 
    
    
    clear_fucntion_cache = false; 

    if clear_fucntion_cache 

        working_dir = pwd; 
        cd(data_dir); 

        file_name_copy = file_name; 
        clear file_name
        file_name = file_name_copy;

        cd(working_dir)
    end 

    bounding_box = true; 
    colorbar_figure = false; 
    colorbar_for_movie = true; 

    L = 3; 
    horiz_min = -L; 
    horiz_max =  L; 
    zmin =  3 - 4*L;
    zmax =  3; 
    
    r = 0.1 * 21.885241; 
    frac_to_right = .35; 

    file_name = strcat(data_dir, '/', file_name); 

    fig = figure('visible','off'); 
    % fig = figure; 
    set(fig, 'Renderer', 'painters');
    % 4x HD resolution 
    set(fig, 'Position', [0 0 2160 4320])
    set(fig, 'PaperPositionMode','auto')

    fig = plot_particles(file_name, max_velocity, fig, bounding_box, colorbar_figure, line_width_leaflet, line_width_tails, dot_size, colored_heads); 

    % side view, anterior leaflet to the right 
    view(0,0)

    axis([horiz_min horiz_max horiz_min horiz_max zmin zmax])
    % axis off 

    ax = gca;
    ax.Position = [0.01 0.01 .98 .98]; 

    side_name = strcat(output_base_name, '_side', format_extension); 

    print(fig, format_string, side_name, '-r0')

    % front view 

    view(90,0)
    axis([horiz_min horiz_max horiz_min horiz_max zmin zmax])
    % axis off 

    ax = gca;
    ax.Position = [0.01 0.01 .98 .98]; 

    front_name = strcat(output_base_name, '_front', format_extension); 
    print(fig, format_string, front_name, '-r0')

    % top view
    view(0,90)



    axis([-r frac_to_right*r -r r -4 2])

    % set(fig, 'Position', [100, 100, 500, floor(500*(1 + frac_to_right)/2)])
    set(fig, 'Position', [0 0 2916 4320])

    ax = gca;
    ax.Position = [0.00 0.00 1 1]; 

    top_name = strcat(output_base_name, '_top', format_extension); 
    print(fig, format_string, strcat(output_base_name, '_top'), '-r0')

    close(fig); 

    % append the existing panels 
    all_name = strcat(output_base_name, '_panels.jpg'); 
    command = sprintf('convert %s %s %s %s +append %s', colorbar_name, side_name, front_name, top_name, all_name);  
    system(command,'-echo') 

%     if eps_format
%         all_name_eps = strcat(output_base_name, '_panels', '.eps');
%         command = sprintf('convert %s %s', all_name, all_name_eps);  
%         system(command,'-echo')
%     end 

    system(sprintf('touch %s', end_name)); 
    system(sprintf('rm %s', start_name)); 

end 

