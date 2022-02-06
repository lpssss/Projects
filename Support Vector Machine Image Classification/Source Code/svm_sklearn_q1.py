from sklearn import svm
from sklearn.metrics import accuracy_score, plot_confusion_matrix
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt

# 装载数据
data = sio.loadmat('Caltech-256_VGG_10classes.mat')
traindata = data['traindata']
testdata = data['testdata']

x_train = traindata[0][0][0].transpose()
y_train = traindata[0][0][1].ravel()
x_test = testdata[0][0][0].transpose()
y_test = testdata[0][0][1].ravel()

x_train = x_train[0:300]
y_train = y_train[0:300]
x_test = x_test[0:955]
y_test = y_test[0:955]

#randomly assigned one class as master class
master_class=np.random.randint(1,11)
print('Master Class: ',master_class)

# check if the data have been correctly loaded
#print(x_train.shape)
#print(y_train.shape)

#change label for master class and non-master class
y_train[y_train==master_class]=0
y_train[y_train!=0]=1
y_test[y_test==master_class]=0
y_test[y_test!=0]=1

#use Linear SVM to train
clf=svm.LinearSVC()
clf.fit(x_train,y_train)

#Prediction on train set
y_pred_train=clf.predict(x_train)
print('Accuracy Score on Train Set: ',accuracy_score(y_train,y_pred_train))

#predication on test set
y_pred=clf.predict(x_test)
print('Accuracy Score on Test Set: ',accuracy_score(y_test,y_pred))

#plot confusion matrix
plt.figure(figsize=[15,10])
plt.rcParams.update({'font.size':7})
plot_confusion_matrix(clf,x_test,y_test,cmap=plt.cm.Blues,normalize='true')
plt.title('Confusion Matrix for Linear Binary Classifier, Master Class: '+str(master_class))
filename='./ConfusionMatrix/ConfusionMatrixLinear_Master'+str(master_class)+'.png'
plt.savefig(filename)