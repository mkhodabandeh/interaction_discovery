path = '/cs/vml2/mkhodaba/results/CVPR2015/CollectiveActivity/13-Nov-2014/';
%res_names = dir([path '/mmca_virat_1_0.4_1.1_5_1_1_0_10_4_4_1_*.mat']);
%res_names = dir([path '/mmca_virat_5_0.4_1.6_5_0_1_0_5_4_4_1_*.mat']);
%res_names = dir(['/cs/vml2/mkhodaba/results/CVPR2015/VIRAT/12-Nov-2014/mmca_virat_0_0.4_1.6_5_1_1_0_10_2_8_1_*.mat']);
res_names = dir(['/cs/vml2/mkhodaba/results/CVPR2015/CollectiveActivity/13-Nov-2014/mmca_ca_1_0.6_1.4_5_1_4_0_15_5_5_1_*.mat']);
max_name = '';
max_pa = 0;
for i = 1:length(res_names)
    load([path res_names(i).name]);
    results.pa;     
    %res_names(i).name
    if max_pa < results.pa
        max_name = res_names(i).name;
        max_pa = results.pa;
    end
end
max_pa
max_name