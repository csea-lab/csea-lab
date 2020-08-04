function checknargin(low, high, numInputs, function_name)
%CHECKNARGIN Check number of input arguments.
%   CHECKNARGIN(LOW,HIGH,NUM_INPUTS,FUNCTION_NAME) checks whether NUM_INPUTS
%   is in the range indicated by LOW and HIGH.  If not, CHECKNARGIN issues a
%   formatted error message using the string in FUNCTION_NAME.
%
%   LOW should be a scalar nonnegative integer.
%
%   HIGH should be a scalar nonnegative integer or Inf.
%
%   FUNCTION_NAME should be a string.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/15 15:57:05 $

% Input arguments are not checked for validity.

if numInputs < low
  msgId = sprintf('Images:%s:tooFewInputs', function_name);
  if low == 1
    msg1 = sprintf('Function %s expected at least 1 input argument', ...
                   function_name);
  else
    msg1 = sprintf('Function %s expected at least %d input arguments', ...
                   function_name, low);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input argument.';
  else
    msg2 = sprintf('but was called instead with %d input arguments.', ...
                   numInputs);
  end
  
  error(msgId, '%s\n%s', msg1, msg2);
  
elseif numInputs > high
  msgId = sprintf('Images:%s:tooManyInputs', function_name);

  if high == 1
    msg1 = sprintf('Function %s expected at most 1 input argument', ...
                   function_name);
  else
    msg1 = sprintf('Function %s expected at most %d input arguments', ...
                   function_name, high);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input argument.';
  else
    msg2 = sprintf('but was called instead with %d input arguments.', ...
                   numInputs);
  end
  
  error(msgId, '%s\n%s', msg1, msg2);
end

  
    
	