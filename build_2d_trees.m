function [chordae_flat] = build_2d_trees(params, left_papillary_flat, right_papillary_flat, tree_frac, filter_parmas)
    % 
    % Creates and returns two binary trees of chordae 
    % The binary trees are fully balanced by definition
    % N, the number of internal nodes, must be a power of two  
    % 
    % Input 
    % params                  
    % left_papillary_flat     Left papillary muscle location 
    % right_papillary_flat    Right papillary muscle location 
    % tree_frac               Coefficient of parent in weighted sum for placement of parents
    %                          (tree_frac)*p + 0.5*(1-tree_frac)*l + 0.5*(1-tree_frac)*r
    % 
    
    [X,alpha,beta,N,p_0,R,ref_frac] = unpack_params(params);  
   
    n_tree = log2(N);
    n_leaves = N; 
    
    if abs(n_tree - round(n_tree)) > eps 
        error('must use a power of two'); 
    end 
    
    if n_tree < 2
        error('weird boundary errors possible on such a small tree'); 
    end 
    
    if ~((0 < tree_frac) && (tree_frac < 1))
        error('multiplier on tree position must be between zero and one'); 
    end 

    total_len = 2^(n_tree+1) - 1; 
    max_internal = 2^(n_tree) - 1;     % last node that is not a leaf 
    
    C_left_flat = zeros(2,total_len); 
    C_right_flat = zeros(2,total_len); 
        
    % initialize the left boundary conditions from the leaflet 
    for i=1:n_leaves
        C_left_flat (:, max_internal + i)  = cone_filter_inv(X(:,1,i), filter_parmas); 
        C_right_flat(:, max_internal + i)  = cone_filter_inv(X(:,i,1), filter_parmas); 
    end 
        
    for i=1:max_internal

        p = get_parent(C_left_flat, i, left_papillary_flat); 
        
        if ~is_leaf(i, max_internal)
            l = get_left__descendant(C_left_flat, i, max_internal); 
            r = get_right_descendant(C_left_flat, i, max_internal); 
            C_left_flat(:,i) = (tree_frac)*p + 0.5*(1-tree_frac)*l + 0.5*(1-tree_frac)*r; 
        end
        
        p = get_parent(C_right_flat, i, right_papillary_flat); 
        
        if ~is_leaf(i, max_internal)
            l = get_left__descendant(C_right_flat, i, max_internal); 
            r = get_right_descendant(C_right_flat, i, max_internal); 
            C_right_flat(:,i) = (tree_frac)*p + 0.5*(1-tree_frac)*l + 0.5*(1-tree_frac)*r;  
        end 
        
    end 
    
    % do not actually want the leaves (which are copied )
    C_left_flat = C_left_flat(:,1:max_internal); 
    C_right_flat = C_right_flat(:,1:max_internal); 
    
    % set up return structure 
    chordae_flat.C_left_flat           = C_left_flat; 
    chordae_flat.C_right_flat          = C_right_flat; 
    chordae_flat.left_papillary_flat   = left_papillary_flat; 
    chordae_flat.right_papillary_flat  = right_papillary_flat; 

end 



function leaf = is_leaf(i, max_internal)
% checks whether node at indenx i is leaf 
% 
    if i > max_internal
        leaf = true; 
    else 
        leaf = false; 
    end 
end 


function p = get_parent(C, i, papillary)
% returns parent coordinates
% if i==1 then returns papillary 

    if i==1
        p = papillary; 
    else 
        p = C(:,floor(i/2));  
    end 
end 


function r = get_right_descendant(C, i, max_internal)
% 
% finds the right most leaf which is a descendant of the node i 
% 
     
    if is_leaf(i, max_internal)
        error('trying to get descendants on a leaf'); 
    end 
    
    j = 2*i + 1;
    while ~is_leaf(j, max_internal)
        j = 2*j + 1; 
    end 
    
    r = C(:,j); 
end 


function l = get_left__descendant(C, i, max_internal)
% 
% finds the left most leaf which is a descendant of the node i 
% 
     
    if is_leaf(i, max_internal)
        error('trying to get descendants on a leaf'); 
    end 
    
    j = 2*i;
    while ~is_leaf(j, max_internal)
        j = 2*j; 
    end 
    
    l = C(:,j);
end 

















