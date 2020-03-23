function ratvec = getRatioVec(h,nFilt)
    hsmooth=smooth(h,nFilt);
    ratvec=(sum(hsmooth(1:3))/3)./hsmooth;
end