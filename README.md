# Hot Topic Detection
The hot topic detection project using acl data.

## fea-gen
> * compute\_hits.pl: compute the hits score of each paper
> * compute\_pagerank.pl: compute the pagerank score of each paper

## label-gen
Labels can be genrated as:
> * perl gen\_label.pl ../release/2013/acl.txt ../topic/acl01-10.matrix 2011
> * perl gen\_label.pl ../release/2013/acl.txt ../topic/acl02-11.matrix 2012

## svm\_rank
A pairwise learning to rank method for topic ranking.

## topic
The topics need to be predicted. 
