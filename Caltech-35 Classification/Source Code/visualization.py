import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn import decomposition
from sklearn.manifold import TSNE
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt


# combine PCA and TSNE together
def features_visualize(features, labels, model_name, n_components=2, normalize=True):
    fig, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, figsize=(15, 10))

    if normalize:
        scaler = StandardScaler()
        new_features = scaler.fit_transform(features)
    else:
        new_features = features

    rd_features_pca = features_pca(new_features, n_components=n_components)

    rd_features_tsne = features_tsne(new_features, n_components=n_components)

    plt1 = ax1.scatter(rd_features_pca[:, 0], rd_features_pca[:, 1], c=labels)
    plt2 = ax2.scatter(rd_features_tsne[:, 0], rd_features_tsne[:, 1], c=labels)
    if 'train' in model_name.split('_'):
        fig.suptitle('Train')
    else:
        fig.suptitle('Test')
    plt.colorbar(plt1, ax=ax1, ticks=np.linspace(0, 34, 35))
    plt.colorbar(plt2, ax=ax2, ticks=np.linspace(0, 34, 35))
    saved_plot = './' + model_name + '_features.png'
    plt.savefig(saved_plot)
    # plt.show()


# PCA
def features_pca(features, n_components=2):
    pca = decomposition.PCA(n_components=n_components)
    pca_features = pca.fit_transform(features)
    return pca_features


# TSNE
def features_tsne(features, n_components=2):
    tsne_features = TSNE(n_components=n_components).fit_transform(features)
    return tsne_features


# Training stats: Train Accuracy, Train Loss, Val Accuracy
def train_visualize(epochs, train_losses, train_accuracies, val_accuracies, model_name):
    fig, (ax1, ax2, ax3) = plt.subplots(nrows=3, ncols=1, figsize=(15, 10))
    ax1.plot(epochs, train_losses, color='g')
    ax2.plot(epochs, train_accuracies, color='r')
    ax3.plot(epochs, val_accuracies, color='r')

    ax1.set_xlabel('Number of Epochs')
    ax1.set_ylabel('Training Loss')
    ax2.set_xlabel('Number of Epochs')
    ax2.set_ylabel('Training Accuracy')
    ax3.set_xlabel('Number of Epochs')
    ax3.set_ylabel('Validation Accuracy')

    saved_plot = './' + model_name + '_training_stats.png'
    plt.savefig(saved_plot)
    # plt.show()


# Confusion Matrix (used for both training and testing)
def my_confusion_matrix(ori_labels, pred_labels, labels_range, model_name):
    matrix = confusion_matrix(ori_labels, pred_labels, labels=labels_range)
    print(matrix.shape)
    fig, ax = plt.subplots(figsize=(15, 15))
    matrix_display = ConfusionMatrixDisplay(confusion_matrix=matrix, display_labels=labels_range)
    matrix_display.plot(ax=ax)
    if 'train' in model_name.split('_'):
        title = 'Confusion Matrix on Last Epoch (Training)'
    else:
        title = 'Confusion Matrix of Test Set'
    ax.set_title(title)
    saved_plot = './' + model_name + '_confusion_matrix.png'
    plt.savefig(saved_plot)
    # plt.show()


# used when tuning learning rate and training model on noisy data (different ratio)
def train_stats_visualize(epochs, train_loss, train_acc, val_acc):
    print('train_loss: ', len(train_loss))
    print('train_acc: ', len(train_acc))
    print('val_acc: ', len(val_acc))
    fig, (ax1, ax2, ax3) = plt.subplots(nrows=3, ncols=1, figsize=(15, 10))
    ax1.plot(epochs, train_loss[0], color='r', label='lr=0.005')
    ax1.plot(epochs, train_loss[1], color='g', label='lr=0.01')
    ax1.plot(epochs, train_loss[2], color='b', label='lr=0.001')
    ax1.legend()

    ax2.plot(epochs, train_acc[0], color='r', label='lr=0.005')
    ax2.plot(epochs, train_acc[1], color='g', label='lr=0.01')
    ax2.plot(epochs, train_acc[2], color='b', label='lr=0.001')
    ax2.legend()

    ax3.plot(epochs, val_acc[0], color='r', label='lr=0.005')
    ax3.plot(epochs, val_acc[1], color='g', label='lr=0.01')
    ax3.plot(epochs, val_acc[2], color='b', label='lr=0.001')
    ax3.legend()

    ax1.set_xlabel('Number of Epochs')
    ax1.set_ylabel('Training Loss')
    ax2.set_xlabel('Number of Epochs')
    ax2.set_ylabel('Training Accuracy')
    ax3.set_xlabel('Number of Epochs')
    ax3.set_ylabel('Validation Accuracy')

    saved_plot = './base_model_' + 'lr_training_stats_combined.png'
    plt.savefig(saved_plot)
    # plt.show()
