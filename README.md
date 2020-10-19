# CS565_Assignment2
2020FA CS565 Assignment2

2020FA CS565 Assignment 2, Junehyeong Park (https://github.com/sai0259/CS565_Assignment2)


For Question 1,

Q1.m: the matlab code using 'Regression Learner' toolbox to predict 'z.csv' based on predictors 'x.csv' and 'y.csv' so that print 'z_predicted.csv'

x.csv, y.csv, and z.csv: input files for the question 1 of Assignment 1

z_predicted.csv: output file for the question 1 of Assignment 1


For Question 2,

Q2.m: the matlab code using K-Means and GMM for clustering 'p2-data' (the code includes the clustering using neural network method, but I commented it to neglect)

kmeans_0##.png: the clustering results using K-Means, and of course the results will be different for every trials

cluster_GMM_#.png: the clustering results using GMM with cases for different covariance sturcture options and different initual conditions

Discusstion on clustering: The K-Means method has the advantage that it's easy to apply and quick, but there is an unavoidable disadvantage that the user will get random results due to specify the central points randomly. Of course, the number of cluster also show different results because the results are random. Thus, I applied the GMM method again to avaid random problem. I followed the number of clusters to 3 as introduced in the reference, because I had tried other numbers additionally as behind but the 3 was better in this data. 


Ref:

https://www.mathworks.com/help/stats/cluster-analysis-example.html

https://www.mathworks.com/help/stats/clustering-using-gaussian-mixture-models.html
