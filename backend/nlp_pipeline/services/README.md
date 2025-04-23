# Humor Detector

The Humor Detector is a machine learning pipeline for detecting humor in text using a fine-tuned BERT model.

## Features
- Preprocessing: Text cleaning, lemmatization, and tokenization.
- Model Training: Fine-tune a DistilBERT model for humor classification.
- Bulk Prediction: Predict humor scores for a batch of text data from a CSV file.
- Evaluation: Generate classification reports and confusion matrices.

## Setup Instructions

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

### Installation
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Download NLTK resources:
   ```bash
   python -m nltk.downloader wordnet stopwords
   ```

3. Ensure GPU support (optional):
   - Install TensorFlow with GPU support: [TensorFlow GPU Installation Guide](https://www.tensorflow.org/install/gpu).

### Configuration
Edit the `config.yaml` file to customize paths, model parameters, and hyperparameters:
```yaml
model_path: "finetuned_distilbert"
batch_size: 32
epochs: 3
learning_rate: 2e-5
text_column: "text"
label_column: "humorous"
```

## Usage

### Training the Model
Run the following command to train the model:
```bash
python -c "from backend.nlp_pipeline.services.HumorDetector import HumorDetector; HumorDetector().train()"
```

### Bulk Prediction
Predict humor scores for a CSV file:
```bash
python -c "from backend.nlp_pipeline.services.HumorDetector import HumorDetector; HumorDetector().predict_score_bulk('input.csv', 'output.csv')"
```

### Evaluation
After training, the following files will be generated:
- `classification_report.json`: Detailed classification report.
- `confusion_matrix.png`: Confusion matrix visualization.

## Dependencies
- Python libraries:
  - `numpy`
  - `pandas`
  - `transformers`
  - `tensorflow`
  - `nltk`
  - `scikit-learn`
  - `matplotlib`
  - `pyyaml`

Install all dependencies using:
```bash
pip install -r requirements.txt
```