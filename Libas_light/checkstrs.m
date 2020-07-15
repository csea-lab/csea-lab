function out = checkstrs(in, valid_strings, function_name, ...
                         variable_name, argument_position)
%CHECKSTRS Check validity of option string.
%   OUT = CHECKSTRS(IN,VALID_STRINGS,FUNCTION_NAME,VARIABLE_NAME, ...
%   ARGUMENT_POSITION) checks the validity of the option string IN.  It
%   returns the matching string in VALID_STRINGS in OUT.  CHECKSTRS looks
%   for a case-insensitive nonambiguous match between IN and the strings
%   in VALID_STRINGS.
%
%   VALID_STRINGS is a cell array containing strings.
%
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/15 15:57:05 $

% Except for IN, input arguments are not checked for validity.

checkinput(in, 'char', 'row', function_name, variable_name, argument_position);

idx = strmatch(lower(in), valid_strings);

num_matches = prod(size(idx));

if num_matches == 1
    out = valid_strings{idx};

else
    % Convert valid_strings to a single string containing a space-separated list
    % of valid strings.
    list = '';
    for k = 1:length(valid_strings)
        list = [list ', ' valid_strings{k}];
    end
    list(1:2) = [];

    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   function_name, num2ordinal(argument_position), ...
                   variable_name);
    msg2 = 'to match one of these strings:';

    if num_matches == 0
        msg3 = sprintf('The input, ''%s'', did not match any of the valid strings.', in);
        id = sprintf('Images:%s:unrecognizedStringChoice', function_name);

    else
        msg3 = sprintf('The input, ''%s'', matched more than one valid string.', in);
        id = sprintf('Images:%s:ambiguousStringChoice', function_name);
    end

    error(id,'%s\n%s\n\n  %s\n\n%s', msg1, msg2, list, msg3);
end

     
	