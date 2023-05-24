from sdk.models.models import GCN_Model, GAT_Model, GraphSAGE_Model
import torch
import pytorch_lightning as pl

model_map ={
  'gcn': {
    'class': lambda: GCN_Model (4, 4)
  },

  'gat': {
    'class': lambda: GAT_Model (4, 4)
  },

  'sage': {
    'class': lambda: GraphSAGE_Model (4, 4)
  }
}

class GNN_Model(pl.LightningModule):
  def __init__(self, model):
    super().__init__()

    # Define model based on constructor argument
    self.model = model_map[model]['class']()

    # self.starter, self.ender = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    self.loss_criterion = torch.nn.CrossEntropyLoss(reduction="sum")

  def forward(self, x, edge_index):
    return self.model(x, edge_index)

  def training_step(self, batch, batch_index):
    x, edge_index = batch.x, batch.edge_index
    y = batch.y

    out = self.forward(x, edge_index)

    # need to mask out trained nodes?
    loss = self.loss_criterion(out[batch.train_mask], y[batch.train_mask])

    # prediction is maximum likelihood from log softmax probabilities
    pred = out[batch.train_mask].argmax(dim=1) # dim=1 : per row
    acc = self.accuracy(pred, y[batch.train_mask])

    self.log("loss/train", loss)
    self.log("accuracy/train", acc)

    return loss

  def validation_step(self, batch, batch_index):
    x, edge_index = batch.x, batch.edge_index
    y = batch.y

    # Compute forward pass for entire batch (train + val)
    out = self.forward(x, edge_index)

    loss = self.loss_criterion(out[batch.val_mask], y[batch.val_mask])
    pred = out[batch.val_mask].argmax(dim=1)
    return out[batch.val_mask], pred, y[batch.val_mask]

  def validation_epoch_end(self, validation_step_outputs):
    val_loss = 0
    num_correct = 0
    num_total = 0

    for out, pred, labels in validation_step_outputs:
      val_loss += self.loss_criterion(out, labels)
      num_correct += (pred == labels).sum()
      num_total += pred.shape[0]
      
      val_accuracy = num_correct / num_total
      val_loss = val_loss/num_total

    self.log("accuracy/val", val_accuracy)
    self.log("loss/val", val_loss)

  def predict_step(self, batch, batch_index):
    x, edge_index = batch.x, batch.edge_index
    torch.cuda.empty_cache()
    self.starter.record()
    _ = self.model(x, edge_index)
    self.ender.record()
    torch.cuda.synchronize()
    inference_time = self.starter.elapsed_time(self.ender)
    return inference_time

  def configure_optimizers(self):
    return torch.optim.Adam(self.parameters(), lr=0.005, weight_decay=5e-4)

  def accuracy(self, pred_y, y):
    """Calculate accuracy."""
    return ((pred_y == y).sum() / len(y)).item()