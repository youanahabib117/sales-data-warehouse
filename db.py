from sqlalchemy import create_engine
import os

def get_engine():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    db_path = os.path.join(base_dir, "business.db")
    return create_engine(f"sqlite:///{db_path}")
