% avgmats
% average .mat files specified in filematin
% this is for averaging struc arrays with many substructures
function [growmat] = avgmats_submats(filematin)

for fileindex = 1 : size(filematin, 1)

    temp =  load(deblank(filematin(fileindex, :)), '-mat');

    fieldnamesTemp = fieldnames(temp);

    tempmat = [];

    for index2= 1:size(fieldnamesTemp, 1)


        if fileindex == 1

            tempmat(index2).data = eval(['temp.' fieldnamesTemp{index2}]);

        else

            growmat(index2).data = eval(['temp.' fieldnamesTemp{index2}]) + growmat(index2).data;

        end

        if fileindex ==1
            growmat = tempmat;
       end


        if fileindex == size(filematin,1)
            growmat(index2).data = growmat(index2).data./size(filematin,1);
        end

    end

end




for  index3= 1:size(fieldnamesTemp, 1)
    growmat(index3).name = fieldnamesTemp{index3};
end
