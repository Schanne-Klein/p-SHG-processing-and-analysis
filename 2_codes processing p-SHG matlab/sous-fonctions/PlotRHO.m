for Depth=1:Nz
    Dept=Depth-1;
    rho_filtered_XY=RHOXY(:,:,Depth);
    rho_filtered_XY(MaskXY(:,:,Depth)==0)=nan;
    rho_filtered_XY(rho_filtered_XY>10)=nan;

    h(Depth+10000)=figure(Depth+10000);
    imagesc(rho_filtered_XY);
    title(strcat('F-PSHG anisotropy parameter in z(um): ',num2str(Dept)),'fontsize',18)
    c=colorbar;
    axis off;
    % MaxRho=ceil(max(max(max(RHOXY))));
    % caxis([1 MaxRho]);
    caxis([1 3]);
    set(c,'fontsize',18);
    set(gca,'fontsize',18);
    %tightfig;
    img=[Path_Writing '07_F_PSHG_rho.z0' num2str(Dept)  '.tif'];
    saveas(h(Depth+10000),img);


    h(Depth+11000)=figure(Depth+11000);
    rho_filtered_Epi=RHOE(:,:,Depth);
    rho_filtered_Epi(MaskE(:,:,Depth)==0)=nan;
    rho_filtered_Epi(rho_filtered_Epi>10)=nan;

    imagesc(rho_filtered_Epi);
    title(strcat('B-PSHG anisotropy parameter in z(um): ',num2str(Dept)),'fontsize',18)
    c=colorbar;
    axis off;
    % MaxRho=ceil(max(max(max(RHOE))));
    % caxis([1 MaxRho]);
    caxis([1 3]);
    set(c,'fontsize',18);
    set(gca,'fontsize',18);
    %tightfig;
    % 
    img=[Path_Writing '07_B_PSHG_rho.z0' num2str(Dept)  '.tif'];
    saveas(h(Depth+11000),img);
end
close all