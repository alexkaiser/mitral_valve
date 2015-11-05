function F = difference_equations_component(params, filter_params,j,k)
% 
% Evaluation of the difference equations at j,k
% Requires reference configuration R 
% 
% Input
%     params   Current parameters 
%     filter_params  Cone filter paramaters 
%
% Output
%     F        Values of all difference equation, 3 by triangular array 
% 


[X,alpha,beta,N,p_0,R,ref_frac] = unpack_params(params); 

left_papillary  = [0; -filter_params.a; 0]; 
right_papillary = [0;  filter_params.a; 0]; 


% always 6 pressure neighbors, which may or may not be in bounds
% relative indices of pressure here 
% numbered counter clockwise 
% ignore out of bounds indices, they are not in the pressure 
% bearing part of the surface 
pressure_nbrs = [ 0, -1; 
                  1, -1; 
                  1,  0; 
                  0,  1; 
                 -1,  1; 
                 -1,  0]'; 

             
% in the triangle?
if (j+k) < (N+2)

    % pressure term first  
    pressure_term = zeros(3,1); 

    % zero indexed loop because we are computing indices with mod n 
    for n=0:5

        j_nbr      = j + pressure_nbrs(1,mod(n  ,6)+1); 
        k_nbr      = k + pressure_nbrs(2,mod(n  ,6)+1); 
        j_nbr_next = j + pressure_nbrs(1,mod(n+1,6)+1); 
        k_nbr_next = k + pressure_nbrs(2,mod(n+1,6)+1);

        % if any index is zero, then 
        % the pressure term does not include this value
        if j_nbr_next && k_nbr_next && j_nbr && k_nbr
            pressure_term = pressure_term + (p_0/6) * cross(X(:,j_nbr,k_nbr) - X(:,j,k), X(:,j_nbr_next,k_nbr_next) - X(:,j,k));                     
        end 

    end 

    u_tangent_term = zeros(3,1); 
    for j_nbr = [j-1,j+1]

        k_nbr = k; 

        if j_nbr == 0
            X_nbr = left_papillary;
            R_nbr = left_papillary;
        else 
            X_nbr = X(:,j_nbr,k_nbr); 
            R_nbr = R(:,j_nbr,k_nbr); 
        end 

        u_tangent_term = u_tangent_term + tension_linear(X(:,j,k),X_nbr,R(:,j,k),R_nbr,alpha,ref_frac) * (X_nbr - X(:,j,k));

    end 

    v_tangent_term = zeros(3,1); 
    for k_nbr = [k-1,k+1]

        j_nbr = j; 

        if k_nbr == 0
            X_nbr = right_papillary;
            R_nbr = right_papillary;
        else 
            X_nbr = X(:,j_nbr,k_nbr); 
            R_nbr = R(:,j_nbr,k_nbr); 
        end

        v_tangent_term = v_tangent_term + tension_linear(X(:,j,k),X_nbr,R(:,j,k),R_nbr,beta,ref_frac) * (X_nbr - X(:,j,k));
    end 

    F = pressure_term + u_tangent_term + v_tangent_term;

else 
    error('requesting difference equations not in the triangle'); 
end

    


