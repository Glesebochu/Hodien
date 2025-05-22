import pytest
import json
from unittest.mock import MagicMock
from ..services.Indexer import Indexer

@pytest.fixture(scope="module")
def indexer():
    """Fixture to initialize the Indexer once for all tests."""
    return Indexer()

@pytest.mark.parametrize(
    "input_record, expected_terms",
    [
        (
            {"id": "1", "text": "Why did the scarecrow become a comedian? He's outstanding!"},
            [
                ("scarecrow", "1"),
                ("become", "1"),
                ("comedian", "1"),
                ("outstand", "1")
            ],
        ),
        (
            {"id": "2", "text": "The meeting is at 2 PM."},
            [
                ("meet", "2"),
                ("2", "2"),
                ("pm", "2")
            ],
        )
    ]
)
def test_process_record(indexer, input_record, expected_terms):
    """Test the process_record method with parameterized inputs."""
    term_data, processed_record = indexer.process_record(input_record)
    
    assert term_data == expected_terms

def test_build_index(indexer, tmp_path):
    """Test the build_index method."""
    input_csv_path = tmp_path / "test_humor.csv"
    input_csv_path.write_text(
        "id,text,emoji_presence,humor_type,humor_type_score\n"
        "1,Why did the scarecrow become a comedian? He's outstanding!,false,2,0.9\n"
        "2,What do you call a bear with no teeth? A gummy bear!,false,2,0.8\n"
        "3,Why did the fake spaghetti become outstanding? An impasta!,false,2,0.85\n"
    )
    expected_index = {
        "scarecrow": [
            {
                "id": "1",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 1.0986
            }
        ],
        "comedian": [
            {
                "id": "1",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 1.0986
            }
        ],
        "outstand": [
            {
                "id": "1",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 0.4055
            },
            {
                "id": "3",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.85,
                "weight": 0.4055
            }
        ],
        "bear": [
            {
                "id": "2",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.8,
                "weight": 2.1972
            }
        ],
        "teeth": [
            {
                "id": "2",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.8,
                "weight": 1.0986
            }
        ],
        "gummy": [
            {
                "id": "2",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.8,
                "weight": 1.0986
            }
        ],
        "fake": [
            {
                "id": "3",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.85,
                "weight": 1.0986
            }
        ],
        "spaghetti": [
            {
                "id": "3",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.85,
                "weight": 1.0986
            }
        ],
        "impaste": [
            {
                "id": "3",
                "humor_type": '2',
                "emoji_presence": False,
                "humor_type_score": 0.85,
                "weight": 1.0986
            }
        ],
        'become': [
            {
                'emoji_presence': False,
                'humor_type': '2',
                'humor_type_score': 0.9,
                'id': '1',
                'weight': 0.4055,
            },
            {
                'emoji_presence': False,
                'humor_type': '2',
                'humor_type_score': 0.85,
                'id': '3',
                'weight': 0.4055,
            },
        ],
        'call': [
            {
                'emoji_presence': False,
                'humor_type': '2',
                'humor_type_score': 0.8,
                'id': '2',
                'weight': 1.0986,
            },
        ],
    }
    content_index = indexer.build_index(input_csv_path)
    assert content_index == expected_index


def test_upload_index_term(monkeypatch):
    """Test the upload_index_term method without contacting Firestore."""
    # Mock Firestore client and its methods
    mock_firestore_client = MagicMock()
    mock_collection = MagicMock()
    mock_document = MagicMock()
    mock_firestore_client.collection.return_value = mock_collection
    mock_collection.document.return_value = mock_document

    # Prepare test data that matches the required structure
    term_data = (
        "scarecrow",
        [
            {
                "id": "1",
                "humor_type": "2",
                "emoji_presence": False,
                "humor_type_score": 0.9,
                "weight": 1.0986
            }
        ],
        "content_index"
    )

    # Call the method with the mock Firestore client
    Indexer.upload_index_term(term_data, db=mock_firestore_client)

    # Assertions
    mock_firestore_client.collection.assert_called_with("content_index")
    mock_collection.document.assert_called_with("scarecrow")
    mock_document.set.assert_called_with({'content': [
        {
            "id": "1",
            "humor_type": "2",
            "emoji_presence": False,
            "humor_type_score": 0.9,
            "weight": 1.0986
        }
    ]})

def test_upload_content_item(monkeypatch):
    """Test the upload_content_item method without contacting Firestore."""
    # Mock Firestore client and its methods
    mock_firestore_client = MagicMock()
    mock_collection = MagicMock()
    mock_document = MagicMock()
    mock_firestore_client.collection.return_value = mock_collection
    mock_collection.document.return_value = mock_document

    # Prepare test data with all required fields present and valid
    content_data = (
        "1",
        {
            "id": "1",
            "text": "Why did the scarecrow become a comedian?",
            "emoji_presence": False,
            "humor_type": "2",
            "humor_type_score": 0.9
        },
        "humor_content"
    )

    # Call the method with the mock Firestore client
    Indexer.upload_content_item(content_data, db=mock_firestore_client)

    # Assertions
    mock_firestore_client.collection.assert_called_with("humor_content")
    mock_collection.document.assert_called_with("1")
    mock_document.set.assert_called_with({
        "id": "1",
        "text": "Why did the scarecrow become a comedian?",
        "emoji_presence": False,
        "humor_type": "2",
        "humor_type_score": 0.9
    })
