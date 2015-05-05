#!sh

train=../fea-gen/fea/data2011.txt
test=../fea-gen/fea/data2012.txt
model=model.txt
prediction=prediction/prediction.txt
./svm_rank_learn -c 20.0 $train $model
./svm_rank_classify $test $model $prediction
