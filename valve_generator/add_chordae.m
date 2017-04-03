function leaflet = add_chordae(leaflet, tree_idx)
    % 
    % Adds a chordae data structure to the current parameters 
    % 
    % Input: 
    %     leaflet     Current leaflet data structures 
    % 
    % Output: 
    %     chordae     Chrodae tree data structure            
    % 

    % unpack relevant parameters 
    tree_frac           = leaflet.tree_frac; 
    left_papillary      = leaflet.left_papillary;
    right_papillary     = leaflet.right_papillary;
    X                   = leaflet.X; 
    k_multiplier        = leaflet.k_multiplier; 
    k_0                 = leaflet.k_0;
    chordae             = leaflet.chordae; 
    free_edge_idx       = chordae(tree_idx).free_edge_idx; 
    
    [n_leaves, m] = size(free_edge_idx);  

    if m ~= 2
        error('free edge indices must be an N by 2 array'); 
    end 
        
    n_tree = log2(n_leaves);

    if abs(n_tree - round(n_tree)) > eps 
        error('must use a power of two'); 
    end 
    
    if n_tree < 2
        warning('weird boundary errors possible on such a small tree'); 
    end 

    if ~((0 < tree_frac) && (tree_frac < 1))
        error('multiplier on tree position must be between zero and one'); 
    end 

    
    total_len = 2^(n_tree+1) - 1; 
    max_internal = 2^(n_tree) - 1;     % last node that is not a leaf 
            
    if leaflet.num_trees ~= 2
        error('not implemented for numbers other than 2 trees'); 
    end 
    
    if tree_idx == 1 
        warning('Fix papillary placement in chordae initialize'); 
        chordae(tree_idx).root = left_papillary; 
    elseif tree_idx == 2
        warning('Fix papillary placement in chordae initialize'); 
        chordae(tree_idx).root = right_papillary; 
    else 
        error('not implemented'); 
    end 
    
    % initialize the left boundary conditions from the leaflet     
    chordae(tree_idx).C = zeros(3,total_len);   

    % Set the free edge according to array of indicies 
    for i=1:n_leaves 
        j = free_edge_idx(i,1); 
        k = free_edge_idx(i,2); 
        chordae(tree_idx).C(:, max_internal + i)  = X(:,j,k);
    end 
     
    
    for i=1:max_internal

        p = get_parent(chordae(tree_idx).C, i, chordae(tree_idx).root); 

        if ~is_leaf(i, max_internal)
            l = get_left__descendant(chordae(tree_idx).C, i, max_internal); 
            r = get_right_descendant(chordae(tree_idx).C, i, max_internal); 
            chordae(tree_idx).C(:,i) = (tree_frac)*p + 0.5*(1-tree_frac)*l + 0.5*(1-tree_frac)*r; 
        end

    end 
    
    
    % do not actually want the leaves (which are copied)
    % remove them 
    chordae(tree_idx).C = chordae(tree_idx).C(:,1:max_internal); 
   
    % there are max_internal points on the tree 
    % leaves are not included as they are part of the leaflet 
    [m max_internal] = size(chordae(tree_idx).C); 
    
    % this parameter is the number of (not included) leaves in the tree
    NN = max_internal + 1; 
    
    % sanity check in building a balanced tree 
    n_tree = log2(NN);
    if abs(n_tree - round(n_tree)) > eps 
        error('must use a power of two'); 
    end 
    
    % Set tensions 
    
    % Each keeps parent wise spring constants 
    chordae(tree_idx).k_vals = zeros(max_internal,1); 

    % set spring constant data structures 
    num_at_level = n_leaves/2; 
    idx = max_internal; 

    % constants connecting to the leaflet are inherited
    % first internal constant to the tree is k_multiplier times that 
    k_running = k_multiplier*k_0; 
    while num_at_level >= 1

        for j=1:num_at_level
            chordae(tree_idx).k_vals(idx) = k_running; 
            idx = idx - 1; 
        end 

        k_running = k_running * k_multiplier; 
        num_at_level = num_at_level / 2; 
    end 

    chordae(tree_idx).k_0              = k_0; 
    chordae(tree_idx).k_multiplier     = k_multiplier;
    
    chordae(tree_idx).min_global_idx   = leaflet.total_internal_with_trees + 1; 
    
    leaflet.total_internal_with_trees  = leaflet.total_internal_with_trees + 3*max_internal; 
    
    leaflet.chordae = chordae;
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








