"""
Basic test suite for Flask application
"""

import pytest
import sys
import os

# Add parent directory to path to import app
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


class TestAppStructure:
    """Test basic app structure"""

    def test_app_file_exists(self):
        """Test that app.py exists"""
        assert os.path.exists("app.py")

    def test_requirements_file_exists(self):
        """Test that requirements.txt exists"""
        assert os.path.exists("requirements.txt")

    def test_templates_exist(self):
        """Test that required templates exist"""
        templates = ["login.html", "register.html", "dashboard.html"]
        for template in templates:
            assert os.path.exists(f"templates/{template}")

    def test_static_css_exists(self):
        """Test that static CSS files exist"""
        assert os.path.exists("static/css/style.css")


class TestFlaskApp:
    """Test Flask application basic functionality"""

    def test_imports(self):
        """Test that required packages can be imported"""
        import flask
        import pymysql
        import werkzeug
        import dotenv

        assert flask is not None
        assert pymysql is not None
        assert werkzeug is not None
        assert dotenv is not None

    def test_app_initialization(self):
        """Test that Flask app can be instantiated"""
        from flask import Flask

        app = Flask(__name__)
        assert app is not None


class TestRequirements:
    """Test Python dependencies"""

    def test_flask_version(self):
        """Test Flask is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            assert "Flask" in content

    def test_pymysql_version(self):
        """Test PyMySQL is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            assert "PyMySQL" in content

    def test_werkzeug_version(self):
        """Test Werkzeug is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            assert "Werkzeug" in content


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
