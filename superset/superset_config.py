import os

# Use a fallback to avoid NoneType errors
SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI", "postgresql://data:Toffkat66@postgres:5432/warehouse")
SECRET_KEY = os.getenv("SUPERSET_SECRET_KEY", "supersecretkey")

# Fix for working behind Nginx
ENABLE_PROXY_FIX = True
WTF_CSRF_ENABLED = True

# Standard Superset requirement to avoid warnings
MAPBOX_API_KEY = os.getenv('MAPBOX_API_KEY', '')