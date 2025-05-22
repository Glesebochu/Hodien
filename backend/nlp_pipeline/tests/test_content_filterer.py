import pytest
from datetime import datetime
from ..services.ContentFilterer import ContentFilterer
from ...shared_utils.models.Content import Content
from datetime import timedelta

@pytest.fixture(scope="module")
def content_filterer():
    """Fixture to initialize the ContentFilterer once for all tests."""
    return ContentFilterer()

@pytest.mark.parametrize(
    "input_data, expected_output",
    [
        (
            [
                Content(id=1, text="Why did the scarecrow become a comedian? Because he was outstanding!"),
                Content(id=2, text=""),
                Content(id=3, text="Hello")
            ],
            [
                Content(id=1, text="Why did the scarecrow become a comedian? Because he was outstanding!"),
                Content(id=3, text="Hello")
            ]
        )
    ]
)
def test_filter_pre_nlp(content_filterer, input_data, expected_output):
    """Test the filter_pre_nlp method."""
    assert [(content.id, content.text) for content in content_filterer.filter_pre_nlp(input_data)] == [(content.id, content.text) for content in expected_output]

@pytest.mark.parametrize(
    "input_data, threshold, expected_output",
    [
        (
            [
                Content(id=1, text="Why did the scarecrow become a comedian? Because he was outstanding in his field!", humor_score=0.8),
                Content(id=2, text="The meeting is at 2 PM.", humor_score=0.3),
                Content(id=3, text="I told my wife to embrace her mistakes... She hugged me.", humor_score=0.7)
            ],
            0.5,
            [
                Content(id=1, text="Why did the scarecrow become a comedian? Because he was outstanding in his field!", humor_score=0.8),
                Content(id=3, text="I told my wife to embrace her mistakes... She hugged me.", humor_score=0.7)
            ]
        )
    ]
)
def test_remove_below_threshold(content_filterer, input_data, threshold, expected_output):
    """Test the remove_below_threshold method."""
    assert [(content.id, content.text, content.humor_score) for content in content_filterer.remove_below_threshold(input_data, threshold)] == [(content.id, content.text, content.humor_score) for content in expected_output]

@pytest.mark.parametrize(
    "start_time, end_time, expected_output",
    [
        (
            datetime.now() - timedelta(hours=1),  # Yesterday
            datetime.now() + timedelta(hours=1),  # Today
            2  # Assuming 2 contents were processed in the given time range
        )
    ]
)
def test_get_processed_data(content_filterer, start_time, end_time, expected_output):
    """Test the get_processed_data method."""
    print("Before processing:", content_filterer.processed_log)
    print("Start time:", start_time)
    print("End time:", end_time)
    assert content_filterer.get_processed_data(start_time, end_time) == expected_output
