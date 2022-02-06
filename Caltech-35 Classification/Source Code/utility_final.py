import time
import torch
import numpy as np
import torch.nn.functional as F


def train(config, train_loader, val_loader, model, optimizer, scheduler, creiteron, device, experiment_name):
    print('train & val: ', device)
    total_train_numbers = 0
    mean_train_loss = []
    mean_accuracy = []
    val_accuracies_all = []
    for epoch in range(config.epochs):
        t0 = time.time()
        train_accuracies = []
        train_losses = []
        for batch_idx, (data, label) in enumerate(train_loader):  # batch_idx start from 0
            model.train()
            data = data.to(device)
            label = label.to(device)  # batch size x 1
            output, out_features = model(data)  # output shape: batch size x 35, output features: batch_size x fc_input

            # one_hot_label = F.one_hot(label, num_classes=config.class_num).float()  # for mse loss only
            # one_hot_label = one_hot_label.to(device)

            # for Triplet Loss
            if config.TripletLoss:
                loss = creiteron(out_features, label)
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()
            else:
                loss = creiteron(output, label)
                # assert output.shape==one_hot_label.shape
                # loss = creiteron(output, one_hot_label)         # for mse loss
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

            total_train_numbers += len(data)
            accuracy = (label == output.argmax(dim=1)).sum() * 1.0 / output.shape[0]

            train_losses.append(loss.item())
            train_accuracies.append(accuracy.item())

            if batch_idx % 20 == 0:
                print(
                    'Train Epoch: {} / {} [{}/{} ({:.0f}%)] Loss: {:.6f} Accuracy: {:.6f} Time Taken: {} seconds'.format(
                        epoch, config.epochs, batch_idx * len(data), len(train_loader.dataset),
                                              100. * batch_idx / len(train_loader),
                        loss.item(), accuracy.item(), (time.time() - t0)))

        # Use Triplet Loss to train features layers no need to validate
        if not config.TripletLoss:
            mean_train_loss.append(np.mean(np.array(train_losses)))
            mean_accuracy.append(np.mean(np.array(train_accuracies)))
            val_accuracy, _, _, _ = test(val_loader, model, device)
            val_accuracies_all.append(val_accuracy.item())
            print('Validation Accuracy: ', val_accuracy.item())
            scheduler.step()
            saved_name = './' + config.model_name + experiment_name + '.pth'
            torch.save(model.state_dict(), saved_name)

    return total_train_numbers, mean_train_loss, mean_accuracy, np.array(val_accuracies_all)


def test(data_loader, model, device):
    model.eval()
    correct = 0
    out_features_all = []
    pred_labels = []
    ori_labels = []
    with torch.no_grad():
        for data, label in data_loader:
            data = data.to(device)
            label = label.to(device)
            output, out_features = model(data)
            pred = output.argmax(dim=1)
            correct += (pred == label).sum()
            out_features_all += out_features.tolist()
            pred_labels += pred.flatten().tolist()
            ori_labels += label.flatten().tolist()

    accuracy = correct * 1.0 / len(data_loader.dataset)
    return accuracy, np.array(pred_labels), np.array(ori_labels), np.array(out_features_all)
