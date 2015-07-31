%In the name of Allah
number_of_frames_per_tracklet = 20;
data_address = '/cs/vml3/mkhodaba/codes/ECCV14/data';
%vid_name = 'ftr_set2';
load([data_address filesep 'UT' filesep vid_name '.mat']);
load(['/cs/vml3/mkhodaba/data/UT/' vid_name '_small.mat']);

obj.nearest_person_bb = cell(number_of_tracklets,1);
obj.nearest_person_dist = cell(number_of_tracklets,1);
obj.nearest_person_id = cell(number_of_tracklets,1);
obj.nearest_person_subject = cell(number_of_tracklets,1);

for i = 1:number_of_tracklets
	nearest_obj_inds = (table(:,3) >= obj.tracklet_frames{i}(1)) & (table(:,3) <= obj.tracklet_frames{i}(end)) & (table(:,8) == 3-obj.subject(i)) & (table(:,1) == obj.track_id(i));
    obj.nearest_person_bb{i} = table(nearest_obj_inds,4:7);
    obj.nearest_person_dist{i} = sqrt(sum((table(nearest_obj_inds, 4:5) - obj.tracklet_bb{i}(:,1:2)).^2,2));
    if obj.sequence_no(i) > 5
        obj.nearest_person_dist{i} = obj.nearest_person_dist{i} / 0.8;
    end
    obj.nearest_person_id{i} = table(nearest_obj_inds, 1);
    obj.nearest_person_subject{i} = table(nearest_obj_inds, 8);
    
end
save([data_address filesep 'UT' filesep vid_name '.mat'], 'obj', 'number_of_tracklets', 'number_of_tracks');
