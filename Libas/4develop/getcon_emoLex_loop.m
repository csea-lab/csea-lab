%function to loop getcon_emolex

cd '/Volumes/TOSHIBA_EXT/EmoLex/dat'

filemat = getfilesindir(pwd, '*.dat*');

all_results = {};

for subindex = 1:size(filemat, 1)

    filepath = deblank(filemat(subindex, :));

    [medianvecwords, medianvecPwords, wordscorrect, pseudowordscorrect] = getcon_emolex(filepath)
 
    [~, name, ~] = fileparts(filepath)

    all_results{subindex, 1} = name;
    all_results{subindex, 2} = medianvecwords;
    all_results{subindex, 3} = medianvecPwords;
    all_results{subindex, 4} = wordscorrect;
    all_results{subindex, 5} = pseudowordscorrect;
end

T = cell2table(all_results, ...
    'VariableNames', {'Filename', 'MedianVecWords', 'MedianVecPWords', 'WordsCorrect', 'PseudowordsCorrect'});

% Write to CSV
writetable(T, 'emolex_results.csv');