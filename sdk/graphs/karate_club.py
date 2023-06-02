
from sdk.trained_graph import TrainedGraph

import torch
from torch_geometric.datasets import KarateClub
from torch_geometric.nn import Node2Vec

class KarateClubGraph(TrainedGraph):
    def __init__(self, feature_count=64):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.feature_count=feature_count

        dataset = KarateClub()[0]
        embeds = dataset.x
        super().__init__(dataset=dataset, embeddings=embeds)

    def train_embeddings(self, feature_size=64, walk_length=10, context_size=5, walks_per_node=10, num_negative_samples=1, sparse=True):
        self.feature_count=feature_size
        n2v_model = Node2Vec(
            self.dataset.edge_index,
            embedding_dim = feature_size,
            walk_length = walk_length,
            context_size = context_size,
            walks_per_node = walks_per_node,
            num_negative_samples = num_negative_samples,
            sparse = sparse
        ).train()

        loader = n2v_model.loader(batch_size=128, shuffle=True, num_workers=4)
        optimizer = torch.optim.SparseAdam(n2v_model.parameters(), lr=0.01)

        # Training loop
        print(f"==== Starting node2vec training loop ====")
        for epoch in range(1, 101):
            total_loss = 0
            for pos_rw, neg_rw in loader:
                optimizer.zero_grad()
                loss = n2v_model.loss(pos_rw.to(self.device), neg_rw.to(self.device))
                loss.backward()
                optimizer.step()
                total_loss += loss.item()
            if (epoch % 10 == 0):
                print(f"Epoch {epoch}, Loss: {total_loss / len(loader)}")

        self.embeddings = n2v_model.embedding.weight
    
    def __str__(self) -> str:
        return "KarateClub"