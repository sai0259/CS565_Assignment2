%% Read 'p2-data'

clear;
fileID = fopen('p2-data','r');
formatSpec = '%f,%f';
A = fscanf(fileID,formatSpec);
var1 = [];
var2 = [];
for i=1:length(A)/2
    var1 = [var1; A((i-1)*2+1)];
    var2 = [var2; A(i*2)];
end
X = [var1, var2];


%% Clustering using GMM method
% Ref: https://www.mathworks.com/help/stats/clustering-using-gaussian-mixture-models.html

rng(3);
legends{1} = {'1','2','3'};
legends{2} = {'1','2','3','4'};
legends{3} = {'1','2','3','4','5'};
legends{4} = {'1','2','3','4','5','6'};
legends{5} = {'1','2','3','4','5','6','7'};
legends{6} = {'1','2','3','4','5','6','7','8'};

sigma_all = {};
sigma_sum = [];
for k=3:8
    options = statset('MaxIter',1000);
    Sigma = 'full';
    SharedCovariance = false;
    
    d = 500; % Grid length
    x1 = linspace(min(X(:,1))-2, max(X(:,1))+2, d);
    x2 = linspace(min(X(:,2))-2, max(X(:,2))+2, d);
    [x1grid,x2grid] = meshgrid(x1,x2);
    X0 = [x1grid(:) x2grid(:)];
    
    threshold = sqrt(chi2inv(0.99,2));
    
    gmfit = fitgmdist(X,k,'CovarianceType',Sigma, ...
        'SharedCovariance',SharedCovariance,'Options',options); % Fitted GMM    
    sigma_all{k-2} = gmfit.Sigma;
    sigma_sum = [sigma_sum, sum(gmfit.Sigma, 'all')];
    clusterX = cluster(gmfit,X); % Cluster index
    mahalDist = mahal(gmfit,X0); % Distance from each grid point to each GMM component
    % Draw ellipsoids over each GMM component and show clustering result.
    subplot(2,3,k-2);
    h1 = gscatter(X(:,1),X(:,2),clusterX);
    hold on
    for m = 1:k
        idx = mahalDist(:,m)<=threshold;
        Color = h1(m).Color*0.75 - 0.5*(h1(m).Color - 1);
        h2 = plot(X0(idx,1),X0(idx,2),'.','Color',Color,'MarkerSize',1);
        uistack(h2,'bottom');
    end
    plot(gmfit.mu(:,1),gmfit.mu(:,2),'kx','LineWidth',2,'MarkerSize',10)
    title(sprintf('k = %d\nSum of Sigma = %0.3f',k,sum(gmfit.Sigma, 'all')),'FontSize',8)
    legend(h1,legends{k-2})
    hold off
    sgtitle(sprintf('Sigma is fill\nSharedCovariance = false'),'FontSize',8)
end
saveas(gcf,'clusters_GMM.png','png')
close(gcf)

[dum,num_cluster] = min(sigma_sum);
num_cluster = num_cluster + 2;
gmfit = fitgmdist(X,num_cluster,'CovarianceType',Sigma, ...
        'SharedCovariance',SharedCovariance,'Options',options); % Fitted GMM
clusterX = cluster(gmfit,X); % Cluster index
point_id = 1:length(A)/2;
max_point = 0;
for k = 1:num_cluster
    max_point = max(max_point, length(point_id(1,clusterX(:,1)==k)));
end
res_pt = NaN(6,max_point);
for k = 1:num_cluster
    pt_temp = point_id(1,clusterX(:,1)==k);
    res_pt(k,1:length(pt_temp)) = pt_temp;
end
csvwrite('clustered.csv',res_pt);
