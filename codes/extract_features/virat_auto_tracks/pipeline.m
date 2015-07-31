scenes = ['0401']; %['0000';'0001'; '0102'; '0502'; '0401'] ;
tracklet_length = 40
small_parts = 4;
tracklet_clip_ratio = 4; %tracklet = 3*clip/2 => 12

person_very_close_threshold = 6;
person_near_threshold = 20;
vehicle_very_close_threshold = 13;
vehicle_near_threshold = 40;
number_of_small_parts=4;

use_converter = 1;

extract_velocity
nearest_obj_to_tracklet
extract_dist_to_nearest
merge_features
prepare_latent
