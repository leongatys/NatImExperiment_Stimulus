% Generate NatImExperiment Stimuli
%LG 07-29-13

addpath(genpath('/mnt/lab/users/leon/'));

files1  = dir('/mnt/lab/users/leon/leon_textures/sourcetextures/cgtextures/*.jpg');
files2  = dir('/mnt/lab/users/leon/leon_textures/sourcetextures/mayang/*.JPG');
files = [files1; files2];
sources = [ones(length(files1),1); 2*ones(length(files2),1)];



for count = 1 : 20
    for f = 1 : length(files)
        texSz = 512;
        scF = 2;
        fprintf('texture %d',f)
        
        % read files
        if sources(f) == 1
            img = imread(sprintf('cgtextures/%s',files(f).name));
        else
            img = imread(sprintf('mayang/%s',files(f).name));
            img = imresize(img,.5);
        end
        img = rgb2gray(img);
        
        
        % generate texture
        sz = size(img);
        c = ceil(sz/2);
        mask = zeros(sz);
        mask((c(1)-texSz/2+1):(c(1)+texSz/2),(c(2)-texSz/2+1):(c(2)+texSz/2)) = 1;
        
        tex = reshape(img(mask==1),texSz,texSz);
        texPre = double(tex);
        
        tic
        %synthesize texture from original image
        [texNat foo] = psresynth_LPdiff(texPre,4,4,texSz);
        
        texNat = imresize(texNat,1/scF);
        texPre = imresize(texPre,1/scF);
        texSz = texSz/scF;
        
        %match texNat histogram to Gaussian
        mu = 0;
        sig = std(texNat(:));
        x = texNat(:);
        u = tiedrank(x) / numel(x);    % convert to uniform
        x = norminv(u, mu, sig);     % feed through inverse CDF to convert to Gaussian
        texNat = reshape(x, texSz, texSz);
        ndx = find(texNat == Inf); %get rid of Inf value
        s = sort(texNat(:));
        texNat(ndx) = s(end-1);
        
        
        % phase scramble texture
        %amp spectrum
        ft = abs(fft2(double(texNat)));
        %random phs spectrum
        aft= angle(fft2(randn(texSz)));
        %generate scrambled texture
        texPhs = real(ifft2(ft.*exp(1i*aft)));
        
        
        % generate white noise texture
        r = randperm(texSz^2);
        texWhn = reshape(texNat(r),texSz,texSz);
        
        %have same mean as background color = 127.5
        texNat = texNat + 127.5;
        texPhs = texPhs + 127.5;
        texWhn = texWhn + 127.5;
        
        % contrast adjustment
        scale = @(x) (x - prctile(x(:), 0.1)) / diff(prctile(x(:), [0.1 99.9])) * 255;
        
        texNat = scale(texNat);
        texPhs = scale(texPhs);
        texWhn = scale(texWhn);
 
        
        textures(f).nat = uint8(texNat); 
        textures(f).phs = uint8(texPhs); 
        textures(f).whn = uint8(texWhn); 
        textures(f).org = uint8(texPre);
        textures(f).source = files(f); 
 
        toc       
        
    end
    
    textures(1).githash = 'd9b90d7be41fdb9b0c6ceab6e5c238ef68a6f4f2'; %for good version control ;)
    idx = randperm(length(textures));
    textures = textures(idx);
    
    save(sprintf('/mnt/lab/users/leon/leon_textures/NatImTextures_%d',count),'textures')
end



