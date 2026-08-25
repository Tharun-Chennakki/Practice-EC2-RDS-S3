"""
Flask Web Application with AWS RDS MySQL Database Connection
This application provides user registration and login functionality with a MySQL database.
"""

import os
import re
from dotenv import load_dotenv
import pymysql
from werkzeug.security import generate_password_hash, check_password_hash
from flask import Flask, render_template, request, redirect, url_for, session, flash

# Load environment variables from .env file
load_dotenv()

# Initialize Flask application
app = Flask(__name__)
app.secret_key = 'your-secret-key-change-this'

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================
# Retrieve database credentials from environment variables
DB_HOST = os.getenv('DB_HOST')
DB_PORT = int(os.getenv('DB_PORT', 3306))
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')

# Debug: Verify credentials are loaded
print(f"[DEBUG] Database Configuration Loaded:")
print(f"  DB_HOST: {DB_HOST}")
print(f"  DB_PORT: {DB_PORT}")
print(f"  DB_NAME: {DB_NAME}")
print(f"  DB_USER: {DB_USER}")
print(f"  DB_PASSWORD: {'*' * len(DB_PASSWORD) if DB_PASSWORD else 'NOT SET'}")


def get_db_connection():
    """
    Establishes a connection to the AWS RDS MySQL database.
    
    Returns:
        pymysql.Connection: A database connection object.
    
    Raises:
        pymysql.Error: If connection fails.
    """
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.Error as e:
        print(f"Database connection error: {e}")
        raise


def create_database():
    """
    Creates the database if it does not already exist.
    This function is called when the application starts.
    """
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Create database if it doesn't exist
        create_db_query = f"CREATE DATABASE IF NOT EXISTS {DB_NAME}"
        cursor.execute(create_db_query)
        
        print(f"Database '{DB_NAME}' is ready.")
        cursor.close()
        connection.close()
    except pymysql.Error as e:
        print(f"Error creating database: {e}")


def get_db_connection_with_db():
    """
    Establishes a connection to the AWS RDS MySQL database with the specific database selected.
    
    Returns:
        pymysql.Connection: A database connection object connected to the specified database.
    """
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.Error as e:
        print(f"Database connection error: {e}")
        raise


def create_users_table():
    """
    Creates the 'users' table if it does not already exist.
    Table structure:
        - id: Primary key, auto-increment
        - username: User's username (unique)
        - email: User's email address (unique)
        - password: Hashed password
        - created_at: Timestamp when user registered
    
    This function is called when the application starts.
    """
    try:
        connection = get_db_connection_with_db()
        cursor = connection.cursor()
        
        # Create users table if it doesn't exist
        create_table_query = """
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) NOT NULL UNIQUE,
            email VARCHAR(100) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        cursor.execute(create_table_query)
        connection.commit()
        
        print("Table 'users' is ready.")
        cursor.close()
        connection.close()
    except pymysql.Error as e:
        print(f"Error creating table: {e}")


def validate_email(email):
    """
    Validates email format using regex.
    
    Args:
        email (str): Email address to validate.
    
    Returns:
        bool: True if email format is valid, False otherwise.
    """
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(email_pattern, email) is not None


def validate_password(password):
    """
    Validates password strength.
    Password must be at least 6 characters long.
    
    Args:
        password (str): Password to validate.
    
    Returns:
        bool: True if password meets requirements, False otherwise.
    """
    return len(password) >= 6


# ============================================================================
# REGISTRATION ROUTE
# ============================================================================
@app.route('/', methods=['GET', 'POST'])
@app.route('/register', methods=['GET', 'POST'])
def register():
    """
    Handles user registration.
    
    GET: Display the registration form.
    POST: Process the registration form submission.
        - Validates username, email, and password.
        - Hashes the password using werkzeug.security.
        - Stores the user in the MySQL database.
    """
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')
        
        # Validate input
        if not username or not email or not password or not confirm_password:
            flash('All fields are required.', 'error')
            return redirect(url_for('register'))
        
        if not validate_email(email):
            flash('Invalid email format.', 'error')
            return redirect(url_for('register'))
        
        if not validate_password(password):
            flash('Password must be at least 6 characters long.', 'error')
            return redirect(url_for('register'))
        
        if password != confirm_password:
            flash('Passwords do not match.', 'error')
            return redirect(url_for('register'))
        
        try:
            # Connect to database
            connection = get_db_connection_with_db()
            cursor = connection.cursor()
            
            # Check if user already exists
            check_user_query = "SELECT * FROM users WHERE email = %s OR username = %s"
            cursor.execute(check_user_query, (email, username))
            
            if cursor.fetchone():
                flash('Email or username already exists.', 'error')
                cursor.close()
                connection.close()
                return redirect(url_for('register'))
            
            # Hash the password
            hashed_password = generate_password_hash(password)
            
            # Insert user into database
            insert_query = "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)"
            cursor.execute(insert_query, (username, email, hashed_password))
            connection.commit()
            
            flash('Registration successful! You can now log in.', 'success')
            cursor.close()
            connection.close()
            
            return redirect(url_for('login'))
        
        except pymysql.Error as e:
            flash(f'Registration failed: {str(e)}', 'error')
            return redirect(url_for('register'))
    
    return render_template('register.html')


# ============================================================================
# LOGIN ROUTE
# ============================================================================
@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    Handles user login.
    
    GET: Display the login form.
    POST: Process the login form submission.
        - Retrieves the user from the MySQL database using email.
        - Verifies the password using werkzeug.security.
        - Creates a session if credentials are correct.
    """
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        # Validate input
        if not email or not password:
            flash('Email and password are required.', 'error')
            return redirect(url_for('login'))
        
        try:
            # Connect to database
            connection = get_db_connection_with_db()
            cursor = connection.cursor()
            
            # Query user by email
            query = "SELECT * FROM users WHERE email = %s"
            cursor.execute(query, (email,))
            user = cursor.fetchone()
            
            cursor.close()
            connection.close()
            
            # Verify user and password
            if user and check_password_hash(user['password'], password):
                session['user_id'] = user['id']
                session['username'] = user['username']
                session['email'] = user['email']
                flash(f'Login successful! Welcome, {user["username"]}', 'success')
                return redirect(url_for('dashboard'))
            else:
                flash('Invalid email or password.', 'error')
                return redirect(url_for('login'))
        
        except pymysql.Error as e:
            flash(f'Login failed: {str(e)}', 'error')
            return redirect(url_for('login'))
    
    return render_template('login.html')


# ============================================================================
# DASHBOARD ROUTE
# ============================================================================
@app.route('/dashboard')
def dashboard():
    """
    Displays the user dashboard (protected route).
    Only accessible if the user is logged in (session exists).
    """
    if 'user_id' not in session:
        flash('Please log in first.', 'error')
        return redirect(url_for('login'))
    
    return render_template('dashboard.html', username=session.get('username'))


# ============================================================================
# LOGOUT ROUTE
# ============================================================================
@app.route('/logout')
def logout():
    """
    Logs out the user by clearing the session.
    Redirects to the login page.
    """
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('login'))


# ============================================================================
# APPLICATION STARTUP
# ============================================================================
if __name__ == '__main__':
    """
    Application entry point.
    - Creates the database if it doesn't exist.
    - Creates the users table if it doesn't exist.
    - Starts the Flask development server.
    """
    print("Initializing database...")
    try:
        create_database()
        create_users_table()
        print("Database initialized successfully!")
    except Exception as e:
        print(f"Warning: Could not initialize database: {e}")
        print("The application will start but database operations will fail.")
        print("Please ensure AWS RDS is running and credentials are correct in .env")
    
    print("\n" + "="*70)
    print("🚀 Flask Web Application Starting...")
    print("="*70)
    print(f"📍 Application URL: http://localhost:5000")
    print(f"📍 Port Number: 5000")
    print(f"📍 Register Page: http://localhost:5000/register")
    print(f"📍 Login Page: http://localhost:5000/login")
    print("="*70 + "\n")
    
    # Start Flask development server (debug mode for development)
    app.run(debug=True, host='0.0.0.0', port=5000)
