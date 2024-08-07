import torch
import torch.nn as nn

class CustomModule(nn.Module):
    def to(self, device=None, *args, **kwargs):
        if isinstance(device, str) and device == 'fpga':
            # Custom logic to move the model's parameters to FPGA
            self.move_to_fpga()
            return self
        else:
            # Use the default behavior for other devices (CPU/GPU)
            return super(CustomModule, self).to(device, *args, **kwargs)
    
    def move_to_fpga(self):
        # Implement logic to move the module's parameters to FPGA
        print("Moving model parameters to FPGA (simulated).")
        for name, param in self.named_parameters():
            # Replace this with the actual FPGA logic
            print(f"Moving parameter {name} to FPGA")
            #Create the payload - use stuff from initialize
            # You would normally move param.data to FPGA here
    def evaluate(self, input): #Change function to be evalute
        # Implement logic to run the model on FPGA
        # For simplicity, we'll just print a message    
        # In real use, you'd perform actual data movement or conversion
        # Also, ensure that the moved parameters are properly managed

# Define a simple model for demonstration
class MyModel(CustomModule):
    def __init__(self):
        super(MyModel, self).__init__()
        self.fc1 = nn.Linear(10, 20)
        self.fc2 = nn.Linear(20, 1)

    def forward(self, x):
        x = self.fc1(x)
        x = torch.relu(x)
        x = self.fc2(x)
        return x

# Example usage
model = MyModel()

# Move the model to FPGA
model.to('fpga')

# Move the model to GPU
model.to('cuda')

# Move the model back to CPU
model.to('cpu')



# Save the original to() method
original_to = nn.Module.to

def custom_global_to(self, device=None, *args, **kwargs):
    if isinstance(device, str) and device == 'fpga':
        print("Moving model parameters to FPGA (simulated).")
        for name, param in self.named_parameters():
            print(f"Moving parameter {name} to FPGA")
        return self
    else:
        # Fallback to the original method
        return original_to(self, device, *args, **kwargs)

# Apply the monkey patch
nn.Module.to = custom_global_to

# Now any model instance will use the custom to() logic
model = MyModel()
model.to('fpga')



import torch
import torch.nn as nn

def custom_to(model, device=None, *args, **kwargs):
    if isinstance(device, str) and device == 'ample':
        # Custom logic to move the model's parameters to FPGA
        print("Moving model parameters to FPGA (simulated).")
        for name, param in model.named_parameters():
            # Replace this with the actual FPGA logic
            print(f"Moving parameter {name} to FPGA")
            # In a real implementation, you'd move param.data to FPGA here
            
        return model
    else:
        # Use the default behavior for other devices (CPU/GPU)
        return torch.nn.Module.to(model, device, *args, **kwargs)

# Define a simple model for demonstration
class MyModel(nn.Module):
    def __init__(self):
        super(MyModel, self).__init__()
        self.fc1 = nn.Linear(10, 20)
        self.fc2 = nn.Linear(20, 1)

    def forward(self, x):
        x = self.fc1(x)
        x = torch.relu(x)
        x = self.fc2(x)
        return x

# Instantiate the model
model = MyModel()

# Patch the `to()` method on this specific model instance
model.to = lambda device=None, *args, **kwargs: custom_to(model, device, *args, **kwargs)

# Now you can use model.to('fpga')
model.to('ample')

# You can still move to GPU or CPU as usual
model.to('cuda')
model.to('cpu')

      init_manager.map_memory() #Has to be done first
        init_manager.dump_memory()
        init_manager.dump_nodeslot_programming()
        init_manager.dump_layer_config()
        # init_manager.embedding_expectation()
        init_manager.save_model()
        init_manager.save_graph()

