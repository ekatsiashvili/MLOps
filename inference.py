import torch
import sys
from PIL import Image
from torchvision import transforms

try:
    import requests
    LABELS_URL = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt"
    labels = requests.get(LABELS_URL).text.splitlines()
except:
    labels = [f"Class {i}" for i in range(1000)]

def predict(image_path, model_path="model.pt"):
    preprocess = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])

    try:
        input_image = Image.open(image_path).convert('RGB')
    except FileNotFoundError:
        print(f"Error: Image {image_path} not found.")
        return

    input_tensor = preprocess(input_image)
    input_batch = input_tensor.unsqueeze(0) 

    # Завантаження TorchScript моделі
    if torch.cuda.is_available():
        device = 'cuda'
    else:
        device = 'cpu'
    
    model = torch.jit.load(model_path, map_location=device)
    model.eval()

    with torch.no_grad():
        output = model(input_batch.to(device))

    # Отримання топ-3 результатів
    probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top3_prob, top3_catid = torch.topk(probabilities, 3)

    print(f"\n--- Prediction for {image_path} ---")
    for i in range(top3_prob.size(0)):
        print(f"{labels[top3_catid[i]]}: {top3_prob[i].item()*100:.2f}%")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python inference.py <image_path>")
        # Для тесту 
        img = Image.new('RGB', (224, 224), color = 'red')
        img.save('test_image.jpg')
        predict('test_image.jpg')
    else:
        predict(sys.argv[1])