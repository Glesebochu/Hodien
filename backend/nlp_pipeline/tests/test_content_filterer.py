import pytest
from datetime import datetime
from ..services.ContentFilterer import ContentFilterer

@pytest.fixture(scope="module")
def content_filterer():
    """Fixture to initialize the ContentFilterer once for all tests."""
    return ContentFilterer()

@pytest.mark.parametrize(
    "input_data, expected_output",
    [
        (
            ["Why did the scarecrow become a comedian? Because he was outstanding!", "", "Hello"],
            ["Why did the scarecrow become a comedian? Because he was outstanding!", "Hello"]
        )
    ]
)
def test_filter_pre_nlp(content_filterer, input_data, expected_output):
    """Test the filter_pre_nlp method."""
    assert content_filterer.filter_pre_nlp(input_data) == expected_output

@pytest.mark.parametrize(
    "input_data, threshold, expected_output",
    [
        (
            [
                "Why did the scarecrow become a comedian? Because he was outstanding in his field!",
                "The meeting is at 2 PM.",
                "I told my wife to embrace her mistakes... She hugged me."
            ],
            0.5,
            [
                "Why did the scarecrow become a comedian? Because he was outstanding in his field!",
                "I told my wife to embrace her mistakes... She hugged me."
            ]
        )
    ]
)
def test_remove_below_threshold(content_filterer, input_data, threshold, expected_output):
    """Test the remove_below_threshold method."""
    assert content_filterer.remove_below_threshold(input_data, threshold) == expected_output

@pytest.mark.parametrize(
    "start_time, end_time, expected_output",
    [
        (
            datetime(2025, 5, 1, 0, 0, 0),
            datetime(2025, 5, 2, 0, 0, 0),
            2  # Assuming 2 contents were processed in the given time range
        )
    ]
)
def test_get_processed_data(content_filterer, start_time, end_time, expected_output):
    """Test the get_processed_data method."""
    assert content_filterer.get_processed_data(start_time, end_time) == expected_output
