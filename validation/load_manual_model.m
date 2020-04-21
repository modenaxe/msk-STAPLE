function model = load_manual_model(model_name)

% This function collects the geometrical information from models previously
% built
switch model_name
    
    case 'P0_MRI'
        % ground-pelvis
        model.ground_pelvis.parent = eye(4);
        model.ground_pelvis.child = [0.0251285 -0.0426211 0.998775 -14.0039
            0.969727 0.243791 -0.0139943 42.2594
            -0.242896 0.968891 0.047457 76.5794
            0 0 0 1 ];
        
        % hip joint
        model.hip_r.parent = [0.0251285 -0.0426211 0.998775 80.2614
            0.969727 0.243791 -0.0139943 -26.5347
            -0.242896 0.968891 0.047457 18.4479
            0 0 0 1];
        model.hip_r.child = [-0.0311177 -0.00216125 0.999513 80.2614
            0.999514 0.00199894 0.031122 -26.5347
            -0.00206523 0.999996 0.002098 18.4479
            0 0 0 1 ];
        
        % knee joint
        model.knee_r.parent = [
            -0.0311177 -0.00216125 0.999513 68.3561
            0.999514 0.00199894 0.031122 -27.7865
            -0.00206523 0.999996 0.002098 -408.006
            0 0 0 1];
        model.knee_r.child = [-0.0311134 -0.00222134 0.999513 68.3561
            0.999508 0.00392906 0.031122 -27.7865
            -0.00399628 0.99999 0.002098 -408.006
            0 0 0 1 ];

        % ankle_child
        model.ankle_r.parent = [0.483445 0.0104324 0.875313 54.4753
            0.875143 0.0172509 -0.483556 -29.9213
            -0.0201446 0.999797 -0.000790001 -833.87
            0 0 0 1];
        model.ankle_r.child = [0.420897 0.238062 0.875313 54.4753
            0.762691 0.429506 -0.483556 -29.9213
            -0.491068 0.871121 -0.000790001 -833.87
            0 0 0 1 ];
        
        % subtalar_parent
        model.subtalar_r.parent = [-0.991735 0.02126 0.126532 46.3581
            0.121176 -0.168971 0.978144 -54.1741
            0.0421757 0.985392 0.164998 -849.461
            0 0 0 1 ];
        model.subtalar_r.child = model.subtalar_r.parent;


    case 'LHDL'
        %------------
        % LHDL
        %------------
        % ground-pelvis
        model.ground_pelvis.parent = eye(4);
        model.ground_pelvis.child = [ 0.00586843 -0.00671522 -0.99996 237.879
            -0.987773 -0.155824 -0.00475047 180.732
            -0.155786 0.987762 -0.00754756 -360.65
            0 0 0 1 ];
        
        % hip joint
        model.hip_r.parent = [   0.00586196 -0.00671624 -0.99996 143.646
            -0.987773 -0.155824 -0.00474392 243.261
            -0.155786 0.987762 -0.00754756 -432.356
            0 0 0 1 ];
        
        model.hip_r.child = [-0.01564 0.053077 -0.998468 143.646
            -0.992453 -0.122288 0.00904522 243.261
            -0.12162 0.991074 0.054589 -432.356
            0 0 0 1 ];
        
        % knee joint
        model.knee_r.parent =[   -0.01564 0.0800826 -0.996666 122.35
            -0.992453 -0.122488 0.005732 292.326
            -0.12162 0.989234 0.081394 -830.007
            0 0 0 1 ];
        
        model.knee_r.child = [   -0.0079477 0.0812076 -0.996666 122.35
            -0.999606 -0.0274812 0.005732 292.326
            -0.0269241 0.996318 0.081394 -830.007
            0 0 0 1 ];
        
        % ankle joint
        model.ankle_r.parent = [ -0.637314 -0.0901888 -0.765308 122.99
            -0.770298 0.0465357 0.635984 303.239
            -0.0217445 0.994837 -0.0991301 -1235.35
            0 0 0 1 ];
        
        model.ankle_r.child = [  -0.493043 -0.413777 -0.765308 122.99
            -0.678232 -0.368137 0.635984 303.239
            -0.544894 0.832625 -0.0991301 -1235.35
            0 0 0 1 ];
        
        % subtalar
        model.subtalar.parent = [0.943713 0.0834633 -0.320061 132.425
            -0.330754 0.230164 -0.915219 324.57
            -0.00272076 0.969566 0.244814 -1254.95
            0 0 0 1 ];
        
        model.subtalar.child = model.subtalar.parent;
        
        % foot sole (origin is heel)
        model.foot_sole = [  -0.296368 -0.294874 -0.908414 153.112
            -0.810301 -0.425837 0.402587 346.122
            -0.505548 0.855402 -0.112733 -1242.65
            0 0 0 1 ];
        
        %------------
        % TLEM2
        %------------
    case 'TLEM2'
        % ground-pelvis
        model.ground_pelvis.parent = eye(4);
        model.ground_pelvis.child = [   0.00784419 0.0684822 -0.997621 23.0776
            -0.994948 -0.0993184 -0.0146409 -186.844
            -0.100085 0.992696 0.0673572 -246.707
            0 0 0 1 ];
        
        % hip joint
        model.hip_r.parent = [  0.00784228 0.068482 -0.997622 -64.0415
            -0.994948 -0.0993186 -0.014639 -146.823
            -0.100085 0.992696 0.0673572 -318.694
            0 0 0 1 ];
        
        model.hip_r.child = [   -0.420021 0.0220464 -0.907247 -64.0415
            -0.905253 -0.0807123 0.417137 -146.823
            -0.0640296 0.996494 0.0538584 -318.694
            0 0 0 1 ];
        
        % knee joint
        model.knee_r.parent =[  -0.420021 0.045559 -0.90637 -72.1561
            -0.905253 -0.0914993 0.414904 -117.115
            -0.0640296 0.994762 0.079674 -685.472
            0 0 0 1 ];
        
        model.knee_r.child = [  -0.415297 0.0775975 -0.90637 -72.1561
            -0.909602 -0.0218908 0.414904 -117.115
            0.0123543 0.996744 0.079674 -685.472
            0 0 0 1 ];
        
        % ankle joint
        model.ankle_r.parent = [-0.858433 0.0721856 -0.507822 -85.4917
            -0.512078 -0.063699 0.856573 -116.049
            0.0294846 0.995355 0.0916459 -1055.2
            0 0 0 1 ];
        
        model.ankle_r.child = [ -0.701659 -0.499791 -0.507822 -85.4917
            -0.349552 -0.379599 0.856573 -116.049
            -0.620876 0.778533 0.0916459 -1055.2
            0 0 0 1 ];
        
        % subtalar
        model.subtalar.parent = [   0.85085 0.0271256 -0.524708 -73.4383
            -0.524491 -0.0151734 -0.851281 -96.8945
            -0.0310531 0.999517 0.00131688 -1062.14
            0 0 0 1 ];
        
        model.subtalar.child = model.subtalar.parent;
        
        % foot sole (origin is heel)
        model.foot_sole = [-0.600331 -0.740384 -0.30238 -37.3834
            -0.496104 0.0481989 0.866924 -84.1428
            -0.627283 0.670454 -0.396243 -1051.9
            0 0 0 1 ];
        
    case 'JIA'
        
        % ground-pelvis
        % copied from model
        orientation = [-3.09393 -1.53251 1.40085];
        location = [-0.00280573 -0.0961158 -0.128228]*1000;
        model.ground_pelvis.parent = eye(4);
        model.ground_pelvis.child = [orientation2MatRot(orientation), location';
            0 0 0 1 ];
        
        % hip joint
        location_in_parent = [-0.083031 -0.0392821 -0.193028]*1000;
        orientation_in_parent = [-3.09393 -1.53251 1.40085];
        model.hip_r.parent  = [orientation2MatRot(orientation_in_parent), location_in_parent';
            0 0 0 1 ];
        location = [-0.083031 -0.0392821 -0.193028]*1000;
        orientation = [1.9565 -1.31846 0.319387];
        model.hip_r.child  = [orientation2MatRot(orientation), location';
            0 0 0 1 ];
        
        % knee joint
        
        
        location_in_parent = [-0.0524808 -0.00986589 -0.580428]*1000;
        orientation_in_parent = [1.48621 -1.32917 -0.137136];
        model.knee_r.parent  = [orientation2MatRot(orientation_in_parent), location_in_parent';
            0 0 0 1 ];
        location = [-0.0524808 -0.00986589 -0.580428]*1000;
        orientation = [1.48621 -1.32917 -0.0720062];
        model.knee_r.child = [orientation2MatRot(orientation), location';
            0 0 0 1 ];
        
        % ankle joint
        location_in_parent = [-0.0459238 -0.0121816 -0.956864]*1000;
        orientation_in_parent = [-1.35773 -1.36541 -2.87772];
        model.ankle_r.parent = [orientation2MatRot(orientation_in_parent), location_in_parent';
            0 0 0 1 ];
        
        location = [-0.0459238 -0.0121816 -0.956864]*1000;
        orientation = [-1.35773 -1.36541 3.13207];
        model.ankle_r.child = [orientation2MatRot(orientation), location';
            0 0 0 1 ];
        
        % subtalar
        location_in_parent = [-0.0563872 0.000894385 -0.975453]*1000;
        orientation_in_parent = [1.07401 0.344128 0.198357];
        model.subtalar.parent = [orientation2MatRot(orientation_in_parent), location_in_parent';
            0 0 0 1 ];
        model.subtalar.child = model.subtalar.parent;
        
        % foot sole (origin is heel)
        model.foot_sole = [];
    otherwise
        error('Please select a model among ''LHDL'',''TLEM2'' and ''JIA''.')
end
end