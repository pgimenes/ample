



import torch
import torch.nn as nn

class CustomDevice:
    def __init__(self):
        self.device_name = 'custom_module'

    def allocate_memory(self, size):
        init_manager.map_memory() #Has to be done first
        init_manager.dump_memory()
        init_manager.dump_nodeslot_programming()
        init_manager.dump_layer_config()
        # Implement memory allocation for your hardware

    def deallocate_memory(self, memory):
        # Implement memory deallocation
        pass

    def move_tensor(self, tensor):
        # Implement tensor transfer to the custom device
        pass

    def to(self, obj):
        if isinstance(obj, nn.Module):
          init_manager.map_memory() #Has to be done first
          init_manager.dump_memory()
          init_manager.dump_nodeslot_programming()
          init_manager.dump_layer_config()

        elif isinstance(obj, torch.Tensor):
            # Move tensor to the custom device
            return CustomTensor(obj)
        else:
            raise TypeError(f"Unsupported type {type(obj)} for custom device transfer.")



class CustomTensor(torch.Tensor):
    @staticmethod
    def __new__(cls, data):
        return torch.Tensor._make_subclass(cls, data, requires_grad=data.requires_grad)

    def to(self, device):
        if isinstance(device, CustomDevice):
            # Move the tensor data to your custom hardware
            return CustomTensor(self.data)
        return super().to(device)



# Initialize the custom device
custom_device = CustomDevice()

# Initialize your model
model = MyModel()

# Move the model to the custom device
model = custom_device.to(model)

# Create an input tensor and move it to the custom device
input_tensor = torch.randn(1, 3, 224, 224)
input_tensor = custom_device.to(input_tensor)

# Perform forward pass
output = model(input_tensor)



# import torch
# import torch.nn as nn

# class Ample(torch.device):
#     def __init__(self):
#         super().__init__('custom_module')

#     def allocate_memory(self, size):
#         # Implement memory allocation for your hardware
#         pass

#     def deallocate_memory(self, memory):
#         # Implement memory deallocation
#         pass

#     def move_tensor(self, tensor):
#         # Implement tensor transfer to the custom device
#         pass

#     def to(self, model):
#         if isinstance(model, nn.Module):
#             # Move all layers of the model to the custom device
#             for layer in model.children():
#                 layer.to('custom_module')
#             return model
#         elif isinstance(model, torch.Tensor):
#             # Move tensor to the custom device
#             return CustomTensor(model)
#         else:
#             raise TypeError(f"Unsupported type {type(model)} for custom device transfer.")




# class CustomTensor(torch.Tensor):
#     @staticmethod
#     def __new__(cls, data):
#         return torch.Tensor._make_subclass(cls, data, requires_grad=data.requires_grad)

#     def to(self, device):
#         if device == 'custom_module':
#             # Move the tensor data to your custom hardware
#             return CustomTensor(self.data)
#         return super().to(device)



# class MyModel(nn.Module):
#     def __init__(self):
#         super(MyModel, self).__init__()
#         # Define your model layers here

#     def forward(self, x):
#         # Define forward pass
#         pass

#     def to(self, device):
#         if isinstance(device, CustomDevice) and device == 'custom_module':
#             # Use the CustomDevice to move layers to the custom hardware
#             device.to(self)
#             return self
#         return super().to(device)


# # Initialize the custom device
# custom_device = CustomDevice()

# # Initialize the model and move it to the custom device
# model = MyModel().to(custom_device)

# # Create an input tensor and move it to the custom device
# input_tensor = CustomTensor(torch.randn(1, 3, 224, 224)).to(custom_device)

# # Perform forward pass
# output = model(input_tensor)
