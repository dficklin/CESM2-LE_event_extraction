clear
tic
delete(gcp('nocreate'))
parpool('local')%delete pool if one is already going

members = {'1231','1251','1281','1301'};

%HISTORICAL CALCULATIONS
precip_hist = [];
precip_hist1 = [];
precip_hist2 = [];

snowdp_hist = [];
snowdp_hist1 = [];
snowdp_hist2 = [];

runoff_hist = [];
runoff_hist1 = [];
runoff_hist2 = [];

for p = 1:length(members)
    for i = 1:20
        if i < 10
            snowdp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SNOWDP/*-',members{p},'.00',num2str(i),'*'));
            runoff_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QRUNOFF/*-',members{p},'.00',num2str(i),'*'));
            precip_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RAIN/*-',members{p},'.00',num2str(i),'*'));

        elseif i >= 10
            snowdp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SNOWDP/*-',members{p},'.0',num2str(i),'*'));
            runoff_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QRUNOFF/*-',members{p},'.0',num2str(i),'*'));
            precip_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RAIN/*-',members{p},'.0',num2str(i),'*'));

        end

        snowdp_hist1 = [];
        runoff_hist1 = [];
        precip_hist1 = [];

        for j = 1:3; % only the first three decades for historical calculations -- 1850-1880
            snowdp1 = ncread(strcat(snowdp_dir1(j).folder,'/',snowdp_dir1(j).name),'SNOWDP');
            snowdp_hist1 = cat(3,snowdp_hist1,snowdp1);
            clearvars snowdp1;

            runoff1 = ncread(strcat(runoff_dir1(j).folder,'/',runoff_dir1(j).name),'QRUNOFF');
            runoff_hist1 = cat(3,runoff_hist1,runoff1);
            clearvars runoff1;

            precip1 = ncread(strcat(precip_dir1(j).folder,'/',precip_dir1(j).name),'RAIN');
            precip_hist1 = cat(3,precip_hist1,precip1);
            clearvars precip1;
        end

        parfor x = 1:192
            for y = 1:288
                %SNOWDEPTH
                snow1 = squeeze(snowdp_hist1(y,x,:));%snow depth in meters
                snow1(snow1<0.001) = 0;
                snow_zero = find(snow1 == 0);

                %RUNOFF
                runoff2 = squeeze(runoff_hist1(y,x,:))*86400;%mm/s to mm/d
                runoff2(runoff2<0.01) = 0;
                runoff3 = runoff2(snow_zero,:); %extract all zero snow days -- only looking at rain without snow present
                runoff3(runoff3 == 0) = [];%remove all zeroes - percentiels of aonly rain events

                %RAIN
                precip2 = squeeze(precip_hist1(y,x,:))*86400;%mm/s to mm/d
                precip2(precip2<0.01) = 0;
                precip3 = precip2(snow_zero,:);
                precip3(precip3 == 0) = [];

                runoff_hist2_95(y,x,:,i) =prctile(runoff3,95); 
                precip_hist2_95(y,x,:,i) =prctile(precip3,95); 
            end
        end

        clearvars snowdp_hist1;
        clearvars runoff_hist1;
        clearvars precip_hist1;
    end

    precip_hist_95(:,:,:,:,p) = precip_hist2_95;
    runoff_hist_95(:,:,:,:,p) = runoff_hist2_95;

    clearvars  runoff_hist2_95  precip_hist2_95 p;
end

