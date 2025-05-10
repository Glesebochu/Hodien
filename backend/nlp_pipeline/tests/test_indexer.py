import pytest
import json
from unittest.mock import MagicMock
from ..services.Indexer import Indexer

@pytest.fixture(scope="module")
def indexer():
    """Fixture to initialize the Indexer once for all tests."""
    return Indexer()

def test_process_record(indexer):
    """Test the process_record method."""
    input_record = {"id": "1", "text": "Why did the scarecrow become a comedian? He's outstanding!"}
    expected_terms = [
        ("scarecrow", "1"),
        ("comedian", "1"),
        ("outstanding", "1")
    ]
    term_data, processed_record = indexer.process_record(input_record)
    assert term_data == expected_terms
    assert processed_record == input_record

def test_build_index(indexer, tmp_path):
    """Test the build_index method."""
    input_csv_path = tmp_path / "test_humor.csv"
    input_csv_path.write_text(
        "id,text,emoji_presence,humor_type,humor_type_score\n"
        "1,Why did the scarecrow become a comedian? He's outstanding!,false,pun,0.9\n"
        "2,The meeting is at 2 PM.,false,neutral,0.5\n"
    )
    expected_index = {
        "scarecrow": [
            {
                "id": "1",
                "humor_type": "pun",
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 0.6931
            }
        ],
        "comedian": [
            {
                "id": "1",
                "humor_type": "pun",
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 0.6931
            }
        ],
        "outstanding": [
            {
                "id": "1",
                "humor_type": "pun",
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 0.6931
            }
        ],
        "meeting": [
            {
                "id": "2",
                "humor_type": "neutral",
                "emoji_presence": False,
                "humor_type_score": 0.5,
                "weight": 0.6931
            }
        ]
    }
    content_index = indexer.build_index(input_csv_path)
    assert content_index == expected_index

def test_push_index_to_firestore(indexer, monkeypatch):
    """Test the push_index_to_firestore method."""
    mock_firestore_client = MagicMock()
    monkeypatch.setattr(indexer, "firestore_client", mock_firestore_client)

    index_data = {
        "scarecrow": {"tfidf": 0.5, "docs": ["1"]},
        "meeting": {"tfidf": 0.3, "docs": ["2"]}
    }
    indexer.push_index_to_firestore(index_data)

    mock_firestore_client.collection.assert_called_with("index")
    assert mock_firestore_client.collection().document.call_count == len(index_data)

def test_push_content_to_firestore(indexer, monkeypatch, tmp_path):
    """Test the push_content_to_firestore method."""
    mock_firestore_client = MagicMock()
    monkeypatch.setattr(indexer, "firestore_client", mock_firestore_client)

    input_csv_path = tmp_path / "test_humor.csv"
    input_csv_path.write_text(
        "id,text\n"
        "1,Why did the scarecrow become a comedian? He's outstanding!\n"
        "2,The meeting is at 2 PM.\n"
    )
    indexer.push_content_to_firestore(input_csv_path, collection_name="humor_content")

    mock_firestore_client.collection.assert_called_with("humor_content")
    assert mock_firestore_client.collection().document.call_count == 2
