import pytest
from ..services.HumorDetector import HumorDetector

@pytest.fixture(scope="module")
def humor_detector():
    """Fixture to initialize the HumorDetector once for all tests."""
    return HumorDetector()

@pytest.mark.parametrize(
    "input_text, expected_output",
    [
        ("Why did the scarecrow become a comedian? Because he was outstanding in his field!", 1),
        ("The meeting is scheduled for 2 PM.", 0),
        ("Where there is a will, there is a way.", 0),
        ("I slipped on a banana peel and landed in therapy. Apparently, it triggered some deep-rooted issues.", 1),
        ("Did you hear about the guy whose left side was cut off? He's all right now.", 1),
        ("Why don't skeletons fight each other? They don't have the guts.", 1),
        ("The weather is sunny today.", 0),
        ("I told my wife she was drawing her eyebrows too high. She looked surprised.", 1),
        ("I need to buy groceries after work.", 0),
        ("Parallel lines have so much in common. It's a shame they'll never meet.", 1),
    ],
)
def test_humor_detector_predict(humor_detector, input_text, expected_output):
    """Test the predict method of HumorDetector with various inputs."""
    assert humor_detector.predict(input_text)[0] == expected_output

@pytest.mark.parametrize(
    "input_text, expected_output",
    [
        ("", 0),  # Empty string
        ("2342039843", 0),
        ("#$%*&^%$#@$#^%", 0),
    ],
)
def test_humor_detector_edge_cases(humor_detector, input_text, expected_output):
    """Test the predict method of HumorDetector with edge cases."""
    assert humor_detector.predict(input_text)[0] == expected_output

@pytest.mark.parametrize(
    "input_text, min_humor_score",
    [
        ("Why did the scarecrow become a comedian? Because he was outstanding in his field!", 0.5),
        ("The meeting is scheduled for 2 PM.", 0.0),
        ("I slipped on a banana peel and landed in therapy. Apparently, it triggered some deep-rooted issues.", 0.7),
        ("Did you hear about the guy whose left side was cut off? He's all right now.", 0.6),
        ("Why don't skeletons fight each other? They don't have the guts.", 0.5),
        ("The weather is sunny today.", 0.0),
        ("I told my wife she was drawing her eyebrows too high. She looked surprised.", 0.6),
        ("I need to buy groceries after work.", 0.0),
        ("Parallel lines have so much in common. It's a shame they'll never meet.", 0.5),
        ("", 0.0),  # Empty string
        ("#$%*&^%$#@$#^%", 0.0),  # Special characters
    ],
)
def test_humor_score(humor_detector, input_text, min_humor_score):
    """Test the humor score as an inequality."""
    humor_score = humor_detector.predict(input_text)[1]
    assert humor_score >= min_humor_score
