clear
delete(gcp('nocreate'));
parpool('local');

load hist_percentiles_no_snow.mat
initial_state = {'1231','1251','1281','1301'}; 
m = 2; %corresponds to above intiital state

members_no = 20;

for p = 1:members_no
    p
    if p < 10
        snowdp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SNOWDP/*-',initial_state{m},'.00',num2str(p),'*'));
        runoff_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QRUNOFF/*-',initial_state{m},'.00',num2str(p),'*'));
        precip_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RAIN/*-',initial_state{m},'.00',num2str(p),'*'));
        sw_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SOILWATER_10CM/*-',initial_state{m},'.00',num2str(p),'*'));
        qsoil_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QSOIL/*-',initial_state{m},'.00',num2str(p),'*'));
        qvege_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QVEGE/*-',initial_state{m},'.00',num2str(p),'*'));
        qvegt_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QVEGT/*-',initial_state{m},'.00',num2str(p),'*'));
        tlai_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/TLAI/*-',initial_state{m},'.00',num2str(p),'*'));
        temp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/TREFHT/*-',initial_state{m},'.00',num2str(p),'*'));
        rh_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RHREFHT/*-',initial_state{m},'.00',num2str(p),'*'));

    elseif p >= 10
        snowdp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SNOWDP/*-',initial_state{m},'.0',num2str(p),'*'));
        runoff_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QRUNOFF/*-',initial_state{m},'.0',num2str(p),'*'));
        precip_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RAIN/*-',initial_state{m},'.0',num2str(p),'*'));
        sw_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/SOILWATER_10CM/*-',initial_state{m},'.0',num2str(p),'*'));
        qsoil_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QSOIL/*-',initial_state{m},'.0',num2str(p),'*'));
        qvege_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QVEGE/*-',initial_state{m},'.0',num2str(p),'*'));
        qvegt_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/QVEGT/*-',initial_state{m},'.0',num2str(p),'*'));
        tlai_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/TLAI/*-',initial_state{m},'.0',num2str(p),'*'));
        temp_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/TREFHT/*-',initial_state{m},'.0',num2str(p),'*'));
        rh_dir1 = dir(strcat('/N/project/pfec_hydroclim/CESM2-LE/RHREFHT/*-',initial_state{m},'.0',num2str(p),'*'));

    end

    time_period_selection = [1 2 3 23 24 25 26]; %this allows you to choose particular time periods based on file location
    for i= 1:length(time_period_selection)
        u = time_period_selection(i);
        precip = ncread(strcat(precip_dir1(u).folder,'/',precip_dir1(u).name),'RAIN');
        runoff = ncread(strcat(runoff_dir1(u).folder,'/',runoff_dir1(u).name),'QRUNOFF');
        snowdp = ncread(strcat(snowdp_dir1(u).folder,'/',snowdp_dir1(u).name),'SNOWDP');
        sw = ncread(strcat(sw_dir1(u).folder,'/',sw_dir1(u).name),'SOILWATER_10CM');
        qsoil = ncread(strcat(qsoil_dir1(u).folder,'/',qsoil_dir1(u).name),'QSOIL');
        qvege = ncread(strcat(qvege_dir1(u).folder,'/',qvege_dir1(u).name),'QVEGE');
        qvegt = ncread(strcat(qvegt_dir1(u).folder,'/',qvegt_dir1(u).name),'QVEGT');
        tlai = ncread(strcat(tlai_dir1(u).folder,'/',tlai_dir1(u).name),'TLAI');
        temp = ncread(strcat(temp_dir1(u).folder,'/',temp_dir1(u).name),'TREFHT')-273.15;
        rh = ncread(strcat(rh_dir1(u).folder,'/',rh_dir1(u).name),'RHREFHT');
        et = qsoil + qvege + qvegt;
        vpd = (0.611.*exp((17.3.*temp)./(temp+237.3))) -  (0.611.*exp((17.3.*temp)./(temp+237.3))).*rh./100 ;

        clearvars rh
        parfor x = 1:192
            for y = 1:288
                precip1 = squeeze(precip(y,x,:))*86400;
                runoff1 = squeeze(runoff(y,x,:))*86400;
                runoff1(runoff1 < 0 ) = 0;
                snowdp1 = squeeze(snowdp(y,x,:));
                sw1 = squeeze(sw(y,x,:));
                et1 = squeeze(et(y,x,:))*86400;
                et1(et1 <0) = 0;
                qvegt1 = squeeze(qvegt(y,x,:))*86400;
                tlai1 = squeeze(tlai(y,x,:));
                temp1 = squeeze(temp(y,x,:))-273.15;%  to F
                qsoil1 = squeeze(qsoil(y,x,:))*86400;
                qcan1 = squeeze(qvege(y,x,:))*86400;
                vpd1 = squeeze(vpd(y,x,:));

                snow_find = find(snowdp1 >0);
                precip1(snow_find,:) = NaN;
                runoff1(snow_find,:) = NaN;
                sw1(snow_find,:) = NaN;
                et1(snow_find,:) = NaN;
                qvegt1(snow_find,:) = NaN;
                tlai1(snow_find,:) = NaN;
                temp1(snow_find,:) = NaN;
                qsoil1(snow_find,:) = NaN;
                qcan1(snow_find,:) = NaN;
                vpd1(snow_find,:) = NaN;

                if contains(strcat(precip_dir1(u).folder,'/',precip_dir1(u).name),'20100101-20141231') == 1
                    precip1(790,:) = [];
                    precip2 = reshape(precip1,365,length(precip1)/365);%THE 2010-2014 TIME PERIOD INCLUDES LEAP YEAR; REMOVE
                    runoff1(790,:) = [];
                    runoff2 = reshape(runoff1,365,length(runoff1)/365);
                    sw1(790,:) = [];
                    sw2 = reshape(sw1,365,length(sw1)/365);
                    et1(790,:) = [];
                    et2 = reshape(et1,365,length(et1)/365);
                    qvegt1(790,:) = [];
                    qvegt2 = reshape(qvegt1,365,length(qvegt1)/365);
                    tlai1(790,:) = [];
                    tlai2 = reshape(tlai1,365,length(tlai1)/365);
                    temp1(790,:) = [];
                    temp2 = reshape(temp1,365,length(temp1)/365);
                    qsoil1(790,:) = [];
                    qsoil2 = reshape(qsoil1,365,length(qsoil1)/365);
                    qcan1(790,:) = [];
                    qcan2 = reshape(qcan1,365,length(qcan1)/365);
                    vpd1(790,:) = [];
                    vpd2 = reshape(vpd1,365,length(vpd1)/365);
                elseif contains(strcat(precip_dir1(u).folder,'/',precip_dir1(u).name),'20950101-21001231') == 1
                    precip1(425,:) = [];
                    precip2 = reshape(precip1,365,length(precip1)/365);%Last time period includes leap year; remove
                    runoff1(425,:) = [];
                    runoff2 = reshape(runoff1,365,length(runoff1)/365);
                    sw1(425,:) = [];
                    sw2 = reshape(sw1,365,length(sw1)/365);
                    et1(425,:) = [];
                    et2 = reshape(et1,365,length(et1)/365);
                    qvegt1(425,:) = [];
                    qvegt2 = reshape(qvegt1,365,length(qvegt1)/365);
                    tlai1(425,:) = [];
                    tlai2 = reshape(tlai1,365,length(tlai1)/365);
                    temp1(425,:) = [];
                    temp2 = reshape(temp1,365,length(temp1)/365);
                    qsoil1(425,:) = [];
                    qsoil2 = reshape(qsoil1,365,length(qsoil1)/365);
                    qcan1(425,:) = [];
                    qcan2 = reshape(qcan1,365,length(qcan1)/365);
                    vpd1(425,:) = [];
                    vpd2 = reshape(vpd1,365,length(vpd1)/365);
                else
                    precip2 = reshape(precip1,365,length(precip1)/365);
                    runoff2 = reshape(runoff1,365,length(runoff1)/365);
                    sw2 = reshape(sw1,365,length(sw1)/365);
                    et2 = reshape(et1,365,length(et1)/365);
                    qvegt2 = reshape(qvegt1,365,length(qvegt1)/365);
                    tlai2 = reshape(tlai1,365,length(tlai1)/365);
                    temp2 = reshape(temp1,365,length(temp1)/365);
                    qsoil2 = reshape(qsoil1,365,length(qsoil1)/365);
                    qcan2 = reshape(qcan1,365,length(qcan1)/365);
                    vpd2 = reshape(vpd1,365,length(vpd1)/365);

                end

                runoff3 = cell(30,size(precip2,2));%the 30 is to give cushion
                sw3 = cell(30,size(precip2,2));
                et3 = cell(30,size(precip2,2));
                prior_precip3 = cell(30,size(precip2,2));
                precip4 = cell(30,size(precip2,2));
                qvegt3 = cell(30,size(precip2,2));
                runoff_count3 = cell(30,size(precip2,2));
                prior_runoff3 = cell(30,size(precip2,2));
                tlai3 = cell(30,size(precip2,2));
                temp3 = cell(30,size(precip2,2));
                event_timing3 = cell(30,size(precip2,2));
                qsoil3 = cell(30,size(precip2,2));
                qcan3 = cell(30,size(precip2,2));
                event_timing2 = cell(30,size(precip2,2));
                vpd3 = cell(30,size(precip2,2));

                for t = 1:size(precip2,2)
                    step11 = find(precip2(:,t) >= squeeze(precip_hist_95(y,x,1,p,m))); 

                    if isempty(step11) == 1;
                        step1 = [];
                    else
                        cons_step1 = [5;diff(step11)];%done to elimate consectuive precip days
                        cons_step2 = find(cons_step1>1);
                        step1 = step11(cons_step2,:);
                    end
                    precip3 = precip2(step1,t);

                    for n =1:length(precip3);
                        if step1(n,:)+1 > 362
                            runoff3{n,t} = NaN;
                            precip4{n,t} = NaN;
                            runoff_count3{n,t} = NaN;
                        else
                            runoff3{n,t} = max(runoff2(step1(n,:):step1(n,:)+1,t)); % maximum of runoff on the day of or day after extreme preicp event
                            runoff_count3{n,t} = double(max(runoff2(step1(n,:):step1(n,:)+1,t)) >squeeze(runoff_hist_95(y,x,1,p,m)));
                        end

                        data_find = step1(n,:);
                        data_find(data_find+1>365) = NaN;
                        data_find(data_find<6) = NaN;
                        if isempty(data_find) == 1
                            event_timing2{n,t} = NaN;
                        else
                            event_timing2{n,t} = data_find;
                        end

                        if step1(n,:) < 6
                            sw3{n,t} = NaN;
                            et3{n,t} = NaN;
                            precip4{n,t} = NaN;
                            prior_precip3{n,t} = NaN;
                            qvegt3{n,t} = NaN;
                            prior_runoff3{n,t} = NaN;
                            tlai3{n,t} = NaN;
                            temp3{n,t} = NaN;
                            qsoil3{n,t} = NaN;
                            qcan3{n,t} = NaN;
                            vpd3{n,t} = NaN;

                        else
                            sw3{n,t} = nanmean(sw2(step1(n,:)-5:step1(n,:)-1,t)); %mean of antecedent conditions
                            et3{n,t} = nanmean(et2(step1(n,:)-5:step1(n,:)-1,t));
                            prior_precip3{n,t} = nanmean(precip2(step1(n,:)-5:step1(n,:)-1,t));
                            tlai3{n,t} = nanmean(tlai2(step1(n,:)-5:step1(n,:)-1,t));
                            temp3{n,t} = nanmean(temp2(step1(n,:)-5:step1(n,:)-1,t));
                            precip4{n,t} = precip3(n,:);
                            qvegt3{n,t} = nanmean(qvegt2(step1(n,:)-5:step1(n,:)-1,t));
                            qsoil3{n,t} = nanmean(qsoil2(step1(n,:)-5:step1(n,:)-1,t));
                            qcan3{n,t} = nanmean(qcan2(step1(n,:)-5:step1(n,:)-1,t));
                            vpd3{n,t} = nanmean(vpd2(step1(n,:)-5:step1(n,:)-1,t));
                            prior_runoff3{n,t} =  nanmean(runoff2(step1(n,:)-5:step1(n,:)-1,t));
                        end

                    end


                end

                runoff_all{y,x} = runoff3; %collect all data
                precip_all{y,x} = precip4;
                sw_all{y,x} = sw3;
                et_all{y,x} = et3;
                prior_precip_all{y,x} = prior_precip3;
                qvegt_all{y,x} = qvegt3;
                runoff_count_all{y,x} = runoff_count3;
                prior_runoff_all{y,x} = prior_runoff3;
                tlai_all{y,x} = tlai3;
                temp_all{y,x} = temp3;
                event_timing_all{y,x} = event_timing2;
                qsoil_all{y,x} = qsoil3;
                qcan_all{y,x} = qcan3;
                vpd_all{y,x} = vpd3;
            end
        end
%        name_1 = precip_dir1(u).name;
%        name_1_extract = extractBetween(name_1,"RAIN.",".nc");
%         save(strcat('analysis_',initial_state{m},'_', num2str(p),'_',[name_1_extract{:}],'.mat'),'vpd_all','qcan_all','qsoil_all','event_timing_all','temp_all','tlai_all','prior_runoff_all','runoff_count_all','qvegt_all','runoff_all', 'et_all', 'precip_all', 'sw_all','prior_precip_all','-nocompression')
%         clearvars vpd_all qcan_all qsoil_all event_timing_all temp_all tlai_all prior_runoff_all runoff_all sw_all et_all precip_all qvegt_all qsoil_can_all  runoff_count_all;;
    end
    % savefast test.mat precip_all runoff_all sw_all et_all -v7.3
%     clearvars et runoff precip sw qvegt qsoil_can qvege snowdp qsoil tlai temp vpd
end

