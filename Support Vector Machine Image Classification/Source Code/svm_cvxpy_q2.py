from sklearn import svm
from sklearn.metrics import accuracy_score
import numpy as np
import scipy.io as sio

# 装载数据
data = sio.loadmat('Caltech-256_VGG_10classes.mat')
traindata = data['traindata']
testdata = data['testdata']

x_train = traindata[0][0][0].transpose()
y_train = traindata[0][0][1].ravel()
x_test = testdata[0][0][0].transpose()
y_test = testdata[0][0][1].ravel()

x_train = x_train[0:60]
y_train = y_train[0:60]
x_test = x_test[0:137]
y_test = y_test[0:137]

# check if the data have been correctly loaded
#print(x_train.shape)
#print(y_train.shape)


import cvxpy as cp
w = cp.Variable(4096)
b = cp.Variable()
y_train_n = y_train.copy()
y_train_n = y_train_n.astype('int')
y_train_n[y_train_n==2] = -1
y_test_n = y_test.copy()
y_test_n = y_test_n.astype('int')
y_test_n[y_test_n==2] = -1

#print(w.shape)
#### 此处填写优化问题的目标函数
obj = cp.Minimize(0.5*cp.norm(w))
####


### 此处填写优化问题的约束条件，如果有多个，以逗号隔开
constraint = [cp.multiply(y_train_n,(x_train@w+b))>=np.ones(60)]
###

prob = cp.Problem(obj, constraint)
prob.solve()

#print(prob.status)
ww = w.value
bb = b.value
#print(ww,bb)

####填写对训练数据和测试数据的测试代码，并测量分类准确率
#Prediction on train set
y_train_pred=np.matmul(x_train,ww)+bb
y_train_pred[y_train_pred>=1]=int(1)
y_train_pred[y_train_pred<=-1]=int(-1)
y_train_pred=y_train_pred.astype(int)
print('Accuracy Score on Train Set(cvxpy): ',accuracy_score(y_train_n,y_train_pred))

#Prediction on test set
y_test_pred=np.matmul(x_test,ww)+bb
y_test_pred[y_test_pred>0]=int(1)   #if the prediction=0, then the point is on the separation line, which we cannot conclude which group the point belongs to
y_test_pred[y_test_pred<0]=int(-1)
y_test_pred=y_test_pred.astype(int)
print('Accuracy Score on Test Set(cvxpy): ',accuracy_score(y_test_n,y_test_pred))
#print(y_test_pred)


#compare with sklearn svm
clf=svm.LinearSVC()
clf.fit(x_train,y_train_n)
print('Accuracy Score on Train Set(sklearn SVM): ',accuracy_score(y_train_n,clf.predict(x_train)))
print('Accuracy Score on Test Set(sklearn SVM): ',accuracy_score(y_test_n,clf.predict(x_test)))
#print(clf.predict(x_test))
