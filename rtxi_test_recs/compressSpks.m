function [cs,cs_unnorm,ofnum,ofmax] = compressSpks(spks,cFactor)
    
    cs = zeros(size(spks(1:cFactor:end)));
    for i =1:cFactor
        sniplen = numel(spks(i:cFactor:end));
        cs(1:(sniplen)) = cs(1:(sniplen))+spks(i:cFactor:end);
    end
    
    ofnum = sum(cs>1);
    ofmax = max(cs);
    
    cs_unnorm = cs;
    cs = min(cs,1);
end