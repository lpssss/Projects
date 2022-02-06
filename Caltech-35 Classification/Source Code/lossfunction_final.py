from torch import Tensor
import torch.nn as nn
from torch import linalg
import torch


# Mode 1 is Cosine Similarity, Mode 2 is Euclidean Distance
class TripletLoss(nn.Module):
    def __init__(self, margin=0.25, mode=1):
        super(TripletLoss, self).__init__()
        self.margin = margin
        self.mode = mode

    # features (batch_size(num of feature vectors) x features_dim), labels (batch_size, )
    def forward(self, features: Tensor, labels: Tensor) -> Tensor:
        n = features.shape[0]  # n is batch_size
        # loss = torch.tensor(0.0).to('cuda:0')
        loss = torch.tensor(0.0)

        # return a batch_size x batch_size matrix, each row i correspond to type of each label compared to label[i]
        label_index = labels.unsqueeze(dim=1) == labels.unsqueeze(dim=0)

        # cosine similarity
        if self.mode == 1:
            # normalization, make features vector length=1
            features = features / linalg.norm(features, dim=1, keepdim=True)

            # find dot product between all features vector  (ith row is features[i] vs others)
            similarity = features.matmul(features.transpose(1, 0))

            for i in range(n):
                pos = similarity[i][label_index[i]].min()  # find the min of all same label (compared to label[i])
                neg = similarity[i][~label_index[i]].max()  # find the max of all different label
                loss += torch.relu(neg - pos + self.margin)

        # euclidean distance
        elif self.mode == 2:
            # find the distance matrix between every two features vector
            distmat = linalg.norm(features[:, None, :] - features[None, :, :], dim=-1)

            for i in range(n):
                pos = distmat[i][label_index[i]].max()  # find the max of all same label (compared to label[i])
                neg = distmat[i][~label_index[i]].min()  # find the min of all different label
                loss += torch.relu(pos - neg + self.margin)

        loss = loss / n
        return loss


cross_entropy_loss = nn.CrossEntropyLoss()
squared_loss = nn.MSELoss(reduction='sum')
mean_squared_loss = nn.MSELoss(reduction='mean')
