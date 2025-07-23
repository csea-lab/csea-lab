% this is the script to loop the graded response for bingham facebor
% paradigm

    cd '/Users/admin/Desktop/hengle/bingham/All data_2023.10.26' %set to whichever folder contains your dat files
    
    filemat = getfilesindir(pwd, '*.dat')

    for subindex = 1:size(filemat, 1)
    
        filepath = deblank(filemat(subindex, :));
        
       [participant_id, hitrate, falselarmrate, graded_response, percentage_correct] = bingham_behavioral_responses(filepath)

    
    end