import json
from app.src_lambda import validate_file
import json
from io import StringIO
import sys

def test_lambda_handler_empty_csv(monkeypatch):
    def mock_get_object(Bucket, Key):
        return {
            "Body": open("tests/mocks/test_empty.csv", "rb")
        }

    # Aplica o mock no client boto3 usado dentro do módulo
    monkeypatch.setattr(validate_file.s3, "get_object", mock_get_object)

    event = {
        "Records": [
            {
                "body": json.dumps({
                    "Records": [
                        {
                            "s3": {
                                "bucket": {"name": "meu-bucket"},
                                "object": {"key": "recebimento/test_empty.csv"}
                            }
                        }
                    ]
                })
            }
        ]
    }

    captured_output = StringIO()
    sys.stdout = captured_output

    validate_file.lambda_handler(event, None)

    sys.stdout = sys.__stdout__
    output = captured_output.getvalue()

    assert "não possui a estrutura esperada" in output or "No columns to parse" in output
