x=ones(1,180);
h=pie(x);
colormap hsv
for hc=1:2:length(h) % segments
    set(h(hc),'EdgeColor','none');
end
for hc=2:2:length(h) % texts
    if mod(hc,10)~=0
        delete(h(hc)); % delete some texts
    else
        set(h(hc),'string',num2str(hc)); % set new texts
    end
end