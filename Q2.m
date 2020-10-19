%% Read 'p2-data'

clear;
fileID = fopen('p2-data','r');
formatSpec = '%f,%f';
A = fscanf(fileID,formatSpec);
var1 = [];
var2 = [];
len = round(size(A)/2);
for i=1:len(1)
    var1 = [var1; A((i-1)*2+1)];
    var2 = [var2; A(i*2)];
end
data = [var1, var2];


%% Clustering using K-Means method
% Ref: https://www.mathworks.com/help/stats/cluster-analysis-example.html

sumd_all = [];
silh_all = [];
for ci = 2:10    
    [cidx,cmeans,sumd] = kmeans(data,ci,'dist','sqeuclidean');
    [silh,h] = silhouette(data,cidx,'sqeuclidean');
    ptsymb = {'bs','r^','md','go','c+','b*','r.','mx','gp','c>'};
    for i = 1:ci
        clust = find(cidx==i);
        plot(data(clust,1),data(clust,2),ptsymb{i});    
        hold on
    end
    hold off
    grid on
    filename = ['kmeans_' sprintf('%03.f',ci) '.png'];
    saveas(gcf,filename,'png')
    close
    
    silh_all = [silh_all, mean(silh)];
    sumd_all = [sumd_all, sum(sumd)];
end
silh_all
sumd_all


%% Clustering using Neural Networks
% Ref: https://www.mathworks.com/help/deeplearning/ug/iris-clustering.html

% net = selforgmap([8 8]);
% view(net)
% [net,tr] = train(net,data);
% nntraintool
% nntraintool('close')
% y = net(data);
% cluster_index = vec2ind(y);
% plotsomtop(net)
% plotsomhits(net,data)
% plotsomnc(net)
% plotsomnd(net)
% plotsomplanes(net)


%% Clustering using GMM method
% Ref: https://www.mathworks.com/help/stats/clustering-using-gaussian-mixture-models.html

X = data;
[n,p] = size(data);
plot(data(:,1),data(:,2),'.','MarkerSize',15);

rng(3);
k = 3; % Number of GMM components

options = statset('MaxIter',1000);
Sigma = {'diagonal','full'}; % Options for covariance matrix type
nSigma = numel(Sigma);

SharedCovariance = {true,false}; % Indicator for identical or nonidentical covariance matrices
SCtext = {'true','false'};
nSC = numel(SharedCovariance);

d = 500; % Grid length
x1 = linspace(min(X(:,1))-2, max(X(:,1))+2, d);
x2 = linspace(min(X(:,2))-2, max(X(:,2))+2, d);
[x1grid,x2grid] = meshgrid(x1,x2);
X0 = [x1grid(:) x2grid(:)];

threshold = sqrt(chi2inv(0.99,2));
count = 1;
for i = 1:nSigma
    for j = 1:nSC
        gmfit = fitgmdist(X,k,'CovarianceType',Sigma{i}, ...
            'SharedCovariance',SharedCovariance{j},'Options',options); % Fitted GMM
        clusterX = cluster(gmfit,X); % Cluster index 
        mahalDist = mahal(gmfit,X0); % Distance from each grid point to each GMM component
        % Draw ellipsoids over each GMM component and show clustering result.
        subplot(2,2,count);
        h1 = gscatter(X(:,1),X(:,2),clusterX);
        hold on
            for m = 1:k
                idx = mahalDist(:,m)<=threshold;
                Color = h1(m).Color*0.75 - 0.5*(h1(m).Color - 1);
                h2 = plot(X0(idx,1),X0(idx,2),'.','Color',Color,'MarkerSize',1);
                uistack(h2,'bottom');
            end    
        plot(gmfit.mu(:,1),gmfit.mu(:,2),'kx','LineWidth',2,'MarkerSize',10)
        title(sprintf('Sigma is %s\nSharedCovariance = %s',Sigma{i},SCtext{j}),'FontSize',8)
        legend(h1,{'1','2','3'})
        hold off
        count = count + 1;
    end
end
saveas(gcf,'cluster_GMM_SpecifyDiffCovStructure.png','png')
close(gcf)

initialCond1 = [ones(n-8,1); [2; 2; 2; 2]; [3; 3; 3; 3]]; % For the first GMM
initialCond2 = randsample(1:k,n,true); % For the second GMM
initialCond3 = randsample(1:k,n,true); % For the third GMM
initialCond4 = 'plus'; % For the fourth GMM
cluster0 = {initialCond1; initialCond2; initialCond3; initialCond4};
converged = nan(4,1);

for j = 1:4
    gmfit = fitgmdist(X,k,'CovarianceType','full', ...
        'SharedCovariance',false,'Start',cluster0{j}, ...
        'Options',options);
    clusterX = cluster(gmfit,X); % Cluster index 
    mahalDist = mahal(gmfit,X0); % Distance from each grid point to each GMM component
    % Draw ellipsoids over each GMM component and show clustering result.
    subplot(2,2,j);
    h1 = gscatter(X(:,1),X(:,2),clusterX); % Distance from each grid point to each GMM component
    hold on;
    nK = numel(unique(clusterX));
    for m = 1:nK
        idx = mahalDist(:,m)<=threshold;
        Color = h1(m).Color*0.75 + -0.5*(h1(m).Color - 1);
        h2 = plot(X0(idx,1),X0(idx,2),'.','Color',Color,'MarkerSize',1);
        uistack(h2,'bottom');
    end
	plot(gmfit.mu(:,1),gmfit.mu(:,2),'kx','LineWidth',2,'MarkerSize',10)
    legend(h1,{'1','2','3'});
    hold off
    converged(j) = gmfit.Converged; % Indicator for convergence
end
saveas(gcf,'cluster_GMM_SpecifyDiffIC','png')
close(gcf)
sum(converged)