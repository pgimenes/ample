import torch
from torch_geometric.datasets import Reddit2
from torch_geometric.datasets import Flickr
from torch_geometric.datasets import Yelp

from sdk.trained_graph import TrainedGraph

class RedditGraph(TrainedGraph):
    def __init__(self, embeddings=[], weights=[]):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        dataset = Reddit2(root='data/Reddit')[0]
        embeds = dataset.x if embeddings == [] else embeddings
        super().__init__(dataset=dataset, embeddings=embeds, weights=weights)

class FlickrGraph(TrainedGraph):
    def __init__(self, embeddings=[], weights=[]):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        dataset = Flickr(root='data/Flickr')[0]
        embeds = dataset.x if embeddings == [] else embeddings
        super().__init__(dataset=dataset, embeddings=embeds, weights=weights)

class YelpGraph(TrainedGraph):
    def __init__(self, embeddings=[], weights=[]):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        dataset = Yelp(root='data/Yelp')[0]
        embeds = dataset.x if embeddings == [] else embeddings
        super().__init__(dataset=dataset, embeddings=embeds, weights=weights)