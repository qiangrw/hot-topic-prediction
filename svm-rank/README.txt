SVMrank

Support Vector Machine for Ranking

Author: Thorsten Joachims <thorsten@joachims.org> 
Cornell University 
Department of Computer Science

Version: 1.00 
Date: 21.03.2009



Overview

SVMrank is an instance of SVMstruct for efficiently training Ranking SVMs as defined in [Joachims, 2002c]. SVMrank solves the same optimization problem as SVMlight with the '-z p' option, but it is much faster. On the LETOR 3.0 dataset it takes about a second to train on any of the folds and datasets. The algorithm for solving the quadratic program is a straightforward extension of the ROC-area optimization algorithm described in [Joachims, 2006] for multiple rankings using the one-slack formulation of SVMstruct. However, since I did not want to spend more than an afternoon on coding SVMrank, I only implemented a simple separation oracle that is quadratic in the number of items in each ranking (not the O[k*log k] separation oracle described in [Joachims, 2006]). While this makes the implementation not very suitable for the special case of ordinal regression [Herbrich et al, 1999], it means that it is nevertheless fast for small rankings (i.e. k<1000) and scales linearly in the number of rankings (i.e. queries).

Source Code

The program is free for scientific use. Please contact me, if you are planning to use the software for commercial purposes. The software must not be further distributed without prior permission of the author. If you use SVMrank in your scientific work, please cite as
T. Joachims, Training Linear SVMs in Linear Time, Proceedings of the ACM Conference on Knowledge Discovery and Data Mining (KDD), 2006. [Postscript (gz)]  [PDF]
The implementation was developed on Linux with gcc, but compiles also on Solaris, Cygwin, Windows (using MinGW) and Mac (after small modifications, see FAQ). The source code is available at the following location:

http://download.joachims.org/svm_rank/current/svm_rank.tar.gz

If you just want the binaries, you can download them for the following systems:
Linux (32-bit): http://download.joachims.org/svm_rank/current/svm_rank_linux32.tar.gz
Linux (64-bit): http://download.joachims.org/svm_rank/current/svm_rank_linux64.tar.gz
Cygwin: http://download.joachims.org/svm_rank/current/svm_rank_cygwin.tar.gz
Windows: http://download.joachims.org/svm_rank/current/svm_rank_windows.zip
Please send me email and let me know that you got it. The archive contains the source code of the most recent version of SVMrank, which includes the source code of SVMstruct and the SVMlight quadratic optimizer. Unpack the archive using the shell command:

      gunzip –c svm_rank.tar.gz | tar xvf –
This expands the archive into the current directory, which now contains all relevant files. You can compile SVMrank using the command:
      make
This will produce the executables svm_rank_learn and svm_rank_classify. If the system does not compile properly, check this FAQ.
How to Use

SVMrank consists of a learning module (svm_rank_learn) and a module for making predictions (svm_rank_classify). SVMrank uses the same input and output file formats as SVM-light, and its usage is identical to SVMlight with the '-z p' option. You call it like

      svm_rank_learn -c 20.0 train.dat model.dat
which trains a Ranking SVM on the training set train.dat and outputs the learned rule to model.dat using the regularization parameter C set to 20.0. However, the interpretation of the parameter C in SVMrank is different from SVMlight. In particular, Clight = Crank/n, where n is the number of training queries (i.e. number of different qid's in the training set). Most of the other options come from SVMstruct and SVMlight and are described there. Only the "application-specific options" listed below are particular to SVMrank.
General Options:
         -?          -> this help
         -v [0..3]   -> verbosity level (default 1)
         -y [0..3]   -> verbosity level for svm_light (default 0)
Learning Options:
         -c float    -> C: trade-off between training error
                        and margin (default 0.01)
         -p [1,2]    -> L-norm to use for slack variables. Use 1 for L1-norm,
                        use 2 for squared slacks. (default 1)
         -o [1,2]    -> Rescaling method to use for loss.
                        1: slack rescaling
                        2: margin rescaling
                        (default 2)
         -l [0..]    -> Loss function to use.
                        0: zero/one loss
                        ?: see below in application specific options
                        (default 1)
Optimization Options (see [2][5]):
         -w [0,..,9] -> choice of structural learning algorithm (default 3):
                        0: n-slack algorithm described in [2]
                        1: n-slack algorithm with shrinking heuristic
                        2: 1-slack algorithm (primal) described in [5]
                        3: 1-slack algorithm (dual) described in [5]
                        4: 1-slack algorithm (dual) with constraint cache [5]
                        9: custom algorithm in svm_struct_learn_custom.c
         -e float    -> epsilon: allow that tolerance for termination
                        criterion (default 0.001000)
         -k [1..]    -> number of new constraints to accumulate before
                        recomputing the QP solution (default 100)
                        (-w 0 and 1 only)
         -f [5..]    -> number of constraints to cache for each example
                        (default 5) (used with -w 4)
         -b [1..100] -> percentage of training set for which to refresh cache
                        when no epsilon violated constraint can be constructed
                        from current cache (default 100%) (used with -w 4)
SVM-light Options for Solving QP Subproblems (see [3]):
         -n [2..q]   -> number of new variables entering the working set
                        in each svm-light iteration (default n = q).
                        Set n < q to prevent zig-zagging.
         -m [5..]    -> size of svm-light cache for kernel evaluations in MB
                        (default 40) (used only for -w 1 with kernels)
         -h [5..]    -> number of svm-light iterations a variable needs to be
                        optimal before considered for shrinking (default 100)
         -# int      -> terminate svm-light QP subproblem optimization, if no
                        progress after this number of iterations.
                        (default 100000)
Kernel Options:
         -t int      -> type of kernel function:
                        0: linear (default)
                        1: polynomial (s a*b+c)^d
                        2: radial basis function exp(-gamma ||a-b||^2)
                        3: sigmoid tanh(s a*b + c)
                        4: user defined kernel from kernel.h
         -d int      -> parameter d in polynomial kernel
         -g float    -> parameter gamma in rbf kernel
         -s float    -> parameter s in sigmoid/poly kernel
         -r float    -> parameter c in sigmoid/poly kernel
         -u string   -> parameter of user defined kernel
Output Options:
         -a string   -> write all alphas to this file after learning
                        (in the same order as in the training set)
Application-Specific Options:

The following loss functions can be selected with the -l option:
     1  Total number of swapped pairs summed over all queries.
     2  Fraction of swapped pairs averaged over all queries.

NOTE: SVM-light in '-z p' mode and SVM-rank with loss 1 are equivalent for
      c_light = c_rank/n, where n is the number of training rankings (i.e.
      queries).
SVMrank learns an unbiased linear classification rule (i.e. a rule w*x without explicit threshold). The loss function to be optimized is selected using the '-l' option. Loss function '1' is identical to the one used in the ranking mode of SVMlight, and it optimizes the total number of swapped pairs. Loss function '2' is a normalized version of  '1'. For each query, it divides the number of swapped pairs by the maximum number of possibly swapped pairs for that query.

You can in principle use kernels in SVMrank using the '-t' option just like in SVMlight, but it is painfully slow and you are probably better off using SVMlight.

The file format of the training and test files is the same as for SVMlight (see here for further details), with the exception that the lines in the input files have to be sorted by increasing qid. The first lines may contain comments and are ignored if they start with #. Each of the following lines represents one training example and is of the following format:

<line> .=. <target> qid:<qid> <feature>:<value> <feature>:<value> ... <feature>:<value> # <info>
<target> .=. <float>
<qid> .=. <positive integer>
<feature> .=. <positive integer>
<value> .=. <float>
<info> .=. <string>
The target value and each of the feature/value pairs are separated by a space character. Feature/value pairs MUST be ordered by increasing feature number. Features with value zero can be skipped. The target value defines the order of the examples for each query. Implicitly, the target values are used to generated pairwise preference constraints as described in [Joachims, 2002c]. A preference constraint is included for all pairs of examples in the example_file, for which the target value differs. The special feature "qid" can be used to restrict the generation of constraints. Two examples are considered for a pairwise preference constraint only if the value of "qid" is the same. For example, given the example_file

3 qid:1 1:1 2:1 3:0 4:0.2 5:0 # 1A
2 qid:1 1:0 2:0 3:1 4:0.1 5:1 # 1B 
1 qid:1 1:0 2:1 3:0 4:0.4 5:0 # 1C
1 qid:1 1:0 2:0 3:1 4:0.3 5:0 # 1D  
1 qid:2 1:0 2:0 3:1 4:0.2 5:0 # 2A  
2 qid:2 1:1 2:0 3:1 4:0.4 5:0 # 2B 
1 qid:2 1:0 2:0 3:1 4:0.1 5:0 # 2C 
1 qid:2 1:0 2:0 3:1 4:0.2 5:0 # 2D  
2 qid:3 1:0 2:0 3:1 4:0.1 5:1 # 3A 
3 qid:3 1:1 2:1 3:0 4:0.3 5:0 # 3B 
4 qid:3 1:1 2:0 3:0 4:0.4 5:1 # 3C 
1 qid:3 1:0 2:1 3:1 4:0.5 5:0 # 3D

the following set of pairwise constraints is generated (examples are referred to by the info-string after the # character):

1A>1B, 1A>1C, 1A>1D, 1B>1C, 1B>1D, 2B>2A, 2B>2C, 2B>2D, 3C>3A, 3C>3B, 3C>3D, 3B>3A, 3B>3D, 3A>3D

The result of svm_rank_learn is the model that is learned from the training data in train.dat. The model is written to model.dat. To make predictions on test examples, svm_rank_classify reads this file. svm_rank_classify is called as follows:

svm_rank_classify test.dat model.dat predictions

For each line in test.dat, the predicted ranking score is written to the file predictions. There is one line per test example in predictions in the same order as in test.dat. From these scores, the ranking can be recovered via sorting. 

Getting started: an Example Problem

You will find an example problem at

http://download.joachims.org/svm_light/examples/example3.tar.gz

It consists of 3 rankings (i.e. queries) with 4 examples each. It also contains a file with 4 test examples. Unpack the archive with

gunzip -c example3.tar.gz | tar xvf -

This will create a subdirectory example3. To run the example, execute the commands:

svm_rank_learn -c 3 example3/train.dat example3/model 
svm_classify example3/test.dat example3/model example3/predictions

The output in the predictions file can be used to rank the test examples. If you do so, you will see that it predicts the correct ranking. The values in the predictions file do not have a meaning in an absolute sense - they are only used for ordering. The equivalent call for SVM-light is

svm_learn -z p -c 1 example3/train.dat example3/model 

Note the different value for c, since we have 3 training rankings.

It can also be interesting to look at the "training error" of the ranking SVM. The equivalent of training error for a ranking SVM is the number of training pairs that are misordered by the learned model. To find those pairs, one can apply the model to the training file:

svm_rank_classify example3/train.dat example3/model example3/predictions.train

Again, the predictions file shows the ordering implied by the model. The model ranks all training examples correctly.

Note that ranks are comparable only between examples with the same qid. Note also that the target value (first value in each line of the data files) is only used to define the order of the examples. Its absolute value does not matter, as long as the ordering relative to the other examples with the same qid remains the same.

Disclaimer

This software is free only for non-commercial use. It must not be distributed without prior permission of the author. The author is not responsible for implications from the use of this software.

Known Problems

none
History

none
References

[1] T. Joachims, Training Linear SVMs in Linear Time, Proceedings of the ACM Conference on Knowledge Discovery and Data Mining (KDD), 2006. [Postscript]  [PDF]

[2] T. Joachims, A Support Vector Method for Multivariate Performance Measures, Proceedings of the International Conference on Machine Learning (ICML), 2005. [Postscript]  [PDF]

[3] Tsochantaridis, T. Joachims, T. Hofmann, and Y. Altun, Large Margin Methods for Structured and Interdependent Output Variables, Journal of Machine Learning Research (JMLR), 6(Sep):1453-1484, 2005. [PDF]  

[4] I. Tsochantaridis, T. Hofmann, T. Joachims, Y. Altun. Support Vector Machine Learning for Interdependent and Structured Output Spaces. International Conference on Machine Learning (ICML), 2004. [Postscript]  [PDF]  

[5] T. Joachims, Making Large-Scale SVM Learning Practical. Advances in Kernel Methods - Support Vector Learning, B. Schölkopf and C. Burges and A. Smola (ed.), MIT Press, 1999. [Postscript (gz)] [PDF]

[6] T. Joachims, T. Finley, Chun-Nam Yu, Cutting-Plane Training of Structural SVMs, Machine Learning Journal, 2009. [PDF]

[7] T. Joachims, Optimizing Search Engines Using Clickthrough Data, Proceedings of the ACM Conference on Knowledge Discovery and Data Mining (KDD), ACM, 2002. [Postscript]  [PDF]  
