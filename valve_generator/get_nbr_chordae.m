function [nbr R_nbr k_val j k c_dec_tension_chordae] = get_nbr_chordae(leaflet, i, nbr_idx, tree_idx)
% 
% Given a current index and nieghbor index 
% Returns the coordinates, reference coordinates and spring constant
% Takes into account all boundary conditions 
% 
% Input
%     leaflet     Current main data structure 
%     i           Index in the chordae tree 
%     nbr_idx     Index of the neighbor in chordae tree 
%     left_side   True if on the left tree 
% 
% Output 
%     nbr         Coordinates of the neighbor
%     R_nbr       Reference coordinate of the neighbor
%     k_val       Spring constant of the connector 
%     j,k         If the neighbor is on the leaflet, these are its coordinates 
%                 Empty if the neighbor is not on the leaflet 

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


% default empty values 
j     = []; 
k     = []; 
R_nbr = []; 
c_dec_tension_chordae = []; 

X       = leaflet.X; 
chordae = leaflet.chordae; 

if isfield(chordae(tree_idx), 'R_free_edge')  && isfield(chordae(tree_idx), 'k_free_edge')
    
    free_edge_constants_set = true;
    R_free_edge = chordae(tree_idx).R_free_edge;
    k_free_edge = chordae(tree_idx).k_free_edge;
else
    free_edge_constants_set = false;
end 

C             = chordae(tree_idx).C; 
root          = chordae(tree_idx).root; 
k_vals        = chordae(tree_idx).k_vals; 
k_0           = chordae(tree_idx).k_0; 
free_edge_idx = chordae(tree_idx).free_edge_idx; 

if isfield(chordae(tree_idx), 'R_ch')
    R_ch  = chordae(tree_idx).R_ch; 
else 
    R_ch  = []; 
end 

if isfield(chordae(tree_idx), 'c_dec_chordae_leaf') && isfield(chordae(tree_idx), 'c_dec_chordae_vals')     
    dec_tension_set = true; 
    c_dec_chordae_vals = chordae(tree_idx).c_dec_chordae_vals; 
    c_dec_chordae_leaf = chordae(tree_idx).c_dec_chordae_leaf;
else 
    dec_tension_set = false; 
end 


[m max_internal] = size(C); 

% if neighbors are out of the chordae region
% then they may be on the leaflet 
if nbr_idx > max_internal
    
    idx = nbr_idx - max_internal; 

    j = free_edge_idx(idx,1); 
    k = free_edge_idx(idx,2); 
    
    nbr   = X(:,j,k); 
        
    if free_edge_constants_set
        % fetch from free edge arrays if available 
        R_nbr = R_free_edge(idx); 
        k_val = k_free_edge(idx); 
    else 
        % free edge springs are all k_0 if not  
        R_nbr = []; 
        k_val = k_0;
        
        if dec_tension_set
            c_dec_tension_chordae = c_dec_chordae_leaf;
        end 
        
    end 
    
% the neighbor is within the tree of chordae 
else 
    
    % parent direction neighbor may be the papillary muscle
    % this occurs precisely when requesting the zero index
    if nbr_idx == 0 
        
        nbr   = root; 
        
        % papillary muscle is always parent, so current location owns constant
        if ~isempty(R_ch)
            R_nbr = R_ch(i); 
        end
        
        k_val = k_vals(i);
        
        if dec_tension_set
            c_dec_tension_chordae = c_dec_chordae_vals(i);
        end
        
    else

        nbr   = C(:,nbr_idx); 
        
        % spring constants
        if nbr_idx < i 
            % nbr_idx is only less if nbr is the parent 
            % parent wise owned by this index 
            k_val = k_vals(i);                      
            
            if ~isempty(R_ch)
                R_nbr = R_ch(i); 
            end
            
            if dec_tension_set
                c_dec_tension_chordae = c_dec_chordae_vals(i);
            end 
            
        else 

            % child's parent-direction spring is at child's index 
            k_val = k_vals(nbr_idx);
            
            if ~isempty(R_ch)
                R_nbr = R_ch(nbr_idx); 
            end 
            
            if dec_tension_set
                c_dec_tension_chordae = c_dec_chordae_vals(nbr_idx);
            end 
        end 
    
    end 
end 

