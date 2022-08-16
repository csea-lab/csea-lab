

% first, the positions of the CS+s
pos1 =  38:48;
pos2 = [8:15,49:50];
pos3 = [1:7,51];
pos4 = 16:26;
pos5 = 27:37;

%% set file matrices
filemat_pow3 = getfilesindir(pwd, '*.pow3.mat');
% make sure it has 561 files
filemat_pow3(1:11:end,:) = [ ]; 
% now it should have 510 files :-) 51 people and 10 conditions

%% Make a Nina matrix

for subject = 1:51
     for condition = 1:10
         index = (subject * 10 - 10) + condition;
         a= load(filemat_pow3(index,:)); allmat3d(:, :, :, condition, subject) = a.eyelinkout; 
     end
end

%% now rotate the positions, so they are aliogned to being 3 in acquisition = CS+

        rotatemathab(:, :, :, [ 1 2 3 4 5], pos1) = diffmat3d(:, [4 5 1 2 3], pos1); 
        rotatemathab(:, :, :, [ 1 2 3 4 5], pos2) = diffmat3d(:, [5 1 2 3 4], pos2); 
        rotatemathab(:, :, :, [ 1 2 3 4 5], pos3) = diffmat3d(:, [ 1 2 3 4 5], pos3); 
        rotatemathab(:, :, :, [ 1 2 3 4 5], pos4) = diffmat3d(:, [ 2 3 4 5 1], pos4); 
        rotatemathab(:, :, :, [ 1 2 3 4 5], pos5) = diffmat3d(:, [ 3 4 5 1 2], pos5);
        
        rotatematacq(:, :, :, [ 1 2 3 4 5], pos1) = diffmat3d(:, [4 5 1 2 3]+5, pos1); 
        rotatematacq(:, :, :, [ 1 2 3 4 5], pos2) = diffmat3d(:, [5 1 2 3 4]+5, pos2); 
        rotatematacq(:, :, :, [ 1 2 3 4 5], pos3) = diffmat3d(:, [ 1 2 3 4 5]+5, pos3); 
        rotatematacq(:, :, :, [ 1 2 3 4 5], pos4) = diffmat3d(:, [ 2 3 4 5 1]+5, pos4); 
        rotatematacq(:, :, :, [ 1 2 3 4 5], pos5) = diffmat3d(:, [ 3 4 5 1 2]+5, pos5);
  
   


