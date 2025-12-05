import torch
import torchvision.models as models

def export_model():
    print("Downloading MobileNetV2 model...")
    model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)
    model.eval()

    # Створюємо приклад вхідних даних 
    example_input = torch.rand(1, 3, 224, 224)
    print("Tracing model to TorchScript...")
    # Трейсінг моделі
    traced_script_module = torch.jit.trace(model, example_input)

    output_file = "model.pt"
    traced_script_module.save(output_file)
    print(f"Model saved to {output_file}")

if __name__ == "__main__":
    export_model()