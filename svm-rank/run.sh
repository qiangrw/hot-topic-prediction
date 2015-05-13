#!sh

feano=3
train=../fea-gen/fea/data2011.fea$feano
test=../fea-gen/fea/data2012.fea$feano
model=fea${feano}.model
prediction=prediction/fea${fea}.prediction
./svm_rank_learn -c 20.0 $train $model
./svm_rank_classify $test $model $prediction
