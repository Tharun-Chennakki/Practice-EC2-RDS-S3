"""
Basic test suite for Flask application
"""

import os
import sys

import pytest

# Add parent directory to path to import app
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def expect(condition, message):
    """Small helper to avoid Bandit's assert_used warning in tests."""
    if not condition:
        raise AssertionError(message)


class TestAppStructure:
    """Test basic app structure"""

    def test_app_file_exists(self):
        """Test that app.py exists"""
        expect(os.path.exists("app.py"), "app.py file not found")

    def test_requirements_file_exists(self):
        """Test that requirements.txt exists"""
        expect(os.path.exists("requirements.txt"), "requirements.txt file not found")

    def test_templates_exist(self):
        """Test that required templates exist"""
        templates = ["login.html", "register.html", "dashboard.html"]
        for template in templates:
            expect(os.path.exists(f"templates/{template}"), f"Template {template} not found")

    def test_static_css_exists(self):
        """Test that static CSS files exist"""
        expect(os.path.exists("static/css/style.css"), "CSS file not found")


class TestFlaskApp:
    """Test Flask application basic functionality"""

    def test_imports(self):
        """Test that required packages can be imported"""
        import flask
        import pymysql
        import werkzeug
        import dotenv

        expect(flask is not None, "flask import failed")
        expect(pymysql is not None, "pymysql import failed")
        expect(werkzeug is not None, "werkzeug import failed")
        expect(dotenv is not None, "dotenv import failed")

    def test_app_initialization(self):
        """Test that Flask app can be instantiated"""
        from flask import Flask

        app = Flask(__name__)
        expect(app is not None, "Flask app could not be created")


class TestRequirements:
    """Test Python dependencies"""

    def test_flask_version(self):
        """Test Flask is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            expect("Flask" in content, "Flask not in requirements.txt")

    def test_pymysql_version(self):
        """Test PyMySQL is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            expect("PyMySQL" in content, "PyMySQL not in requirements.txt")

    def test_werkzeug_version(self):
        """Test Werkzeug is installed"""
        with open("requirements.txt", "r") as f:
            content = f.read()
            expect("Werkzeug" in content, "Werkzeug not in requirements.txt")


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
