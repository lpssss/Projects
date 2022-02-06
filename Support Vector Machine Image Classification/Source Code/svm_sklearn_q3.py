from sklearn import svm
from sklearn.metrics import accuracy_score
from sklearn.metrics import plot_confusion_matrix
from sklearn.multiclass import OneVsOneClassifier
from sklearn.multiclass import OneVsRestClassifier
from sklearn.model_selection import GridSearchCV
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt

def SVMClassifier(paramC,paramkernel,paramdegree):
    clf=svm.SVC(C=paramC,kernel=paramkernel,degree=paramdegree)

    #One vs One Classifier
    ovo_clf=OneVsOneClassifier(clf)
    ovo_clf.fit(x_train,y_train)

    y_pred_train_ovo=ovo_clf.predict(x_train)
    print('Accuracy Score on Train Set (One Vs One): ',accuracy_score(y_train,y_pred_train_ovo))

    y_pred_test_ovo=ovo_clf.predict(x_test)
    print('Accuracy Score on Test Set (One Vs One): ',accuracy_score(y_test,y_pred_test_ovo))


    #Confusion Matrix for ovo classifier
    plt.figure(figsize=[15,10])
    plt.rcParams.update({'font.size':7})
    plot_confusion_matrix(ovo_clf,x_test,y_test,cmap=plt.cm.Blues,normalize='true')
    plt.title('Confusion matrix for OvO classifier')
    if(paramdegree!=0):
        filename='./ConfusionMatrix/ConfusionMatrixOvO_'+str(paramC)+'_'+str(paramkernel)+'_degree'+str(paramdegree)+'.png'
    else:
        filename='./ConfusionMatrix/ConfusionMatrixOvO_'+str(paramC)+'_'+str(paramkernel)+'.png'
    plt.savefig(filename)

    #One vs Rest Classifier
    ovr_clf=OneVsRestClassifier(clf)
    ovr_clf.fit(x_train,y_train)

    y_pred_train_ovr=ovr_clf.predict(x_train)
    print('Accuracy Score on Train Set (One Vs Rest): ',accuracy_score(y_train,y_pred_train_ovr))

    y_pred_test_ovr=ovr_clf.predict(x_test)
    print('Accuracy Score on Test Set (One Vs Rest): ',accuracy_score(y_test,y_pred_test_ovr))

    #Confusion Matrix for ovr classifier
    plt.figure(figsize=[20,10])
    plt.rcParams.update({'font.size':7})
    plot_confusion_matrix(ovr_clf,x_test,y_test,cmap=plt.cm.Blues,normalize='true')
    plt.title('Confusion matrix for OvR classifier')
    filename='./ConfusionMatrix/ConfusionMatrixOvR_'+str(paramC)+'_'+str(paramkernel)+'.png'
    plt.savefig(filename)

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

#configure classifier parameters
paramC=[0.01,1,100]   #for regularization
paramkernel=['linear','rbf','poly']
paramdegree=[2,3] #only for polynomial kernel

for i in range(len(paramC)):
    for j in range(len(paramkernel)):
        print('Paramters:')
        print('C=',paramC[i])
        print('Kernel=',paramkernel[j])
        if(j==2):
            for k in range(len(paramdegree)):
                print('degree=',paramdegree[k])
                SVMClassifier(paramC[i],paramkernel[j],paramdegree[k])
        else:
            SVMClassifier(paramC[i],paramkernel[j],0)

