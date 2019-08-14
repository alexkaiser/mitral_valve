function skeleton = get_skeleton_aortic_generic()
% 
% hardcoded patient specific MV skeleton
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


debug = false; 

% https://e-echocardiography.com/page/page.php?UID=1867001
% middle of range, simple hack 
% skeleton.r = 1.0; 
% skeleton.r = 1.25; 
% skeleton.r_commissure = 1.0 * skeleton.r; 
% 
% skeleton.normal_height = 1.4 * skeleton.r; 
% 
% skeleton.height_min_comm = 0.6 * skeleton.r; 
% 
% skeleton.ring_offset_angle = 0; 

% from... 
% A general three-dimensional parametric geometry of the native aortic valve and root for biomechanical modeling
% 
% approx radius from normal 1 
% .05 larger than value in paper 
r = 1.25; 
skeleton.r = r; 

% aorta radius 
r_aorta = 1.1 * r; 

% sinus radius at widest point (valve not to here)
r_sinus = 1.4 * r; 

% commissure radius 
skeleton.r_commissure = (2/3) * r_aorta + (1/3) * r_sinus; 

% r_co in paper 
% wide point in verticle plane through origin and commissure 
skeleton.r_co = (1/2) * (r_aorta + r_sinus); 

% height from annulus to origin 
% equal to height from annulus to height at which r_co is the radius
h1 = .9 * r; 

% commissure height measured from origin (annulus is not at the origin)
hc = .5 * r; 

skeleton.height_min_comm = h1; 

% totall commissures 
skeleton.normal_height = h1 + hc; 

skeleton.ring_offset_angle = 0; 



heights = [0; skeleton.height_min_comm; skeleton.normal_height]; 
radii   = [r; skeleton.r_co; skeleton.r_commissure]; 
skeleton.r_of_z = @(z) (z<0) .* r + ... 
                       (0<=z).*(z<skeleton.normal_height) .* interp1(heights, radii, z, 'spline') + ... 
                       (skeleton.normal_height<z) .* skeleton.r_commissure; 

if debug 
    z = linspace(-1, 2*skeleton.normal_height, 100); 
    plot(skeleton.r_of_z(z), z); 
    
    xlabel('r_of_z')
    ylabel('z')
    title('spline for radius')
    axis equal
    
end 


