% plotaffectivespace
% reads IAPS ratings (rows = pics, col1 = picnum, col2 = valence, col3 =
% arousal) and plots affective space... 
function [] = plotaffectivespace(picvecfile, ratingfile)

picvec = load(picvecfile);
ratings = load(ratingfile);

figure; axis([1000 10000 1000 10000])
hold on

for picture = 1:length(picvec)
    
    index = find(ratings(:,1) == picvec(picture));
    
    ratings(index,:)
    
    if isempty(index); error('no such iaps ...'), return, end
    
    val(picture) = ratings(index,2);
    aro(picture) = ratings(index,3);
    
    valplot = val(picture) .* 1000;
    aroplot = aro(picture) .* 1000;
   
    picjpg = imread([num2str(picvec(picture)) '.jpg']);
    
    image(aroplot, valplot, flipdim(picjpg,1))
    
    
end
