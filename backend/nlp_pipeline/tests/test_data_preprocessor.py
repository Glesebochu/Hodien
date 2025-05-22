import pytest
from ...shared_utils.services.DataPreprocessor import DataPreprocessor

@pytest.fixture(scope="module")
def data_preprocessor():
    """Fixture to initialize the DataPreprocessor once for all tests."""
    return DataPreprocessor()

@pytest.mark.parametrize(
    "input_text, expected_output",
    [
        (
            "Why did the Scarecrow become a Comedian? He's outstanding!",
            ["Why", "did", "the", "Scarecrow", "become", "a", "Comedian?", "He's", "outstanding!"]
        )
    ]
)
def test_tokenize(data_preprocessor, input_text, expected_output):
    """Test the tokenize method."""
    assert data_preprocessor.tokenize(input_text) == expected_output

@pytest.mark.parametrize(
    "input_tokens, expected_output",
    [
        (
            ["Why", "did", "the", "Scarecrow'", "!", None],
            ["why", "did", "the", "scarecrow"]
        )
    ]
)
def test_normalize(data_preprocessor, input_tokens, expected_output):
    """Test the normalize method."""
    assert data_preprocessor.normalize(input_tokens) == expected_output

@pytest.mark.parametrize(
    "input_tokens, expected_output",
    [
        (
            ["why", "did", "the", "scarecrow", "become", "comedian"],
            ["scarecrow", "become", "comedian"]
        )
    ]
)
def test_remove_stop_words(data_preprocessor, input_tokens, expected_output):
    """Test the remove_stop_words method."""
    assert data_preprocessor.remove_stop_words(input_tokens) == expected_output

@pytest.mark.parametrize(
    "input_tokens, expected_output",
    [
        (
            ["scarecrow", "commedian", "outstandng"],
            ["scarecrow", "comedian", "outstanding"]
        ),
        (
            ["paralel", "liness", "comon", "shame", "theyll", "nevr", "meet"],
            ["parallel", "lines", "common", "shame", "they'll", "never", "meet"]
        ),
        (
            ["told", "wiffe", "drawng", "eyebrows", "hgh", "looked", "suprised"],
            ["told", "wife", "drawing", "eyebrows", "high", "looked", "surprised"]
        ),
    ]
)
def test_correct_spelling(data_preprocessor, input_tokens, expected_output):
    """Test the correct_spelling method."""
    assert data_preprocessor.correct_spelling(input_tokens) == expected_output

@pytest.mark.parametrize(
    "input_tokens, expected_output",
    [
        (
            ["scarecrow", "comedian", "outstanding"],
            ["scarecrow", "comedian", "outstand"]
        ),
        (
            ["parallel", "lines", "common", "shame", "they", "never", "meet"],
            ["parallel", "line", "common", "shame", "they", "never", "meet"]
        ),
        (
            ["told", "wife", "drawing", "eyebrows", "high", "looked", "surprised"],
            ["told", "wife", "draw", "eyebrow", "high", "look", "surprise"]
        ),
    ]
)
def test_stem_tokens(data_preprocessor, input_tokens, expected_output):
    """Test the stem_tokens method."""
    assert data_preprocessor.stem_tokens(input_tokens) == expected_output
