
diff1 = mat3d_11-mat3d_1;
diff2 = mat3d_12-mat3d_2; 
diff3 = mat3d_13-mat3d_3; 
diff4 = mat3d_14-mat3d_4; 
diff5 = mat3d_15-mat3d_5; 
diff6 = mat3d_16-mat3d_6; 
diff7 = mat3d_17-mat3d_7; 
diff8 = mat3d_18-mat3d_8; 
diff9 = mat3d_19-mat3d_9; 
diff10 = mat3d_20-mat3d_10; 


for time = 1:1401

    repeatmat = cat(3, squeeze(diff1(:, time, :)), squeeze(diff2(:, time, :)), squeeze(diff3(:, time, :)), squeeze(diff4(:, time, :)), ...
        squeeze(diff5(:, time, :)), squeeze(diff6(:, time, :)), squeeze(diff7(:, time, :)), squeeze(diff8(:, time, :)), squeeze(diff9(:, time, :)), squeeze(diff10(:, time, :))); 

    [Fcontmat_linear(:,time),rcontmat,MScont,MScs, dfcs]=contrast_rep(repeatmat,[-9 -7 -5 -3 -1 1 3 5 7 9]); 
    
    if time./100 == round(time./100), fprintf('.'), end

end
