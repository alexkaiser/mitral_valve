function pts = interpolate_valve_ring_points(valve, mesh)

skeleton = valve.skeleton;

if ~isfield(skeleton, 'valve_ring_pts')
    error('must have field valve.skeleton.valve_ring_pts to interpolate points'); 
end

if ~isfield(skeleton, 'ring_center')
    warning('ring_center not found, using origin');
    ring_center = zeros(3,1); 
else
    ring_center = skeleton.ring_center; 
end 

if ~isfield(skeleton, 'ring_offet_angle')
    warning('setting ring_offset_angle to default value of zero'); 
    ring_offet_angle = 0; 
else 
    ring_offet_angle = skeleton.ring_offset_angle; 
end

% these are the angles at which the points lie
x = skeleton.valve_ring_pts(1,:) - ring_center(1); 
y = skeleton.valve_ring_pts(2,:) - ring_center(2); 

theta = atan2(y,x); 

% center mesh on zero, because atan2 returns results on this interval 
mesh = mod(mesh, 2*pi) - pi; 

theta_three_period = [theta - 2*pi, theta, theta + 2*pi]; 

x_table = [skeleton.valve_ring_pts(1,:), skeleton.valve_ring_pts(1,:), skeleton.valve_ring_pts(1,:)]; 
y_table = [skeleton.valve_ring_pts(2,:), skeleton.valve_ring_pts(2,:), skeleton.valve_ring_pts(2,:)]; 
z_table = [skeleton.valve_ring_pts(3,:), skeleton.valve_ring_pts(3,:), skeleton.valve_ring_pts(3,:)]; 

pts_x = interp1(theta_three_period, x_table, mesh, 'spline')'; 
pts_y = interp1(theta_three_period, y_table, mesh, 'spline')'; 
pts_z = interp1(theta_three_period, z_table, mesh, 'spline')'; 

% pts_x = interp1(theta, skeleton.valve_ring_pts(1,:), mesh, 'spline')'; 
% pts_y = interp1(theta, skeleton.valve_ring_pts(2,:), mesh, 'spline')'; 
% pts_z = interp1(theta, skeleton.valve_ring_pts(3,:), mesh, 'spline')'; 

pts = [pts_x, pts_y, pts_z]; 

