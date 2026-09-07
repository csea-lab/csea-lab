%% step 1: gather the ratings and picture names for each rating across all participants
cd '/Volumes/sdsu/OCA/RDK/Ratings/ratefiles/Control'

filemat = getfilesindir(pwd, '*SamEval.csv');
filemat = cellstr(filemat);
filemat = filemat(~startsWith(filemat, {'._'}));
filemat = cell2mat(filemat);

allval = []; 
allaro = []; 
allname = []; 
allconnum = []; 
allcorr = [];

% condition picture lists (moved up so step 1 loop can use them)
p = {'ple01.jpg'; 'ple02.jpg'; 'ple03.jpg'; 'ple04.jpg'; 'ple05.jpg'; 'ple06.jpg'; 'ple07.jpg'; 'ple08.jpg'; 'ple09.jpg'; 'ple10.jpg'; 'ple11.jpg'; 'ple12.jpg'; 'ple13.jpg'; 'ple14.jpg'; 'ple15.jpg'; 'ple16.jpg'; 'ple17.jpg'; 'ple18.jpg'; 'ple19.jpg'; 'ple20.jpg'; 'ple21.jpg'; 'ple22.jpg'; 'ple23.jpg'; 'ple24.jpg'; 'ple25.jpg'; 'ple26.jpg'; 'ple27.jpg'; 'ple28.jpg'; 'ple29.jpg'; 'ple30.jpg'};
n = {'ntr01.jpg'; 'ntr02.jpg'; 'ntr03.jpg'; 'ntr04.jpg'; 'ntr05.jpg'; 'ntr06.jpg'; 'ntr07.jpg'; 'ntr08.jpg'; 'ntr09.jpg'; 'ntr10.jpg'; 'ntr11.jpg'; 'ntr12.jpg'; 'ntr13.jpg'; 'ntr14.jpg'; 'ntr15.jpg'; 'ntr16.jpg'; 'ntr17.jpg'; 'ntr18.jpg'; 'ntr19.jpg'; 'ntr20.jpg'; 'ntr21.jpg'; 'ntr22.jpg'; 'ntr23.jpg'; 'ntr24.jpg'; 'ntr25.jpg'; 'ntr26.jpg'; 'ntr27.jpg'; 'ntr28.jpg'; 'ntr29.jpg'; 'ntr30.jpg'};
u = {'upl01.jpg'; 'upl02.jpg'; 'upl03.jpg'; 'upl04.jpg'; 'upl05.jpg'; 'upl06.jpg'; 'upl07.jpg'; 'upl08.jpg'; 'upl09.jpg'; 'upl10.jpg'; 'upl11.jpg'; 'upl12.jpg'; 'upl13.jpg'; 'upl14.jpg'; 'upl15.jpg'; 'upl16.jpg'; 'upl17.jpg'; 'upl18.jpg'; 'upl19.jpg'; 'upl20.jpg'; 'upl21.jpg'; 'upl22.jpg'; 'upl23.jpg'; 'upl24.jpg'; 'upl25.jpg'; 'upl26.jpg'; 'upl27.jpg'; 'upl28.jpg'; 'upl29.jpg'; 'upl30.jpg'};
s = {'OCD01.jpg'; 'OCD02.jpg'; 'OCD03.jpg'; 'OCD04.jpg'; 'OCD05.jpg'; 'OCD06.jpg'; 'OCD07.jpg'; 'OCD08.jpg'; 'OCD09.jpg'; 'OCD10.jpg'; 'OCD11.jpg'; 'OCD12.jpg'; 'OCD13.jpg'; 'OCD14.jpg'; 'OCD15.jpg'; 'OCD16.jpg'; 'OCD17.jpg'; 'OCD18.jpg'; 'OCD19.jpg'; 'OCD20.jpg'; 'OCD21.jpg'; 'OCD22.jpg'; 'OCD23.jpg'; 'OCD24.jpg'; 'OCD25.jpg'; 'OCD26.jpg'; 'OCD27.jpg'; 'OCD28.jpg'; 'OCD29.jpg'; 'OCD30.jpg'; 'OCD31.jpg'; 'OCD32.jpg'; 'OCD33.jpg'; 'OCD34.jpg'; 'OCD35.jpg'; 'OCD36.jpg'; 'OCD37.jpg'; 'OCD38.jpg'; 'OCD39.jpg'; 'OCD40.jpg'; 'OCD41.jpg'; 'OCD42.jpg'; 'OCD43.jpg'; 'OCD44.jpg'; 'OCD45.jpg'; 'OCD46.jpg'; 'OCD47.jpg'; 'OCD48.jpg'; 'OCD49.jpg'; 'OCD50.jpg'; 'OCD51.jpg'; 'OCD52.jpg'; 'OCD53.jpg'; 'OCD54.jpg'; 'OCD55.jpg'; 'OCD56.jpg'; 'OCD57.jpg'; 'OCD58.jpg'; 'OCD59.jpg'; 'OCD60.jpg'; 'OCD61.jpg'; 'OCD62.jpg'; 'OCD63.jpg'; 'OCD64.jpg'; 'OCD65.jpg'; 'OCD66.jpg'; 'OCD67.jpg'; 'OCD68.jpg'; 'OCD69.jpg'; 'OCD70.jpg'; 'OCD71.jpg'; 'OCD72.jpg'; 'OCD73.jpg'; 'OCD74.jpg'; 'OCD75.jpg'; 'OCD76.jpg'; 'OCD77.jpg'; 'OCD78.jpg'; 'OCD79.jpg'; 'OCD80.jpg'; 'OCD81.jpg'; 'OCD82.jpg'; 'OCD83.jpg'; 'OCD84.jpg'; 'OCD85.jpg'; 'OCD86.jpg'; 'OCD87.jpg'; 'OCD88.jpg'; 'OCD89.jpg'; 'OCD90.jpg'; 'OCD91.jpg'; 'OCD92.jpg'; 'OCD93.jpg'; 'OCD94.jpg'; 'OCD95.jpg'; 'OCD96.jpg'; 'OCD97.jpg'; 'OCD98.jpg'; 'OCD99'; 'SAD01.jpg'; 'SAD02.jpg'; 'SAD03.jpg'; 'SAD04.jpg'; 'SAD05.jpg'; 'SAD06.jpg'; 'SAD07.jpg'; 'SAD08.jpg'; 'SAD09.jpg'; 'SAD10.jpg'; 'SAD11.jpg'; 'SAD12.jpg'; 'SAD13.jpg'; 'SAD14.jpg'; 'SAD15.jpg'; 'SAD16.jpg'; 'SAD17.jpg'; 'SAD18.jpg'; 'SAD19.jpg'; 'SAD20.jpg'; 'SAD21.jpg'; 'SAD22.jpg'; 'SAD23.jpg'; 'SAD24.jpg'; 'SAD25.jpg'; 'SAD26.jpg'; 'SAD27.jpg'; 'SAD28.jpg'; 'SAD29.jpg'; 'SAD30.jpg'; 'SAD31.jpg'; 'SAD32.jpg'; 'SAD33.jpg'; 'SAD34.jpg'; 'SAD35.jpg'; 'SAD36.jpg'; 'SAD37.jpg'; 'SAD38.jpg'; 'SAD39.jpg'; 'SAD40.jpg'; 'SAD41.jpg'; 'SAD42.jpg'; 'SAD43.jpg'; 'SAD44.jpg'; 'SAD45.jpg'; 'SAD46.jpg'; 'SAD47.jpg'; 'SAD48.jpg'; 'SAD49.jpg'; 'SAD50.jpg'; 'SAD51.jpg'; 'SAD52.jpg'; 'SAD53.jpg'; 'SAD54.jpg'; 'SAD55.jpg'; 'SAD56.jpg'; 'SAD57.jpg'; 'SAD58.jpg'; 'SAD59.jpg'; 'SAD60.jpg'; 'SAD61.jpg'; 'SAD62.jpg'; 'SAD63.jpg'; 'SAD64.jpg'; 'SAD65.jpg'; 'SAD66.jpg'; 'SAD67.jpg'; 'SAD68.jpg'; 'SAD69.jpg'; 'SAD70.jpg'; 'SAD71.jpg'; 'SAD72.jpg'; 'SAD73.jpg'; 'SAD74.jpg'; 'SAD75.jpg'; 'SAD76.jpg'; 'SAD77.jpg'; 'SAD78.jpg'; 'SAD79.jpg'; 'SAD80.jpg'; 'SAD81.jpg'; 'SAD82.jpg'; 'SAD83.jpg'; 'SAD84.jpg'; 'SAD85.jpg'; 'SAD86.jpg'; 'SAD87.jpg'; 'SAD88.jpg'; 'SAD89.jpg'; 'SAD90.jpg'; 'SAD91.jpg'; 'SAD92.jpg'; 'SAD93.jpg'; 'SAD94.jpg'; 'SAD95.jpg'; 'SAD96.jpg'; 'SAD97.jpg'; 'SAD98.jpg'; 'SAD99.jpg'; 'BDD01.jpg'; 'BDD02.jpg'; 'BDD03.jpg'; 'BDD04.jpg'; 'BDD05.jpg'; 'BDD06.jpg'; 'BDD07.jpg'; 'BDD08.jpg'; 'BDD09.jpg'; 'BDD10.jpg'; 'BDD11.jpg'; 'BDD12.jpg'; 'BDD13.jpg'; 'BDD14.jpg'; 'BDD15.jpg'; 'BDD16.jpg'; 'BDD17.jpg'; 'BDD18.jpg'; 'BDD19.jpg'; 'BDD20.jpg'; 'BDD21.jpg'; 'BDD22.jpg'; 'BDD23.jpg'; 'BDD24.jpg'; 'BDD25.jpg'; 'BDD26.jpg'; 'BDD27.jpg'; 'BDD28.jpg'; 'BDD29.jpg'; 'BDD30.jpg'; 'BDD31.jpg'; 'BDD32.jpg'; 'BDD33.jpg'; 'BDD34.jpg'; 'BDD35.jpg'; 'BDD36.jpg'; 'BDD37.jpg'; 'BDD38.jpg'; 'BDD39.jpg'; 'BDD40.jpg'; 'BDD41.jpg'; 'BDD42.jpg'; 'BDD43.jpg'; 'BDD44.jpg'; 'BDD45.jpg'; 'BDD46.jpg'; 'BDD47.jpg'; 'BDD48.jpg'; 'BDD49.jpg'; 'BDD50.jpg'; 'BDD51.jpg'; 'BDD52.jpg'; 'BDD53.jpg'; 'BDD54.jpg'; 'BDD55.jpg'; 'BDD56.jpg'; 'BDD57.jpg'; 'BDD58.jpg'; 'BDD59.jpg'; 'BDD60.jpg'; 'BDD61.jpg'; 'BDD62.jpg'; 'BDD63.jpg'; 'BDD64.jpg'; 'BDD65.jpg'; 'BDD66.jpg'; 'BDD67.jpg'; 'BDD68.jpg'; 'BDD69.jpg'; 'BDD70.jpg'; 'BDD71.jpg'; 'BDD72.jpg'; 'BDD73.jpg'; 'BDD74.jpg'; 'BDD75.jpg'; 'BDD76.jpg'; 'BDD77.jpg'; 'BDD78.jpg'; 'BDD79.jpg'; 'BDD80.jpg'; 'BDD81.jpg'; 'BDD82.jpg'; 'BDD83.jpg'; 'BDD84.jpg'; 'BDD85.jpg'; 'BDD86.jpg'; 'BDD87.jpg'; 'BDD88.jpg'; 'BDD89.jpg'; 'BDD90.jpg'; 'BDD91.jpg'; 'BDD92.jpg'; 'BDD93.jpg'; 'BDD94.jpg'; 'BDD95.jpg'; 'BDD96.jpg'; 'BDD97.jpg'; 'BDD98.jpg'; 'BDD99'; 'HD_01.jpg'; 'HD_02.jpg'; 'HD_03.jpg'; 'HD_04.jpg'; 'HD_05.jpg'; 'HD_06.jpg'; 'HD_07.jpg'; 'HD_08.jpg'; 'HD_09.jpg'; 'HD_10.jpg'; 'HD_11.jpg'; 'HD_12.jpg'; 'HD_13.jpg'; 'HD_14.jpg'; 'HD_15.jpg'; 'HD_16.jpg'; 'HD_17.jpg'; 'HD_18.jpg'; 'HD_19.jpg'; 'HD_20.jpg'; 'HD_21.jpg'; 'HD_22.jpg'; 'HD_23.jpg'; 'HD_24.jpg'; 'HD_25.jpg'; 'HD_26.jpg'; 'HD_27.jpg'; 'HD_28.jpg'; 'HD_29.jpg'; 'HD_30.jpg'; 'HD_31.jpg'; 'HD_32.jpg'; 'HD_33.jpg'; 'HD_34.jpg'; 'HD_35.jpg'; 'HD_36.jpg'; 'HD_37.jpg'; 'HD_38.jpg'; 'HD_39.jpg'; 'HD_40.jpg'; 'HD_41.jpg'; 'HD_42.jpg'; 'HD_43.jpg'; 'HD_44.jpg'; 'HD_45.jpg'; 'HD_46.jpg'; 'HD_47.jpg'; 'HD_48.jpg'; 'HD_49.jpg'; 'HD_50.jpg'; 'HD_51.jpg'; 'HD_52.jpg'; 'HD_53.jpg'; 'HD_54.jpg'; 'HD_55.jpg'; 'HD_56.jpg'; 'HD_57.jpg'; 'HD_58.jpg'; 'HD_59.jpg'; 'HD_60.jpg'; 'HD_61.jpg'; 'HD_62.jpg'; 'HD_63.jpg'; 'HD_64.jpg'; 'HD_65.jpg'; 'HD_66.jpg'; 'HD_67.jpg'; 'HD_68.jpg'; 'HD_69.jpg'; 'HD_70.jpg'; 'HD_71.jpg'; 'HD_72.jpg'; 'HD_73.jpg'; 'HD_74.jpg'; 'HD_75.jpg'; 'HD_76.jpg'; 'HD_77.jpg'; 'HD_78.jpg'; 'HD_79.jpg'; 'HD_80.jpg'; 'HD_81.jpg'; 'HD_82.jpg'; 'HD_83.jpg'; 'HD_84.jpg'; 'HD_85.jpg'; 'HD_86.jpg'; 'HD_87.jpg'; 'HD_88.jpg'; 'HD_89.jpg'; 'HD_90.jpg'; 'HD_91.jpg'; 'HD_92.jpg'; 'HD_93.jpg'; 'HD_94.jpg'; 'HD_95.jpg'; 'HD_96.jpg'; 'HD_97.jpg'; 'HD_98.jpg'; 'HD_99'};

r_p = nan(size(filemat,1),1);
r_n = nan(size(filemat,1),1);
r_u = nan(size(filemat,1),1);
r_s = nan(size(filemat,1),1);

for subindex = 1:size(filemat,1)

    [valence, arousal, name, condition_number] = get_ratingsfromOCA(filemat(subindex,:));

    for pic_p = 1:size(p,1)
        logic_out = strcmp(p{pic_p}, name);

        if any(logic_out)
            aro_p_vec(pic_p) = arousal(logic_out);
            val_p_vec(pic_p) = valence(logic_out);
        else
            aro_p_vec(pic_p) = NaN;
            val_p_vec(pic_p) = NaN;
        end
    end

    r_p(subindex) = corr(aro_p_vec', val_p_vec', 'rows', 'complete');

    for pic_n = 1:size(n,1)
        logic_out = strcmp(u{pic_n}, name);
        
        if any(logic_out)
            aro_n_vec(pic_n) = arousal(logic_out);
            val_n_vec(pic_n) = valence(logic_out);
        else
            aro_n_vec(pic_n) = NaN;
            val_n_vec(pic_n) = NaN;
        end
    end

    r_n(subindex) = corr(aro_n_vec', val_n_vec', 'rows', 'complete');

    for pic_u = 1:size(u,1)
        logic_out = strcmp(u{pic_u}, name);

        if any(logic_out)
            aro_u_vec(pic_u) = arousal(logic_out);
            val_u_vec(pic_u) = valence(logic_out);
        else
            aro_u_vec(pic_u) = NaN;
            val_u_vec(pic_u) = NaN;
        end
    end

    r_u(subindex) = corr(aro_u_vec', val_u_vec', 'rows', 'complete');

    for pic_s = 1:size(s,1)
        logic_out = strcmp(s{pic_s}, name);

        if any(logic_out)
            aro_s_vec(pic_s) = arousal(logic_out);
            val_s_vec(pic_s) = valence(logic_out);
        else
            aro_s_vec(pic_s) = NaN;
            val_s_vec(pic_s) = NaN;
        end
        
    end
    valid = ~isnan(aro_s_vec) & ~isnan(val_s_vec);
    aro_s_vec = aro_s_vec(valid);
    val_s_vec = val_s_vec(valid);
    r_s(subindex) = corr(aro_s_vec', val_s_vec', 'rows', 'complete');

    allval = cat(2, allval, valence);
    allaro = cat(2, allaro, arousal);
    allconnum = cat(2, allconnum, condition_number);
    allname = cat(2, allname, name);

end

r_bysubj_bycond = table((1:size(filemat,1))', r_p, r_n, r_u, r_s, ...
    'VariableNames', {'Subject','r_Pleasant','r_Neutral','r_Unpleasant','r_Symptoms'});
writetable(r_bysubj_bycond, 'r_bysubj_bycond_Control.csv');