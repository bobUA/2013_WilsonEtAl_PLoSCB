clear



directories;
savedir   = [maindir 'fakefits/'];



% load fits
cd(savedir)
d = dir('*.mat');
for i = 1:length(d)
L(i) = load(d(i).name, 'FIT');
end

FIT = [L.FIT];
clear L



%% excedance probability confusion matrices
clear alpha xp exp_r


% find all models generated by mdl_sim
mdl_sim = {'full' 'nassar' '1' '2' '3'};

for mn_sim = 1:length(mdl_sim)
    clear bic
    
    % for each simulation number and each mdl_fit, get best fitting bic
    mdl_fit = {'full' 'nassar' '1' '2' '3'};
    for mn = 1:length(mdl_fit)
        
        ft = FIT(strcmp({FIT.model_true}, mdl_sim{mn_sim}));
        ft = ft(strcmp({ft.model}, mdl_fit{mn}));
        sn = unique([ft.simNum]);
        
        for i = 1:length(sn)
            
            ind = find([ft.simNum] == sn(i));
            [~,i_min] = min([ft(ind).BIC]);
            bic(i,mn) = ft(ind(i_min)).BIC;
        end
    end
    
    % exclude nans
    ind = ~isnan(sum(bic,2));
    bic = bic(ind,:);
    
    
    [alpha,exp_r(mn_sim,:),xp(mn_sim,:)] = spm_BMS(-bic);
end


m_name = {'full' 'Nassar et al.' '1 node' '2 nodes' '3 nodes'};
exp_r = round(exp_r*100)/100;
xp = round(xp*100)/100;

figure(1); clf;
set(gcf, 'Position', [ 546   454   900   350])
ax = easy_gridOfEqualFigures([0.05 0.25], [0.15 0.18 0.03]);
axes(ax(1));
t = imageTextMatrix(exp_r, m_name, m_name)';
hold on;
[l1, l2] = addFacetLines(xp);
set([l1 l2], 'linewidth', 1)

set(t(exp_r>0.2), 'color', 'w');
set(t, 'fontsize', 12)



axes(ax(2));
t = imageTextMatrix(xp, m_name, m_name)';
hold on;
[l1, l2] = addFacetLines(xp);
set([l1 l2], 'linewidth', 1)
set(t(xp>0.2), 'color', 'w');
set(t, 'fontsize', 12)
set(ax, 'xaxislocation', 'top')
set(ax, 'fontsize', 12, 'fontweight', 'normal', 'tickdir', 'out')

for i = 1:length(ax)
    axes(ax(i))
    
    xlabel('fit model', 'fontsize', 24)
    ylabel('simulated model', 'fontsize', 24)
end
colormap gray
cc = colormap;
colormap(1-cc)
addABCs(ax, [-0.1 0.25], 48)
axes(ax(1)); title('fraction best fit', 'fontsize', 30, 'fontweight', 'normal')
axes(ax(2)); title('excedance probability', 'fontsize', 30, 'fontweight', 'normal')
% saveFigurePdf(gcf, '~/Desktop/confusionMatrix')



