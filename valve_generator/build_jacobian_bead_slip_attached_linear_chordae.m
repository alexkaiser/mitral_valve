function J = build_jacobian_bead_slip_attached(valve)
    % 
    % Builds the Jacobian for the current index and parameter values 
    % 
    % Input 
    %      leaflet   Current parameter values
    % 
    % Output 
    %      J         Jacobian of difference equations 

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

    anterior  = valve.anterior; 
    posterior = valve.posterior; 
    
    X_anterior                  = anterior.X; 
    R_anterior                  = anterior.R; 
    p_0_anterior                = anterior.p_0; 
    alpha_anterior              = anterior.alpha; 
    beta_anterior               = anterior.beta; 
    ref_frac_anterior           = anterior.ref_frac; 
    C_left                      = anterior.chordae.C_left; 
    C_right                     = anterior.chordae.C_right; 
    Ref_l                       = anterior.chordae.Ref_l; 
    Ref_r                       = anterior.chordae.Ref_r; 
    k_0                         = anterior.chordae.k_0; 
    chordae_idx_left            = anterior.chordae_idx_left; 
    chordae_idx_right           = anterior.chordae_idx_right;
    j_max                       = anterior.j_max; 
    k_max                       = anterior.k_max; 
    du                          = anterior.du; 
    dv                          = anterior.dv; 
    is_internal_anterior        = anterior.is_internal; 
    is_bc_anterior              = anterior.is_bc; 
    free_edge_idx_left          = anterior.free_edge_idx_left; 
    free_edge_idx_right         = anterior.free_edge_idx_right; 
    linear_idx_offset_anterior  = anterior.linear_idx_offset; 
    
    X_posterior                 = posterior.X; 
    R_posterior                 = posterior.R;
    p_0_posterior               = posterior.p_0; 
    alpha_posterior             = posterior.alpha; 
    beta_posterior              = posterior.beta; 
    ref_frac_posterior          = posterior.ref_frac; 
    is_internal_posterior       = posterior.is_internal; 
    is_bc_posterior             = posterior.is_bc; 
    linear_idx_offset_posterior = posterior.linear_idx_offset; 
    
    [m N_chordae] = size(C_left); 
    
    % total internal points in triangular domain 
    total_internal = 3*(sum(is_internal_anterior(:)) + sum(is_internal_posterior(:))); 
    total_points   = total_internal + 3*2*N_chordae; 

    % there are fewer than 15 nnz per row
    % if using the redundant features on sparse creation use more 
    capacity = 10 * 15 * total_points; 
    
    % build with indices, then add all at once 
    nnz_placed = 0; 
    j_idx      = zeros(capacity, 1); 
    k_idx      = zeros(capacity, 1); 
    vals       = zeros(capacity, 1); 
    
    
    % constant stride arrays for building 3x3 blocks 
    j_offsets = [0 1 2 0 1 2 0 1 2]'; 
    k_offsets = [0 0 0 1 1 1 2 2 2]';
    
    % initialize structures for tension variables and jacobians 
    S_anterior_left(k_max-1).val   = 0;  
    S_anterior_left(k_max-1).j     = 0;
    S_anterior_left(k_max-1).k     = 0; 
    S_anterior_left(k_max-1).j_nbr = 0; 
    S_anterior_left(k_max-1).k_nbr = 0; 
    S_anterior_left(k_max-1).G     = zeros(3,1);  
    
    S_anterior_right(k_max-1).val   = 0;  
    S_anterior_right(k_max-1).j     = 0;
    S_anterior_right(k_max-1).k     = 0; 
    S_anterior_right(k_max-1).j_nbr = 0; 
    S_anterior_right(k_max-1).k_nbr = 0; 
    S_anterior_right(k_max-1).G     = zeros(3,1); 
    
    T_anterior(j_max).val   = 0;  
    T_anterior(j_max).j     = 0;
    T_anterior(j_max).k     = 0; 
    T_anterior(j_max).j_nbr = 0; 
    T_anterior(j_max).k_nbr = 0; 
    T_anterior(j_max).G     = zeros(3,1); 
    
    S_posterior_left(k_max-1).val   = 0;  
    S_posterior_left(k_max-1).j     = 0;
    S_posterior_left(k_max-1).k     = 0; 
    S_posterior_left(k_max-1).j_nbr = 0; 
    S_posterior_left(k_max-1).k_nbr = 0; 
    S_posterior_left(k_max-1).G     = zeros(3,1);  
    
    S_posterior_right(k_max-1).val   = 0;  
    S_posterior_right(k_max-1).j     = 0;
    S_posterior_right(k_max-1).k     = 0; 
    S_posterior_right(k_max-1).j_nbr = 0; 
    S_posterior_right(k_max-1).k_nbr = 0; 
    S_posterior_right(k_max-1).G     = zeros(3,1); 
    
    T_posterior(j_max).val   = 0;  
    T_posterior(j_max).j     = 0;
    T_posterior(j_max).k     = 0; 
    T_posterior(j_max).j_nbr = 0; 
    T_posterior(j_max).k_nbr = 0; 
    T_posterior(j_max).G     = zeros(3,1);
                 
    
    for left_side = [true, false]
        
        if left_side
            free_edge_idx = free_edge_idx_left; 
            chordae_idx = chordae_idx_left; 
            C = C_left; 
            Ref = Ref_l;
        else 
            free_edge_idx = free_edge_idx_right; 
            chordae_idx = chordae_idx_right;
            C = C_right; 
            Ref = Ref_r;
        end 
        
        
        % free edge terms first              
        for i=1:size(free_edge_idx, 1)
            j = free_edge_idx(i,1);
            k = free_edge_idx(i,2);

            range_current = linear_idx_offset_anterior(j,k) + (1:3); 

            X = X_anterior(:,j,k); 
            R = R_anterior(:,j,k);

            % interior neighbor is right in j on left side, 
            % left in j on right side 
            if left_side
                j_nbr = j + 1;
            else 
                j_nbr = j - 1;
            end 
            k_nbr = k;

            % Anterior circumferential 
            X_nbr = X_anterior(:,j_nbr,k_nbr); 
            R_nbr = R_anterior(:,j_nbr,k_nbr); 

            J_tension = tension_linear_tangent_jacobian(X, X_nbr, R, R_nbr, alpha_anterior, ref_frac_anterior);
    
            if left_side 
                S_anterior_left(k)  = get_linear_tension_struct(X, X_nbr, R, R_nbr, alpha_anterior/dv, ref_frac_anterior, j, k, j_nbr, k_nbr); 
            else 
                S_anterior_right(k) = get_linear_tension_struct(X, X_nbr, R, R_nbr, alpha_anterior/dv, ref_frac_anterior, j, k, j_nbr, k_nbr); 
            end 
            
            % current term is always added in 
            % this gets no sign 
            % this is always at the current,current block in the matrix 
            place_tmp_block(range_current, range_current, J_tension); 

            % If the neighbor is an internal point, it also gets a Jacobian contribution 
            % This takes a sign
            if is_internal_anterior(j_nbr,k_nbr)
                range_nbr  = linear_idx_offset_anterior(j_nbr,k_nbr) + (1:3);
                place_tmp_block(range_current, range_nbr, -J_tension); 
            end 


            % Posterior circumferential 
            % At the "point" of the leaflet this must come from anterior 
            if chordae_idx_left(j_nbr,k_nbr) || chordae_idx_right(j_nbr,k_nbr)
                X_nbr = X_anterior(:,j_nbr,k_nbr); 
                R_nbr = R_anterior(:,j_nbr,k_nbr); 
            else 
                X_nbr = X_posterior(:,j_nbr,k_nbr); 
                R_nbr = R_posterior(:,j_nbr,k_nbr); 
            end 

            J_tension = tension_linear_tangent_jacobian(X, X_nbr, R, R_nbr, alpha_posterior, ref_frac_posterior);

            if left_side
                S_posterior_left(k)  = get_linear_tension_struct(X, X_nbr, R, R_nbr, alpha_posterior/dv, ref_frac_posterior, j, k, j_nbr, k_nbr); 
            else 
                S_posterior_right(k) = get_linear_tension_struct(X, X_nbr, R, R_nbr, alpha_posterior/dv, ref_frac_posterior, j, k, j_nbr, k_nbr); 
            end 
            
            % current term is always added in 
            % this gets no sign 
            % this is always at the current,current block in the matrix 
            place_tmp_block(range_current, range_current, J_tension); 

            % If the neighbor is an internal point, it also gets a Jacobian contribution 
            % This takes a sign
            if is_internal_posterior(j_nbr,k_nbr)
                range_nbr  = linear_idx_offset_posterior(j_nbr,k_nbr) + (1:3);
                place_tmp_block(range_current, range_nbr, -J_tension); 
            
            % if not internal posterior, the neighbor may be on the free edge 
            elseif (chordae_idx_left(j_nbr,k_nbr) || chordae_idx_right(j_nbr,k_nbr)) && is_internal_anterior(j_nbr,k_nbr)
                range_nbr  = linear_idx_offset_anterior(j_nbr,k_nbr) + (1:3);
                place_tmp_block(range_current, range_nbr, -J_tension);                
                
            end 


            % interior neighbor is up in k, always  
            j_nbr = j;     
            k_nbr = k+1; 

            % Anterior radial
            X_nbr = X_anterior(:,j_nbr,k_nbr); 
            R_nbr = R_anterior(:,j_nbr,k_nbr); 

            J_tension = tension_linear_tangent_jacobian(X, X_nbr, R, R_nbr, beta_anterior, ref_frac_anterior);

            T_anterior(j) = get_linear_tension_struct(X, X_nbr, R, R_nbr, beta_anterior/du, ref_frac_anterior, j, k, j_nbr, k_nbr); 

            % current term is always added in 
            % this gets no sign 
            % this is always at the current,current block in the matrix 
            place_tmp_block(range_current, range_current, J_tension); 

            % If the neighbor is an internal point, it also gets a Jacobian contribution 
            % This takes a sign
            if is_internal_anterior(j_nbr,k_nbr)
                range_nbr  = linear_idx_offset_anterior(j_nbr,k_nbr) + (1:3);
                place_tmp_block(range_current, range_nbr, -J_tension); 
            end 

            % Posterior radial  
            X_nbr = X_posterior(:,j_nbr,k_nbr); 
            R_nbr = R_posterior(:,j_nbr,k_nbr); 

            J_tension = tension_linear_tangent_jacobian(X, X_nbr, R, R_nbr, beta_posterior, ref_frac_posterior);

            T_posterior(j) = get_linear_tension_struct(X, X_nbr, R, R_nbr, beta_posterior/du, ref_frac_posterior, j, k, j_nbr, k_nbr); 

            % current term is always added in 
            % this gets no sign 
            % this is always at the current,current block in the matrix 
            place_tmp_block(range_current, range_current, J_tension); 

            % If the neighbor is an internal point, it also gets a Jacobian contribution 
            % This takes a sign
            if is_internal_posterior(j_nbr,k_nbr)
                range_nbr  = linear_idx_offset_posterior(j_nbr,k_nbr) + (1:3);
                place_tmp_block(range_current, range_nbr, -J_tension); 
            end

            % current node has a chordae connection
            if chordae_idx(j,k)

                kappa = k_0;

                % index that free edge would have if on tree
                % remember that leaves are only in the leaflet
                leaf_idx = chordae_idx(j,k) + N_chordae;

                % then take the parent index of that number in chordae variables
                idx_chordae = floor(leaf_idx/2);

                X_nbr = C(:,idx_chordae);
                R_nbr = Ref(:,idx_chordae);

                J_tension = tension_linear_tangent_jacobian(X,X_nbr,R,R_nbr,kappa,ref_frac_anterior); 

                % current term is always added in 
                % this gets no sign 
                % this is always at the current,current block in the matrix 
                place_tmp_block(range_current, range_current, J_tension); 

                % chordae range 
                range_nbr = range_chordae(total_internal, N_chordae, idx_chordae, left_side); 
                place_tmp_block(range_current, range_nbr, -J_tension); 

            else
                error('free edge point required to have chordae connection'); 
            end

        end
    
    end 
    
    
    for anterior_side = [true, false]

        if anterior_side 
            is_internal = is_internal_anterior; 
            is_bc = is_bc_anterior; 
            linear_idx_offset = linear_idx_offset_anterior; 
            X_current = X_anterior; 
            p_0 = p_0_anterior; 
            S_left  = S_anterior_left; 
            S_right = S_anterior_right; 
            T = T_anterior; 
        else 
            is_internal = is_internal_posterior; 
            is_bc = is_bc_posterior; 
            linear_idx_offset = linear_idx_offset_posterior; 
            X_current = X_posterior; 
            p_0 = p_0_posterior; 
            S_left  = S_posterior_left; 
            S_right = S_posterior_right; 
            T = T_posterior;
        end 


        % Internal anterior leaflet 
        % Zero indices always ignored 
        for j=1:j_max
            for k=1:k_max
                
                % Internal points, not on free edge 
                if is_internal(j,k) && ~chordae_idx_left(j,k) && ~chordae_idx_right(j,k)

                    X = X_current(:,j,k); 

                    % vertical offset does not change while differentiating this equation 
                    range_current = linear_idx_offset(j,k) + (1:3); 


                    % pressure portion 
                    % always four neighbors
                    if p_0 ~= 0.0
                        
                        % get neighbors and ranges 
                        j_nbr = j+1; 
                        k_nbr = k; 
                        [X_j_plus range_j_plus jacobian_j_plus_needed] = get_neighbor(); 

                        j_nbr = j-1; 
                        k_nbr = k; 
                        [X_j_minus range_j_minus jacobian_j_minus_needed] = get_neighbor(); 

                        j_nbr = j; 
                        k_nbr = k+1;
                        [X_k_plus range_k_plus jacobian_k_plus_needed] = get_neighbor(); 

                        j_nbr = j; 
                        k_nbr = k-1; 
                        [X_k_minus range_k_minus jacobian_k_minus_needed] = get_neighbor(); 
                        

%                         j_nbr = j+1; 
%                         k_nbr = k; 

                        J_pressure = -(p_0/(4*du*dv)) * cross_matrix(X_k_plus - X_k_minus);

                        if jacobian_j_plus_needed
                            place_tmp_block(range_current, range_j_plus, J_pressure); 
                        end 
 
%                         j_nbr = j-1; 
%                         k_nbr = k; 
                        J_pressure =  (p_0/(4*du*dv)) * cross_matrix(X_k_plus - X_k_minus); 

                        if jacobian_j_minus_needed
                            place_tmp_block(range_current, range_j_minus, J_pressure); 
                        end 

%                         j_nbr = j; 
%                         k_nbr = k+1; 
                        J_pressure =  (p_0/(4*du*dv)) * cross_matrix(X_j_plus - X_j_minus);

                        if jacobian_k_plus_needed
                            place_tmp_block(range_current, range_k_plus, J_pressure); 
                        end 

%                         j_nbr = j; 
%                         k_nbr = k-1; 
                        J_pressure = -(p_0/(4*du*dv)) * cross_matrix(X_j_plus - X_j_minus);

                        if jacobian_k_minus_needed
                            place_tmp_block(range_current, range_k_minus, J_pressure); 
                        end 

                    end 



                    for j_nbr = [j-1,j+1]

                        k_nbr = k; 

                        if (j_nbr > 0) && (k_nbr > 0) && (is_internal(j_nbr,k_nbr) || is_bc(j_nbr,k_nbr))

                            if chordae_idx_left(j,k) || chordae_idx_right(j,k)
                                error('trying to apply slip model at chordae attachment point'); 
                            end 

                            % X_nbr = X_current(:,j_nbr,k_nbr);
                            [X_nbr range_nbr nbr_jacobian_needed] = get_neighbor(); 
                            
                            % There is a 1/du term throughout from taking a finite difference derivative 
                            % Place this on the tension variables, one of which apprears in each term 

                            tension = (1/(2*du)) * (S_left(k).val + S_right(k).val); 
                            
                            grad_tension_left   = (1/(2*du)) * S_left(k).G; 
                            grad_tension_right  = (1/(2*du)) * S_right(k).G; 
                            
                            tangent = (X_nbr - X) / norm(X_nbr - X); 

                            J_tangent = tangent_jacobian(X, X_nbr); 

                            % current term is always added in 
                            % this gets no sign 
                            % this is always at the current,current block in the matrix 
                            place_tmp_block(range_current, range_current, tension * J_tangent); 

                            % If the neighbor is an internal point, on current leaflet 
                            % it also gets a Jacobian contribution 
                            % This takes a sign
                            if nbr_jacobian_needed 
                                place_tmp_block(range_current, range_nbr, -tension * J_tangent); 
                            end 

                            % Jacobians with respect to inherited tensions
                            Jac_left = tangent * grad_tension_left'; 

                            j_edge = S_left(k).j; 
                            k_edge = S_left(k).k;

                            % edge always on anterior 
                            if is_internal_anterior(j_edge,k_edge)
                                range_nbr  = linear_idx_offset_anterior(j_edge,k_edge) + (1:3);
                                place_tmp_block(range_current, range_nbr, Jac_left); 
                            end 

                            j_nbr_tension = S_left(k).j_nbr; 
                            k_nbr_tension = S_left(k).k_nbr;

                            % nbr always on current leaflet 
                            % nbr jacobian gets a sign 
                            if is_internal(j_nbr_tension,k_nbr_tension)
                                range_nbr  = linear_idx_offset(j_nbr_tension,k_nbr_tension) + (1:3);
                                place_tmp_block(range_current, range_nbr, -Jac_left); 
                            end
                            
                            % Jacobians with respect to inherited tensions
                            Jac_right = tangent * grad_tension_right'; 

                            j_edge = S_right(k).j; 
                            k_edge = S_right(k).k;

                            % edge always on anterior 
                            if is_internal_anterior(j_edge,k_edge)
                                range_nbr  = linear_idx_offset_anterior(j_edge,k_edge) + (1:3);
                                place_tmp_block(range_current, range_nbr, Jac_right); 
                            end 

                            j_nbr_tension = S_right(k).j_nbr; 
                            k_nbr_tension = S_right(k).k_nbr;

                            % nbr always on current leaflet 
                            % nbr jacobian gets a sign 
                            if is_internal(j_nbr_tension,k_nbr_tension)
                                range_nbr  = linear_idx_offset(j_nbr_tension,k_nbr_tension) + (1:3);
                                place_tmp_block(range_current, range_nbr, -Jac_right); 
                            end

                        end 
                    end 

                    
                    % v tension terms 
                    for k_nbr = [k-1,k+1]

                        j_nbr = j; 

                        if (j_nbr > 0) && (k_nbr > 0) && (is_internal(j_nbr,k_nbr) || is_bc(j_nbr,k_nbr))

                            if chordae_idx_left(j,k) || chordae_idx_right(j,k)
                                error('trying to apply slip model at chordae attachment point'); 
                            end 

                            % X_nbr = X_current(:,j_nbr,k_nbr);
                            [X_nbr range_nbr nbr_jacobian_needed] = get_neighbor(); 
                            
                            % There is a 1/du term throughout from taking a finite difference derivative 
                            % Place this on the tension variables, one of which apprears in each term 

                            tension = (1/dv) * T(j).val; 

                            grad_tension  = (1/dv) * T(j).G; 

                            tangent = (X_nbr - X) / norm(X_nbr - X); 

                            J_tangent = tangent_jacobian(X, X_nbr); 

                            % current term is always added in 
                            % this gets no sign 
                            % this is always at the current,current block in the matrix 
                            place_tmp_block(range_current, range_current, tension * J_tangent); 

                            % If the neighbor is an internal point, on current leaflet 
                            % it also gets a Jacobian contribution 
                            % This takes a sign
                            if nbr_jacobian_needed 
                                place_tmp_block(range_current, range_nbr, -tension * J_tangent); 
                            end 

                            % Jacobians with respect to inherited tensions
                            Jac = tangent * grad_tension'; 

                            j_edge = T_anterior(j).j; 
                            k_edge = T_anterior(j).k;

                            % edge always on anterior 
                            if is_internal_anterior(j_edge,k_edge)
                                range_nbr  = linear_idx_offset_anterior(j_edge,k_edge) + (1:3);
                                place_tmp_block(range_current, range_nbr, Jac); 
                            end 

                            j_nbr_tension = T(j).j_nbr; 
                            k_nbr_tension = T(j).k_nbr;

                            % nbr always on current leaflet 
                            % nbr jacobian gets a sign 
                            if is_internal(j_nbr_tension,k_nbr_tension)
                                range_nbr  = linear_idx_offset(j_nbr_tension,k_nbr_tension) + (1:3);
                                place_tmp_block(range_current, range_nbr, -Jac); 
                            end

                        end 
                    end                    

                end
            end
        end

    end 



    % chordae internal terms 
    for left_side = [true false];  

        if left_side
            C = C_left; 
            Ref = Ref_l; 
        else 
            C = C_right; 
            Ref = Ref_r; 
        end 

        for i=1:N_chordae

            left   = 2*i; 
            right  = 2*i + 1;
            parent = floor(i/2); 

            % this is the same, updating the equations for this component 
            range_current = range_chordae(total_internal, N_chordae, i, left_side); 

            for nbr_idx = [left,right,parent]

                % get the neighbors coordinates, reference coordinate and spring constants
                [nbr R_nbr k_val j_nbr k_nbr] = get_nbr_chordae(anterior, i, nbr_idx, left_side); 

                % if the neighbor is in the chordae 
                if isempty(j_nbr) && isempty(k_nbr) 
                    range_nbr = range_chordae(total_internal, N_chordae, nbr_idx, left_side); 
                elseif is_internal_anterior(j_nbr, k_nbr)
                    % neighbor is on the leaflet 
                    range_nbr = linear_idx_offset_anterior(j_nbr,k_nbr) + (1:3);
                elseif is_bc(j_nbr, k_nbr)
                    % no block added for neighbor on boundary 
                    range_nbr = []; 
                else 
                    error('Should be impossible, neighbor must be chordae, internal or bc'); 
                end

                % tension Jacobian for this spring 
                J_tension = tension_linear_tangent_jacobian(C(:,i), nbr, Ref(:,i), R_nbr, k_val, ref_frac_anterior); 

                % current always gets a contribution from this spring 
                place_tmp_block(range_current, range_current, J_tension); 

                % range may be empty if papillary muscle, in which case do nothing 
                if ~isempty(range_nbr)
                    place_tmp_block(range_current, range_nbr, -J_tension); 
                end 
            end 
        end 
    end 
 

    J = sparse(j_idx(1:nnz_placed), k_idx(1:nnz_placed), vals(1:nnz_placed), total_points, total_points, nnz_placed);  
    
%%%%%%%%%%
%
% End of real code for building Jacobian 
%  
%%%%%%%%%%


    function place_tmp_block(range_current_loc, range_nbr_loc, block_loc)
        % 
        % Places a 3x3 block in a vectors associated with a sparse matrix 
        % This function is NESTED which means that 
        % it has access to the entire workspace of the calling function 
        % 
        % Input:  
        %   range_current_loc   indices to place in j direction  
        %   range_nbr_loc       indices to place in k direction  
        %   block_loc           block to place 
        % 

        if ~all(size(block_loc) == [3,3])
            error('Must place a 3x3 block'); 
        end 

        % reallocate if too big 
        if nnz_placed + 9 >= capacity
            capacity = 2*capacity; 
            j_idx(capacity) = 0.0; 
            k_idx(capacity) = 0.0; 
            vals(capacity)  = 0.0; 
            fprintf(1, 'Hit reallocation, adjust the initial parameter up so this does not happen.\n'); 
        end 

        j_idx(nnz_placed+1 : nnz_placed+9) = range_current_loc(1) + j_offsets; 
        k_idx(nnz_placed+1 : nnz_placed+9) = range_nbr_loc(1)     + k_offsets; 
        vals (nnz_placed+1 : nnz_placed+9) = block_loc(:); 

        nnz_placed = nnz_placed+9; 

    end 


    function [X_nbr range_nbr nbr_jacobian_needed] = get_neighbor()
        % nested function for getting neighbor 
        % nested functions have full access to current work space 

        if chordae_idx_left(j_nbr,k_nbr) || chordae_idx_right(j_nbr,k_nbr)
            X_nbr = X_anterior(:,j_nbr,k_nbr); 
            range_nbr = linear_idx_offset_anterior(j_nbr,k_nbr) + (1:3);
            nbr_jacobian_needed = true; 
        elseif is_internal(j_nbr,k_nbr) 
            X_nbr = X_current(:,j_nbr,k_nbr);
            range_nbr = linear_idx_offset(j_nbr,k_nbr) + (1:3);
            nbr_jacobian_needed = true;                        
        elseif is_bc(j_nbr,k_nbr)
            X_nbr = X_current(:,j_nbr,k_nbr); 
            range_nbr = NaN; 
            nbr_jacobian_needed = false; 
        else
            error('requesting nbr in location with no nbr'); 
        end 
    end 

end 

