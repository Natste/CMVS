function outputArray = getMatrix(cmv_sample,window,matrix_type)
%% This function maps lux data into a selected matrix type
[data_length,~] = size(cmv_sample);
cmv_sample_norm = getNorm(cmv_sample);
pages = data_length - window + 1

% Get raw pixels
I_raw = zeros(3,3,pages);
for j = 1:data_length
    I_temp = [cmv_sample(j,5) cmv_sample(j,4) cmv_sample(j,6);
              cmv_sample(j,8) cmv_sample(j,7) cmv_sample(j,9);
              cmv_sample(j,2) cmv_sample(j,1) cmv_sample(j,3)];
    
    I_raw(:,:,j) = I_temp;
end

% Get pixels
switch matrix_type
    case 'I'
        I = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample(j-1+k,5) cmv_sample(j-1+k,4) cmv_sample(j-1+k,6);
                    cmv_sample(j-1+k,8) cmv_sample(j-1+k,7) cmv_sample(j-1+k,9);
                    cmv_sample(j-1+k,2) cmv_sample(j-1+k,1) cmv_sample(j-1+k,3)];
                
                I(:,:,j) = I(:,:,j) + I_temp;
            end
            I(:,:,j) = I(:,:,j)/window;
        end
        outputArray = I;
        
    case 'I_norm'
        % Get normalized pixels
        I_norm = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample_norm(j-1+k,5) cmv_sample_norm(j-1+k,4) cmv_sample_norm(j-1+k,6);
                    cmv_sample_norm(j-1+k,8) cmv_sample_norm(j-1+k,7) cmv_sample_norm(j-1+k,9);
                    cmv_sample_norm(j-1+k,2) cmv_sample_norm(j-1+k,1) cmv_sample_norm(j-1+k,3)];
                
                I_norm(:,:,j) = I_norm(:,:,j) + I_temp;
            end
            I_norm(:,:,j) = I_norm(:,:,j)/window;
        end
        outputArray = I_norm;
        
    case 'I_norm_v2'
        I_norm_v2 = zeros(3,3,pages);
        for j = 1:pages
            for k = 1:window
                I_temp = [cmv_sample_norm(j-1+k,7) cmv_sample_norm(j-1+k,8) cmv_sample_norm(j-1+k,9);
                    cmv_sample_norm(j-1+k,4) cmv_sample_norm(j-1+k,5) cmv_sample_norm(j-1+k,6);
                    cmv_sample_norm(j-1+k,1) cmv_sample_norm(j-1+k,2) cmv_sample_norm(j-1+k,3)];
                
                I_norm_v2(:,:,j) = I_norm_v2(:,:,j) + I_temp;
            end
            I_norm_v2(:,:,j) = I_norm_v2(:,:,j)/window;
        end
        outputArray = I_norm_v2;
        
    case 'I_ave_norm'
        I_ave_norm = zeros(3,3,pages);
        idx = 1;
        for j = 1:data_length
            I_temp = [cmv_sample_norm(j,5) cmv_sample_norm(j,4) cmv_sample_norm(j,6);
                cmv_sample_norm(j,8) cmv_sample_norm(j,7) cmv_sample_norm(j,9);
                cmv_sample_norm(j,2) cmv_sample_norm(j,1) cmv_sample_norm(j,3)];
            
            I_ave_norm(:,:,idx) = I_ave_norm(:,:,idx) + I_temp;
            if mod(j,window) == 0
                I_ave_norm(:,:,idx) = I_ave_norm(:,:,idx)/window;
                idx = idx + 1;
            end
        end
        outputArray = I_ave_norm;
        
    otherwise
        fprintf('ERROR')
end

end
