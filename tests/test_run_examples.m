%-------------------------------------------------------------------------%
% Copyright (c) 2021 Modenese L.                                          %
%    Author: Luca Modenese                                                %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %

ex_list = dir('../Example*.m');
run_str = '';
for n_ex = 1:numel(ex_list)
    if ~isfolder(ex_list(n_ex).name)
%         evalin('caller', ['run(''',fullfile(ex_list(n_ex).folder, ex_list(n_ex).name),''')'])
        run_str = [run_str, 'run(''',fullfile(ex_list(n_ex).folder, ex_list(n_ex).name),''');'];
        
    else
        continue
    end
end
        
eval(run_str)