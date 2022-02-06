import torch.nn as nn
import torchvision.models as models
import torch
from typing import List
from my_resnet import MyResNet, MyBottleneck, MyBasicBlock

__all__ = ['base_model', 'MyVgg16', 'MyResnet18', 'MyBaseModel1', 'MyBaseModel2']


class base_model(nn.Module):
    def __init__(self, num_classes=35):
        super(base_model, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=3, out_channels=64, kernel_size=(7, 7), padding=3, stride=2)
        self.bn1 = nn.BatchNorm2d(64)
        self.conv2 = nn.Conv2d(in_channels=64, out_channels=128, kernel_size=(3, 3), padding=1, stride=1)
        self.bn2 = nn.BatchNorm2d(128)
        self.conv3 = nn.Conv2d(in_channels=128, out_channels=256, kernel_size=(3, 3), padding=1, stride=1)
        self.relu = nn.ReLU(inplace=True)
        self.max_pooling = nn.MaxPool2d(kernel_size=(2, 2), stride=(2, 2))
        self.GAP = nn.AdaptiveMaxPool2d((1, 1))
        self.bn3 = nn.BatchNorm1d(256)
        self.bn4 = nn.BatchNorm1d(64)
        self.fc1 = nn.Linear(256, 64)
        self.fc2 = nn.Linear(64, num_classes)
        # self.softmax = nn.Softmax(dim=1)                # for mse loss

    def forward(self, x):
        x = self.relu(self.bn1(self.conv1(x)))
        x = self.max_pooling(x)

        x = self.relu(self.bn2(self.conv2(x)))
        x = self.max_pooling(x)
        x = self.conv3(x)
        x = self.GAP(x).squeeze(dim=3).squeeze(dim=2)
        # you can see this x as the feature, and use it to visualize something
        x_feature = x
        x = self.fc1(self.relu(self.bn3(x)))
        x = self.relu(self.bn4(x))
        # logits = self.softmax(self.fc2(x))          # softmax for mse loss
        logits = self.fc2(x)
        return logits, x_feature


class MyBaseModel1(nn.Module):  # ~40% on val and test set, ~90% on train set
    def __init__(self, num_classes=35):
        super(MyBaseModel1, self).__init__()
        self.conv = nn.Conv2d(in_channels=3, out_channels=64, kernel_size=(7, 7), stride=2, padding=3, bias=False)
        self.bn = nn.BatchNorm2d(64)
        self.relu = nn.ReLU(inplace=True)
        self.BasicBlock1 = MyBasicBlock(inplanes=64, planes=64, stride=1)
        self.BasicBlock2 = MyBasicBlock(inplanes=64, planes=128, stride=2, downsample=nn.Sequential(
            nn.Conv2d(in_channels=64, out_channels=128, kernel_size=(1, 1), stride=2, bias=False), nn.BatchNorm2d(128)))
        self.GAP = nn.AdaptiveMaxPool2d((1, 1))
        self.fc = nn.Linear(128, num_classes)
        # self.softmax = nn.Softmax(dim=1)        # for mse loss

    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        x = self.relu(x)
        x = self.BasicBlock1(x)
        x = self.BasicBlock2(x)
        x = self.GAP(x).squeeze(dim=3).squeeze(dim=2)
        x_features = x
        # x=self.softmax(self.fc(x))          # for mse loss
        x = self.fc(x)
        return x, x_features


class MyBaseModel2(nn.Module):
    def __init__(self, num_classes=35):
        super(MyBaseModel2, self).__init__()
        self.conv = nn.Conv2d(in_channels=3, out_channels=64, kernel_size=(7, 7), stride=2, padding=3, bias=False)
        self.bn = nn.BatchNorm2d(64)
        self.relu = nn.ReLU(inplace=True)
        self.BottleNeck1 = MyBottleneck(inplanes=64, planes=32, stride=1, downsample=nn.Sequential(
            nn.Conv2d(in_channels=64, out_channels=128, kernel_size=(1, 1), stride=1, bias=False), nn.BatchNorm2d(128)))
        self.BottleNeck2 = MyBottleneck(inplanes=128, planes=64, stride=2, downsample=nn.Sequential(
            nn.Conv2d(in_channels=128, out_channels=256, kernel_size=(1, 1), stride=2, bias=False),
            nn.BatchNorm2d(256)))
        self.GAP = nn.AdaptiveMaxPool2d((1, 1))
        self.fc = nn.Linear(256, num_classes)

    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        x = self.relu(x)
        x = self.BottleNeck1(x)
        x = self.BottleNeck2(x)
        x = self.GAP(x).squeeze(dim=3).squeeze(dim=2)
        x_features = x
        x = self.fc(x)
        return x, x_features


class MyResnet18(MyResNet):
    def __init__(self, block=MyBasicBlock, layers=[2, 2, 2, 2], num_classes=35):
        super(MyResnet18, self).__init__(block, layers, num_classes)


# Vgg16, slightly modified from source code (https://github.com/pytorch/vision/blob/master/torchvision/models/vgg.py)
def make_layers() -> nn.Sequential:
    cfg = [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512, 'M', 512, 512, 512, 'M']
    layers: List[nn.Module] = []
    in_channels = 3
    for v in cfg:
        if v == 'M':
            layers += [nn.MaxPool2d(kernel_size=2, stride=2)]
        else:
            conv2d = nn.Conv2d(in_channels, v, kernel_size=3, padding=1)
            layers += [conv2d, nn.ReLU(inplace=True)]
            in_channels = v
    return nn.Sequential(*layers)


class MyVgg16(models.VGG):
    def __init__(self, num_classes=35):
        super(MyVgg16, self).__init__(make_layers(), num_classes=num_classes)

    def forward(self, x):
        x = self.features(x)
        x = self.avgpool(x)
        x = torch.flatten(x, 1)
        x_features = x
        x = self.classifier(x)
        return x, x_features
