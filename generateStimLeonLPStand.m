% Creates stimuli for NatImExperiment
% Synthesize textures from original textures (Pre_Nat_Textures),
% then create phase scrambled and white noise textures from that
% and save all in textures structure


% load original textures
load('PreNatTextures_512.mat')

scF = 2;

for c=1:20
    fprintf('\n')
    for f=1:size(pretex,2)
        tic
        fprintf('texture %d\n',f)
        texPre = pretex(f).nat;
        texSz = 512;
        %synthesize texture from original image
        [texNat foo] = psresynth_LPdiff(texPre,4,4,texSz);
        
        texNat = imresize(texNat,1/scF,'Method','nearest','Antialiasing',1);
        texPre = imresize(texPre,1/scF,'Method','nearest','Antialiasing',1);
        texSz = texSz/scF;
        
        
        
        % phase scramble texture
        %amp spectrum
        ft = abs(fft2(double(texNat)));
        %random phs spectrum
        aft= angle(fft2(randn(texSz)));
        %generate scrambled texture
        texPhs = real(ifft2(ft.*exp(1i*aft)));
        
        
        % match histograms
        texNat = double(texNat);
        gr_lev = sort(texPhs(:));
        
        [foo, idx] = sort(texNat(:));
        [gh, idx2] = sort(idx);
        
        
        texNat = reshape(gr_lev(idx2),texSz,texSz);
        
        
        % generate white noise texture
        r = randperm(texSz^2);
        texWhn = reshape(texNat(r),texSz,texSz);
        
        %have same mean as background color = 127.5 and maximal variance without
        %clipping
        
        texNat = texNat + 127.5;
        texPhs = texPhs + 127.5;
        texWhn = texWhn + 127.5;
        
        textures(f).nat = uint8(texNat); %#ok<AGROW>
        textures(f).phs = uint8(texPhs); %#ok<AGROW>
        textures(f).whn = uint8(texWhn); %#ok<AGROW>
        textures(f).org = uint8(texPre);
        textures(f).source = pretex(f).source; %#ok<AGROW>
        
        toc
        
        
    end
    
    idx = randperm(length(textures));
    textures = textures(idx);
    
    save(sprintf('/mnt/scratch01/leon_textures/StandLPtextures_%d',c),'textures')
end
