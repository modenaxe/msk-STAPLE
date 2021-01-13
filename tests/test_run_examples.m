%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author: Luca Modenese                                                %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% get list of examples

ex_list = dir('../Example*.m');
run_str = '';
% build string to execute (cannot simply run through them otherwise the
% clear command in the example scripts deletes also ex_list).
for n_ex = 1:numel(ex_list)
    if ~isfolder(ex_list(n_ex).name)
        run_str = [run_str, 'run(''',fullfile(ex_list(n_ex).folder, ex_list(n_ex).name),''');'];
    else
        continue
    end
end
% executes all scripts as listed
eval(run_str)