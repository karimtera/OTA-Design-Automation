function DESIGN = setTech(path)
%   Checks the path of the technology files, if the path is valid then
%   DESIGN.file(1).state=1, otherwise it equals 0.
%
%   important notes:    
%   1) technology files should be inside the folder passed to this fuction
%   and nothing more.
%   2) techonlogy files should be named like this: n180TSMC
%      'channelType''minimumLength''ProductionCompany' 
%   3) channelType is either 'n' or 'p'


    if ~isdir(path) % checking if the folder exist
        fprintf('Error: The following folder does not exist:\n%s', path);
        DESIGN.file(1).state=0; % this acts as a flag equals 1 when the path is valid, 0 otherwise
        return ; 
    end
    
    DESIGN.file = dir([path '/*.mat']); % listing the files in the directory given
    
    if isempty(DESIGN.file) % checking that the given folder path contain .mat files
        fprintf('Error: the following folder doesn''t contain .mat files:\n%s',path);
        DESIGN.file(1).state=0;
        return;
    end
    
    channel_type = DESIGN.file(1).name(1); % getting channel type of the first file
    
    if channel_type ~= 'n'&& channel_type ~= 'p' % if channel type is not n or p, terminate
        disp('Error: the channel type is not named correctly');
        DESIGN.file(1).state=0;
        return;
    end
    
    if channel_type == DESIGN.file(2).name(1) % if the two files are of same channel type, terminate
       disp('Error: the channel types of the two files are the same');
       DESIGN.file(1).state=0;
       return;
    end
    
    if DESIGN.file(2).name(1) ~= 'n' && DESIGN.file(2).name(1) ~= 'p' % if the second channel type is not n or p,terminate
        disp('Error: the channel type is not named correctly');
        return;
    end
    
    tech_name = DESIGN.file(1).name(2:end); % getting the technology minimum length and company name
        
    if  tech_name ~= DESIGN.file(2).name(2:end) % if the 2 files are not of the same technology, terminate
        disp('Error: Files are not from the same technology');
        return;
    end
    
    DESIGN.file(1).state=1; % this path is valid
