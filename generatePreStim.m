% generate pretextures for NatImExperiment stimuli

files1  = dir('/Users/leongatys/Documents/MATLAB/houston/textures/cgtextures/*.jpg');
files2  = dir('/Users/leongatys/Documents/MATLAB/houston/textures/mayang/*.JPG');
files = [files1; files2];
sources = [ones(length(files1),1); 2*ones(length(files2),1)];

texSz = 512;
scF = 1;

fprintf('\n')
for f=1:length(files)
    fprintf('texture %d\n',f)
    
    % read files
    if sources(f)==1
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
    tex = double(tex);
    
    %normalize
    mx = mean(tex(:));
    sx = std(tex(:));
    tex = 45*(tex - mx) / sx + 127.5;
  
    tex = uint8(tex);
    tex = double(tex);
        
    pretex(f).nat = tex; %#ok<AGROW>
    pretex(f).source = files(f); %#ok<AGROW>
   
    
end


save(sprintf('PreNatTextures_%d',texSz/scF),'pretex')