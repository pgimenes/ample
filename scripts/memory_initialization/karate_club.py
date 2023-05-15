from sdk.init_manager import InitManager
from sdk.graphs.karate_club import KarateClubGraph
from sdk.models.simple_gcn import SimpleGCN

'''
    Build the KarateClub graph with requested embedding size and generate memory file.
'''

def main():
    # Load graph and generate feature embeddings
    karate = KarateClubGraph()
    # karate.train_embeddings(feature_size = 64)
    karate.random_embeddings()
    karate.random_weights()

    # Initialize Memory

    init_manager = InitManager(karate)
    init_manager.initialize()

    # Dump
    init_manager.dump_memory()
    init_manager.dump_txt()
    init_manager.dump_json()

if (__name__ == "__main__"):
    main()

"""### Train GCN network for club classification"""

# model = SimpleGCN(in_channels=64, out_channels=4)
# model = model.to(device)
# optimizer = torch.optim.Adam(model.parameters(), lr=0.1)

# x = karate.node_embeddings.to(device)
# y = karate[0].y.to(device)

# TO DO : rewrite using lightning

# for epoch in range(1, 201):
#   model.train()
#   optimizer.zero_grad()
#   out = model(x, karate[0].edge_index)
#   loss = F.nll_loss(out[karate[0].train_mask], y[karate[0].train_mask])
#   loss.backward()
#   optimizer.step()

#   pred = out.argmax(dim=1)
#   correct = pred.eq(y).sum().item()
#   train_acc = correct / y[karate[0].train_mask].shape[0]
#   # test_acc = evaluate(model, x, karate[0].edge_index, y, karate[0].test_mask)
#   if epoch % 10 == 0:
#     print(f"Epoch {epoch}, Loss: {loss.item():.4f}, Train Accuracy: {train_acc:.4f}, Test Accuracy: {0}")

# """Get weights"""

# weights = model.state_dict()
# # print(weights.keys())
# conv1_weights = weights["conv1.lin.weight"]
# print(conv1_weights)