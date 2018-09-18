function returned_flag=checkSpec(spec)
%   this function checks the validity of the design
%   by comparing the required specs with the design simulated results
% ret=1;
% tol=5;
% Error_AO=abs(OTA1_Sim.LGmag(1)-OTA1.AO)/OTA1.AO*100;
% if Error_AO>tol
%     ret=0;
% end
returned_flag=1;

if spec.CMIR_LOW<0 | spec.CMIR_HIGH>spec.VDD | spec.CMIR_LOW>spec.CMIR_HIGH
    disp('Error: the CMIR doesn''t fit between 0 --> VDD');
    returned_flag=0;
    return
end

