import pytest
from ..services.HumorTypeClassifier import HumorTypeClassifier

@pytest.fixture(scope="module")
def humor_classifier():
    """Fixture to initialize the HumorClassifier once for all tests."""
    return HumorTypeClassifier()

@pytest.mark.parametrize(
    "input_text, expected_category, min_score",
    [
        ("I slipped on a banana peel and landed in therapy. Apparently, it triggered some deep-rooted issues.", 1, 0.7),
        ("Did you hear about the guy whose left side was cut off? He's all right now.", 2, 0.6),
        ("I told my wife she should embrace her mistakes... She came and hugged me.", 3, 0.5),
        ("The planet is fine. The people are screwed.", 4, 0.8),
    ],
)
def test_humor_classifier_predict(humor_classifier, input_text, expected_category, min_score):
    """Test the predict method of HumorClassifier with various inputs."""
    category, score = humor_classifier.predict(input_text)
    assert category == expected_category
    assert score >= min_score
