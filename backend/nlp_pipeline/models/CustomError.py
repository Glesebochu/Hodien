from datetime import datetime

class CustomError(Exception):
    def __init__(self, message):
        super().__init__(message)
        self.timestamp = datetime.now()

    def __str__(self):
        return f"{super().__str__()} (Occurred at: {self.timestamp})"
