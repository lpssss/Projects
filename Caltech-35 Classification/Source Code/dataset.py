import numpy as np
from PIL import Image
import os
from torch.utils.data import Dataset
import random

__all__ = ['tiny_caltech35']


def choose_class(desired_class):
    def filter_class(variable_tuple):
        classes = desired_class
        if variable_tuple[1] in classes:
            return True
        else:
            return False

    return filter_class


# utility function to chose specific class for visualization
def _samples_filtering(samples_tuple, desired_class):  # samples_tuple is a tuple of two lists
    # zip the input to form list of tuples for filter
    after_filter = list(filter(choose_class(desired_class),
                               list(zip(samples_tuple[0], samples_tuple[1]))))

    # unzip the filtered samples to a list of two tuples (first is image path, second is label)
    after_filter = list(zip(*after_filter))
    return list(after_filter[0]), list(after_filter[1])


def _create_noisy_data(annotations, noisy_data_ratio):
    # print('Original Annotations: ', annotations)
    noisy_annotations = annotations
    chosen_labels_idx = random.sample(range(0, len(annotations)),
                                      int(noisy_data_ratio * len(annotations)))  # sampled index to be shuffled
    shuffled_labels = []
    for i in chosen_labels_idx:
        shuffled_labels.append(annotations[i])
    np.random.shuffle(shuffled_labels)
    for i in range(len(chosen_labels_idx)):
        noisy_annotations[chosen_labels_idx[i]] = shuffled_labels[i]
    # print('Noisy Annotations: ', noisy_annotations)
    return noisy_annotations


class tiny_caltech35(Dataset):
    def __init__(self, transform=None, used_data=['train'], desired_class=list(range(0, 35)), noisy_data_ratio=0.0):
        self.train_dir = 'dataset/train/'
        self.addition_dir = 'dataset/addition/'
        self.val_dir = 'dataset/val/'
        self.test_dir = 'dataset/test/'
        self.used_data = used_data
        for x in used_data:
            assert x in ['train', 'addition', 'val', 'test']
        self.transform = transform
        self.samples, self.annotions = _samples_filtering(self._load_samples(), desired_class=desired_class)
        if noisy_data_ratio > 0.0:
            self.annotions = _create_noisy_data(self.annotions, noisy_data_ratio)

    def _load_samples_one_dir(self, dir='dataset/train/'):
        samples, annotions = [], []
        if 'test' not in dir:
            sub_dir = os.listdir(dir)  # 0--34
            for i in sub_dir:
                tmp = os.listdir(os.path.join(dir, i))
                samples += [os.path.join(dir, i, x) for x in tmp]
                annotions += [int(i)] * len(tmp)
        else:
            with open(os.path.join(self.test_dir, 'annotions.txt'), 'r') as f:
                tmp = f.readlines()
            for i in tmp:
                path, label = i.split(',')[0], i.split(',')[1]
                samples.append(os.path.join(self.test_dir, path))
                annotions.append(int(label))
        return samples, annotions

    def _load_samples(self):
        samples, annotions = [], []
        for i in self.used_data:
            if i == 'train':
                tmp_s, tmp_a = self._load_samples_one_dir(dir=self.train_dir)
            elif i == 'addition':
                tmp_s, tmp_a = self._load_samples_one_dir(dir=self.addition_dir)
            elif i == 'val':
                tmp_s, tmp_a = self._load_samples_one_dir(dir=self.val_dir)
            elif i == 'test':
                tmp_s, tmp_a = self._load_samples_one_dir(dir=self.test_dir)
            else:
                print('error used_data!!')
                exit(0)
            samples += tmp_s  # += results in a 1d array
            annotions += tmp_a
        return samples, annotions

    def __getitem__(self, index):
        img_path, img_label = self.samples[index], self.annotions[index]
        img = self._loader(img_path)
        if self.transform is not None:
            img = self.transform(img)
        return img, img_label

    def _loader(self, img_path):
        return Image.open(img_path).convert('RGB')

    def __len__(self):
        return len(self.samples)

# test_dataset=tiny_caltech35( used_data=['test'], desired_class=[1,2])
# print(test_dataset.samples)
# print(test_dataset.annotions)
