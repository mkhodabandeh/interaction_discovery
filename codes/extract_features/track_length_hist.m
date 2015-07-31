objects = dir(fullfile(raw_data_address, 'annotations',scene,'*objects*'));
track_length = [];
for o = 1:length(objects)
    object = objects(o).name;
    table = dlmread(fullfile(raw_data_address,'annotations', scene, object));
    person_ids = unique(table(table(:,8)==1,1));
    for i = 1:length(person_ids);
        track_length = [track_length; table(find(table(:,1)==person_ids(i), 1),2)];
    end
end

objects = dir(fullfile(raw_data_address, 'annotations',scene,'*event*'));
interaction_length = [];
for o = 1:length(objects)
    object = objects(o).name;
    try
        table = dlmread(fullfile(raw_data_address,'annotations', scene, object));
        person_ids = unique(table(table(:,8)==1,1));
        for i = 1:length(person_ids);
            interaction_length = [interaction_length; table(find(table(:,1)==person_ids(i), 1),3)];
        end
    catch e
        e
    end
end
                                                                                                                                                                                                                              