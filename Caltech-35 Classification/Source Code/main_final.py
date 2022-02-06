from dataset import tiny_caltech35
import torchvision.transforms as transforms
import torch
import torch.optim as optim
from torch.utils.data import DataLoader
import argparse
import torch.nn as nn
from model import base_model
from visualization import train_visualize, my_confusion_matrix
from utility_final import train, test
from torchinfo import summary


def main(config):
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    transform_train = transforms.Compose([
        transforms.Resize(config.image_size, interpolation=3),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    transform_test = transforms.Compose([
        transforms.Resize(config.image_size, interpolation=3),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    train_dataset = tiny_caltech35(transform=transform_train, used_data=['train', 'val', 'addition'],
                                   desired_class=list(range(0, 35)))
    val_dataset = tiny_caltech35(transform=transform_test, used_data=['test'], desired_class=list(range(0, 35)))

    train_loader = DataLoader(train_dataset, batch_size=config.batch_size, shuffle=True, drop_last=True)
    val_loader = DataLoader(val_dataset, batch_size=config.batch_size, shuffle=False, drop_last=False)
    test_dataset = tiny_caltech35(transform=transform_test, used_data=['test'], desired_class=list(range(0, 35)))
    test_loader = DataLoader(test_dataset, batch_size=config.batch_size, shuffle=False, drop_last=False)

    model = base_model(num_classes=35)
    model.load_state_dict(torch.load("./base_model/base_model_3_1_1.pth"))  # may need to change

    optimizer = optim.SGD(model.parameters(), lr=config.learning_rate, momentum=0.9)
    scheduler = torch.optim.lr_scheduler.MultiStepLR(optimizer, milestones=config.milestones, gamma=0.1, last_epoch=-1)
    creiteron = nn.CrossEntropyLoss()

    #print(model)
    #summary(model, input_size=(config.batch_size, 3, config.image_size[0], config.image_size[1]), device='cpu')
    model.to(device)

    # train model
    _, train_losses, train_accuracies, val_accuracies = train(
        config,
        train_loader,
        val_loader,
        model,
        optimizer,
        scheduler,
        creiteron,
        device,
        config.experiment_name)
    train_visualize(list(range(config.epochs)), train_losses, train_accuracies, val_accuracies,
                    model_name=config.model_name + config.experiment_name)

    _, train_pred_labels_all, train_labels_all, _ = test(train_loader, model, device)
    my_confusion_matrix(train_labels_all, train_pred_labels_all, labels_range=list(range(0, 35)),
                        model_name=config.model_name + config.experiment_name + '_train')

    # test model
    test_accuracy, test_pred_labels_all, test_labels_all, _ = test(test_loader, model, device)
    my_confusion_matrix(test_labels_all, test_pred_labels_all, labels_range=list(range(0, 35)),
                        model_name=config.model_name + config.experiment_name + '_test')  # experiment name need to change
    print('===========================')
    print("test accuracy:{}%".format(test_accuracy * 100))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--image_size', type=int, nargs='+', default=[112, 112])
    parser.add_argument('--batch_size', type=int, default=32)
    parser.add_argument('--class_num', type=int, default=35)
    parser.add_argument('--learning_rate', type=float, default=0.01)
    parser.add_argument('--epochs', type=int, default=2)
    parser.add_argument('--milestones', type=int, nargs='+', default=[15])
    parser.add_argument('--model_name', type=str, default='base_model')
    parser.add_argument('--experiment_name', type=str, default='_FinalCheck')
    parser.add_argument('--TripletLoss', type=bool, default=False)

    config = parser.parse_args()
    main(config)
