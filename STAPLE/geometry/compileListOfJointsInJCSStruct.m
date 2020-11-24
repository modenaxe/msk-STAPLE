function joint_list = compileListOfJointsInJCSStruct(JCS)
bodies_list = fields(JCS)';
joint_list = {};
n_unique_j = 1;
for n = 1:length(bodies_list)
    cur_body = bodies_list{n};
    % get a temp joint list
    temp_joint_list = fields(JCS.(cur_body));
    % get the complete joint list available from morphological analysis
    for nj = 1:length(temp_joint_list)
        cur_joint = temp_joint_list{nj};
        if sum(strcmp(cur_joint, joint_list))==0
            % list of unique joints mentioned in JCSs
            joint_list{n_unique_j} = cur_joint;
            n_unique_j = n_unique_j+1;
        end
    end
end