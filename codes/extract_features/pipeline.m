
raw_data_address = '/cs/vml2/mkhodaba/data/AutoTrackerManuallyInitialized/';
data_address = '/cs/vml2/mkhodaba/data/CVPR2015/';
%data_path = '/cs/vml2/mkhodaba/data/AutoTrackerManuallyInitialized/';

%scenes = ['0000';'0001'; '0102'; '0502'; '0401'] ;
scenes = ['0001'] ;
scene = '0001';
tracklet_length = 6*30
small_parts = 4;
tracklet_clip_ratio = 3; %tracklet = 3*clip/2 => 12

person_very_close_threshold = 6;
person_near_threshold = 20;
vehicle_very_close_threshold = 13;
vehicle_near_threshold = 40;
number_of_small_parts=4;


extract_velocity
nearest_obj_to_tracklet
extract_dist_to_nearest
merge_features
prepare_latent
