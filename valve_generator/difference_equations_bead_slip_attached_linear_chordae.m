function [F_anterior F_posterior F_chordae_left F_chordae_right] = difference_equations_bead_slip_attached(valve)
    % 
    % Evaluation of the global difference equations at j,k
    % Requires reference configuration R 
    % 
    % Input
    %     leaflet    Current parameters 
    %
    % Output
    %     F        Values of all difference equation, 3 by triangular array 
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
    
    anterior  = valve.anterior; 
    posterior = valve.posterior;

    X_anterior         = anterior.X; 
    R_anterior         = anterior.R; 
    p_0_anterior       = anterior.p_0; 
    alpha_anterior     = anterior.alpha; 
    beta_anterior      = anterior.beta; 
    ref_frac_anterior  = anterior.ref_frac; 
    C_left             = anterior.chordae.C_left; 
    C_right            = anterior.chordae.C_right; 
    Ref_l              = anterior.chordae.Ref_l; 
    Ref_r              = anterior.chordae.Ref_r; 
    k_0                = anterior.chordae.k_0; 
    chordae_idx_left   = anterior.chordae_idx_left; 
    chordae_idx_right  = anterior.chordae_idx_right;
    j_max              = anterior.j_max; 
    k_max              = anterior.k_max; 
    du                 = anterior.du; 
    dv                 = anterior.dv; 


    X_posterior        = posterior.X; 
    R_posterior        = posterior.R;
    p_0_posterior      = posterior.p_0; 
    alpha_posterior    = posterior.alpha; 
    beta_posterior     = posterior.beta; 
    ref_frac_posterior = posterior.ref_frac; 


    F_anterior  = zeros(size(X_anterior)); 
    F_posterior = zeros(size(X_posterior)); 


    [m N_chordae] = size(C_left); 


    S_anterior_left   = zeros(k_max-1,1); 
    S_anterior_right  = zeros(k_max-1,1); 
    S_posterior_left  = zeros(k_max-1,1); 
    S_posterior_right = zeros(k_max-1,1); 
    T_anterior        = zeros(j_max,1); 
    T_posterior       = zeros(j_max,1); 


    free_edge_idx_left  = anterior.free_edge_idx_left; 
    free_edge_idx_right = anterior.free_edge_idx_right;


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

        for i=1:size(free_edge_idx, 1)

            F_tmp = zeros(3,1);

            % left free edge has spring connections up and right on both leaflets

            j = free_edge_idx(i,1);
            k = free_edge_idx(i,2);

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

            if left_side
                S_anterior_left(k) = tension_linear(X, X_nbr, R, R_nbr, alpha_anterior, ref_frac_anterior); 
                F_tmp = F_tmp + S_anterior_left(k) * (X_nbr-X)/norm(X_nbr-X); 
            else
                S_anterior_right(k) = tension_linear(X, X_nbr, R, R_nbr, alpha_anterior, ref_frac_anterior); 
                F_tmp = F_tmp + S_anterior_right(k) * (X_nbr-X)/norm(X_nbr-X);             
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
            
            if left_side 
                S_posterior_left(k) = tension_linear(X, X_nbr, R, R_nbr, alpha_posterior, ref_frac_posterior);         
                F_tmp = F_tmp + S_posterior_left(k) * (X_nbr-X)/norm(X_nbr-X);  
            else 
                S_posterior_right(k) = tension_linear(X, X_nbr, R, R_nbr, alpha_posterior, ref_frac_posterior);         
                F_tmp = F_tmp + S_posterior_right(k) * (X_nbr-X)/norm(X_nbr-X);            
            end 

            % interior neighbor is up in k, always 
            j_nbr = j;     
            k_nbr = k+1; 

            % Anterior radial
            X_nbr = X_anterior(:,j_nbr,k_nbr); 
            R_nbr = R_anterior(:,j_nbr,k_nbr); 
            T_anterior(j) = tension_linear(X, X_nbr, R, R_nbr, beta_anterior, ref_frac_anterior); 
            F_tmp = F_tmp + T_anterior(j) * (X_nbr-X)/norm(X_nbr-X); 

            % Posterior radial 
            X_nbr = X_posterior(:,j_nbr,k_nbr); 
            R_nbr = R_posterior(:,j_nbr,k_nbr); 
            T_posterior(j) = tension_linear(X, X_nbr, R, R_nbr, beta_posterior, ref_frac_posterior); 
            F_tmp = F_tmp + T_posterior(j) * (X_nbr-X)/norm(X_nbr-X); 

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

                F_tmp = F_tmp + tension_linear(X,X_nbr,R,R_nbr,kappa,ref_frac_anterior) * (X_nbr-X)/norm(X_nbr-X); 

            else
                error('free edge point required to have chordae connection'); 
            end

            F_anterior(:,j,k) = F_tmp; 

        end 

    end 

    % Tensions are equalized from left to right 
    S_anterior = (S_anterior_left + S_anterior_right)/2.0; 
    S_posterior = (S_posterior_left + S_posterior_right)/2.0; 
 
    % Convert from units of force to force densities 
    S_anterior  = S_anterior  /dv;
    S_posterior = S_posterior /dv;
    T_anterior  = T_anterior  /du;
    T_posterior = T_posterior /du;

    % Internal leaflet part 
    for anterior_side = [true, false]

        if anterior_side 
            is_internal = anterior.is_internal; 
            is_bc = anterior.is_bc; 
            X_current = X_anterior; 
            p_0 = p_0_anterior; 
            S = S_anterior; 
            T = T_anterior; 
        else 
            is_internal = posterior.is_internal; 
            is_bc = posterior.is_bc; 
            X_current = X_posterior; 
            p_0 = p_0_posterior; 
            S = S_posterior; 
            T = T_posterior;
        end 


        for j=1:j_max
            for k=1:k_max
                if is_internal(j,k) && (~chordae_idx_left(j,k)) && (~chordae_idx_right(j,k))

                    X = X_current(:,j,k); 

                    F_tmp = zeros(3,1);

                    % pressure term first  
                    if p_0 ~= 0
                        
                        j_nbr = j+1; 
                        k_nbr = k; 
                        X_j_plus = get_neighbor(); 

                        j_nbr = j-1; 
                        k_nbr = k; 
                        X_j_minus = get_neighbor(); 

                        j_nbr = j; 
                        k_nbr = k+1;
                        X_k_plus = get_neighbor(); 

                        j_nbr = j; 
                        k_nbr = k-1; 
                        X_k_minus = get_neighbor(); 
                        
                        F_tmp = F_tmp + (p_0 / (4*du*dv)) * cross(X_j_plus - X_j_minus, X_k_plus - X_k_minus); 
                    end 

                    
                    % u type fibers 
                    for j_nbr = [j-1,j+1]

                        k_nbr = k; 
                        X_nbr = get_neighbor(); 

                        F_tmp = F_tmp + S(k)/du * (X_nbr-X)/norm(X_nbr-X); 
                        % F_tmp = F_tmp + 1/du * (X_nbr-X)/norm(X_nbr-X); 

                    end 

                    
                    % v type fibers 
                    for k_nbr = [k-1,k+1]

                        j_nbr = j; 
                        X_nbr = get_neighbor(); 

                        F_tmp = F_tmp + T(j)/dv * (X_nbr-X)/norm(X_nbr-X); 

                    end 
                    

                    if anterior_side
                        F_anterior(:,j,k) = F_tmp;
                    else 
                        F_posterior(:,j,k) = F_tmp;
                    end 
                end
            end 
        end
    end 



    % chordae internal terms 
    F_chordae_left  = zeros(size(C_left )); 
    F_chordae_right = zeros(size(C_right)); 

    [m N_chordae] = size(C_left); 

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

            for nbr_idx = [left,right,parent]

                % get the neighbors coordinates, reference coordinate and spring constants
                [nbr R_nbr k_val] = get_nbr_chordae(anterior, i, nbr_idx, left_side); 

                tension = tension_linear_over_norm(C(:,i), nbr, Ref(:,i), R_nbr, k_val, ref_frac_anterior) * (nbr - C(:,i));  

                if left_side
                    F_chordae_left(:,i)  = F_chordae_left(:,i)  + tension; 
                else 
                    F_chordae_right(:,i) = F_chordae_right(:,i) + tension; 
                end 

            end 

        end 
    end 


    function X_nbr = get_neighbor()
        % nested function for getting neighbor 
        % nested functions have full access to current work space 

        if chordae_idx_left(j_nbr,k_nbr) || chordae_idx_right(j_nbr,k_nbr)
            X_nbr = X_anterior(:,j_nbr,k_nbr); 
        elseif is_internal(j_nbr,k_nbr) || is_bc(j_nbr,k_nbr) 
            X_nbr = X_current(:,j_nbr,k_nbr); 
        else
            error('requesting nbr in location with no nbr'); 
        end 
    end 
    
    

end 



