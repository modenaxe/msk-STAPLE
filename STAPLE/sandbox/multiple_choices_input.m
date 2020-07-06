GOOD EXAMPLE OF MULTIPLE CHOICES

% myFunc  Example function
% This function is called with any of these syntaxes:
%
%   myFunc(in1, in2) accepts 2 required arguments. 
%   myFunc(in1, in2, in3) also accepts an optional 3rd argument. 
%   myFunc(___, NAME, VALUE) accepts one or more of the following name-value pair 
%       arguments. This syntax can be used in any of the previous syntaxes.
%           * 'NAME1' with logical value
%           * 'NAME2' with 'Default', 'Choice1', or 'Choice2'
function myFunc(reqA,reqB,varargin)
    % Initialize default values
    NV1 = true;
    NV2 = 'Default';
    posA = [];
    
    if nargin > 3
        if rem(nargin,2)
            posA = varargin{1};
            V = varargin(2:end);
        else
            V = varargin;
        end
        for n = 1:2:size(V,2)
            switch V{n}
                case 'Name1'
                    NV1 = V{n+1};
                case 'Name2'
                    NV2 = V{n+1}
                otherwise
                    error('Error.')
            end
        end
    end
end