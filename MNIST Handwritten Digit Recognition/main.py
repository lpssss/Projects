import numpy as np
import torch
from torchvision import datasets,transforms
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
import torch.nn as nn
import torch.optim as optim
import argparse


class BaseModel(nn.Module):
    def __init__(self,input_size=784, output_size=10):
        super(BaseModel,self).__init__()
        self.linear1=nn.Linear(input_size,64)
        self.linear2=nn.Linear(64,32)
        self.linear3=nn.Linear(32,output_size)
        self.relu=nn.ReLU(inplace=True)
        self.softmax=nn.LogSoftmax(dim=1)

    def forward(self,x):
        x=self.linear1(x)
        x=self.relu(x)
        x=self.linear2(x)
        x=self.relu(x)
        x=self.linear3(x)
        x=self.softmax(x)
        return x



def main(config):
    transform_dataset=transforms.Compose([
        transforms.Resize(config.image_size),
        transforms.ToTensor(),
        transforms.Normalize((0.1307,),(0.3081,))
    ])

    trainset=datasets.MNIST('./data',download=True,train=True,transform=transform_dataset)
    testset=datasets.MNIST('./data',train=False,transform=transform_dataset)

    trainloader = DataLoader(trainset,batch_size=config.batch_size,shuffle=True)
    testloader=DataLoader(testset,batch_size=config.batch_size,shuffle=True)

    view_Image(trainloader,config.batch_size)

    vector_length=config.image_size[0]*config.image_size[1]
    model= BaseModel(vector_length,config.class_num)

    criterion=nn.NLLLoss()
    #optimizer=optim.Adam(model.parameters(),lr=config.learning_rate)
    optimizer=optim.SGD(model.parameters(),lr=config.learning_rate,momentum=0.9)

    train_loss,train_accuracy=train(config,model,trainloader,criterion,optimizer)
    test(model,testloader)

    plt.plot(range(config.epochs),train_loss)
    plt.title('Training Loss Vs Epochs')
    plt.xlabel('epochs')
    plt.ylabel('Loss')
    plt.show()

    plt.plot(range(config.epochs), train_accuracy)
    plt.title('Training Accuracy Vs Epochs')
    plt.xlabel('epochs')
    plt.ylabel('Accuracy')
    plt.show()

def view_Image(imageloader,imageNum):
    figure=plt.figure
    dataiter=iter(imageloader)
    images,_=next(dataiter)
    for i in range(imageNum):
        plt.subplot(6,10,i+1)
        plt.axis('off')
        plt.imshow(images[i].numpy().squeeze(),cmap='gray_r')
    plt.show()

def train(config,model,trainloader,criterion,optimizer):
    print('----------Start Training----------')
    train_loss=[]
    accuracies=[]
    for epoch in range(config.epochs):
        CumuLoss=0
        correct_cnt = 0
        for batch_idx, (images,labels) in enumerate(trainloader):
            images=images.view(images.shape[0], -1)
            output=model(images)
            pred = output.argmax(dim=1)
            correct_cnt += (pred == labels).sum()

            loss=criterion(output,labels)
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            CumuLoss+=loss.item()

        mean_loss=CumuLoss/len(trainloader.dataset)
        train_loss.append(mean_loss)
        accuracy = correct_cnt * 1.0 / len(trainloader.dataset)
        accuracies.append(accuracy)
        print('Train Epoch:{} - Loss:{}'.format(epoch,mean_loss))
        print('Training Accuracy: ',float(accuracy))

    print('----------End Training----------')
    return train_loss,accuracies


def test(model,testloader):
    print('----------Start Testing----------')
    with torch.no_grad():
        correct_cnt=0
        for images,labels in testloader:
            images = images.view(images.shape[0], -1)
            test_output=model(images)
            pred=test_output.argmax(dim=1)
            correct_cnt+=(pred==labels).sum()

    accuracy=correct_cnt*1.0/len(testloader.dataset)

    print('Test accuracy: ',float(accuracy))
    torch.save(model,'./my_model.pt')
    print('----------Done Testing and model is saved as "my_model.pt"----------')


if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--image_size',type=int,nargs='+',default=[28,28])      # nargs='+' means list
    parser.add_argument('--batch_size',type=int,default=32)
    parser.add_argument('--class_num',type=int,default=10)
    parser.add_argument('--learning_rate',type=float,default=0.01)
    parser.add_argument('--epochs',type=int,default=15)

    config=parser.parse_args()
    main(config)


