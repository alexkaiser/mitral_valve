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


% Global iteration = 1, 	norm 3.090390e+05, 	elapsed = 33.652541, 	alpha = 0.031250
% Global iteration = 2, 	norm 2.940966e+05, 	elapsed = 38.024560, 	alpha = 0.125000
% Global iteration = 3, 	norm 1.995802e+05, 	elapsed = 31.840831, 	alpha = 0.250000
% Global iteration = 4, 	norm 1.007015e+05, 	elapsed = 25.793595, 	alpha = 0.500000
% Global iteration = 5, 	norm 5.718715e+04, 	elapsed = 26.973709, 	alpha = 0.500000
% Global iteration = 6, 	norm 4.270672e+04, 	elapsed = 21.319424, 	alpha = 0.500000
% Global iteration = 7, 	norm 3.540817e+04, 	elapsed = 28.376697, 	alpha = 0.500000
% Global iteration = 8, 	norm 2.740952e+04, 	elapsed = 20.229294, 	alpha = 0.500000
% Global iteration = 9, 	norm 1.953890e+04, 	elapsed = 20.289857, 	alpha = 0.500000
% Global iteration = 10, 	norm 1.488641e+04, 	elapsed = 17.212572, 	alpha = 1.000000
% Global iteration = 11, 	norm 5.159897e+02, 	elapsed = 23.562354, 	alpha = 1.000000
% Global iteration = 12, 	norm 4.422052e+01, 	elapsed = 15.755354, 	alpha = 1.000000
% Global iteration = 13, 	norm 1.229451e-01, 	elapsed = 15.746115, 	alpha = 1.000000
% Global iteration = 14, 	norm 2.166187e-06, 	elapsed = 18.597082, 	alpha = 1.000000
% 
% 



% Global iteration = 0, 	norm 3.200829e+05
% Global iteration = 1, 	norm 3.090390e+05, 	elapsed = 31.906581, 	alpha = 0.031250
% Global iteration = 2, 	norm 2.940966e+05, 	elapsed = 24.922407, 	alpha = 0.125000
% Global iteration = 3, 	norm 1.995802e+05, 	elapsed = 22.910582, 	alpha = 0.250000
% Global iteration = 4, 	norm 1.007015e+05, 	elapsed = 19.440061, 	alpha = 0.500000
% Global iteration = 5, 	norm 5.718715e+04, 	elapsed = 21.354971, 	alpha = 0.500000
% Global iteration = 6, 	norm 4.270672e+04, 	elapsed = 29.233980, 	alpha = 0.500000
% Global iteration = 7, 	norm 3.540817e+04, 	elapsed = 30.328459, 	alpha = 0.500000
% Global iteration = 8, 	norm 2.740952e+04, 	elapsed = 30.333576, 	alpha = 0.500000
% Global iteration = 9, 	norm 1.953890e+04, 	elapsed = 30.784950, 	alpha = 0.500000
% Global iteration = 10, 	norm 1.488641e+04, 	elapsed = 25.639934, 	alpha = 1.000000
% Global iteration = 11, 	norm 5.159897e+02, 	elapsed = 22.253457, 	alpha = 1.000000
% Global iteration = 12, 	norm 4.422052e+01, 	elapsed = 24.778278, 	alpha = 1.000000
% Global iteration = 13, 	norm 1.229451e-01, 	elapsed = 27.125694, 	alpha = 1.000000
% Global iteration = 14, 	norm 2.166187e-06, 	elapsed = 22.544668, 	alpha = 1.000000
% 
% 


 err = [
3.200829e+05
3.090390e+05
 2.940966e+05
 1.995802e+05
 1.007015e+05
 5.718715e+04
 4.270672e+04
 3.540817e+04
 2.740952e+04
 1.953890e+04
 1.488641e+04
 5.159897e+02
 4.422052e+01
 1.229451e-01
 2.166187e-06
]; 

it = 0:14; 

fig = figure; 
% h = axes; 
semilogy(it, err,'k')
grid on 
% set(h,'YMinorGrid','on')

xlabel('iteration')
ylabel('|F(\Phi_m)|')

printfig(fig, 'newton_error')



