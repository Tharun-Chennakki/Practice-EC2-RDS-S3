# Flask Web Application with AWS RDS MySQL Database

A simple yet robust Flask web application that provides user registration and login functionality with MySQL database integration. This application is designed to connect to an AWS RDS MySQL database and includes password hashing for security.

## Features

- **User Registration**: Create a new account with username, email, and password
- **User Login**: Authenticate users with email and password verification
- **Password Hashing**: Secure password storage using Werkzeug security
- **Session Management**: User sessions for persistent login
- **Environment Variables**: Secure credential management without hardcoding
- **Database Auto-initialization**: Automatic database and table creation
- **Input Validation**: Email format and password strength validation
- **Error Handling**: Comprehensive error messages for user feedback

## Project Structure

```
project/
├── app.py                    # Main Flask application logic
├── requirements.txt          # Python dependencies
├── .env.example              # Example environment variables
├── .gitignore                # Git ignore file
├── README.md                 # Project documentation
├── templates/
    ├── register.html        # Registration form template
    ├── login.html           # Login form template
    └── dashboard.html       # Dashboard template (after login)
└── static/
    └── css/
        └── style.css        # Shared page styles
```

## Prerequisites

- Python 3.7 or higher
- AWS RDS MySQL database instance
- pip (Python package installer)

## Installation

### 1. Clone or Download the Project

Navigate to your project directory:

```bash
cd /path/to/your/project
```

### 2. Create a Virtual Environment

On Windows:
```bash
python -m venv venv
venv\Scripts\activate
```

On macOS/Linux:
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

Install all required Python packages from requirements.txt:

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the project root directory by copying `.env.example`:

```bash
cp .env.example .env
```

Edit the `.env` file and add your AWS RDS database credentials:

```env
DB_HOST=your-rds-endpoint.rds.amazonaws.com
DB_PORT=3306
DB_NAME=loginapp
DB_USER=admin
DB_PASSWORD=your-secure-password
```

**Important**: 
- Replace `your-rds-endpoint.rds.amazonaws.com` with your actual RDS endpoint
- Replace `admin` with your RDS master username
- Replace `your-secure-password` with your RDS master password
- **NEVER commit the `.env` file to version control**

### 5. Verify AWS RDS Connection

Before running the application, ensure:

1. Your AWS RDS MySQL instance is running
2. The security group allows connections on port 3306
3. Your local IP address is whitelisted in the RDS security group
4. Database credentials are correct

You can test the connection using MySQL client:

```bash
mysql -h your-rds-endpoint.rds.amazonaws.com -u admin -p -P 3306
```

## Running the Application

### Start the Flask Development Server

```bash
python app.py
```

You should see output like:
```
Initializing database...
Database 'loginapp' is ready.
Table 'users' is ready.
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://0.0.0.0:5000
```

### Access the Application

Open your web browser and navigate to:

- **Register**: `http://localhost:5000/register` or `http://localhost:5000/`
- **Login**: `http://localhost:5000/login`
- **Dashboard**: `http://localhost:5000/dashboard` (after logging in)

## Usage

### User Registration

1. Navigate to the registration page
2. Enter a username (at least 3 characters)
3. Enter a valid email address
4. Enter a password (at least 6 characters)
5. Confirm your password
6. Click "Register"
7. If successful, you'll be redirected to the login page

### User Login

1. Navigate to the login page
2. Enter your registered email address
3. Enter your password
4. Click "Login"
5. If credentials are correct, you'll be redirected to your dashboard

### Logout

1. Click the "Logout" button on the dashboard
2. You'll be logged out and redirected to the login page

## Database Schema

### Users Table

The application automatically creates a `users` table with the following structure:

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Table Columns:**
- `id`: Unique identifier for each user
- `username`: User's username (must be unique)
- `email`: User's email address (must be unique)
- `password`: Hashed password (never stored in plain text)
- `created_at`: Timestamp of user registration

## Code Comments and Structure

### Database Connection (`app.py`)

```python
def get_db_connection():
    """Establishes a connection to the AWS RDS MySQL database."""
    # Database credentials from environment variables
    # Connection uses UTF-8 encoding
```

### Creating Database and Table

```python
def create_database():
    """Creates the database if it does not already exist."""
    # Runs on application startup
    # Safe to run multiple times

def create_users_table():
    """Creates the 'users' table if it does not already exist."""
    # Defines table schema with appropriate constraints
    # Ensures data integrity with UNIQUE constraints
```

### User Registration

```python
@app.route('/register', methods=['GET', 'POST'])
def register():
    """Handles user registration."""
    # Validates input (email format, password strength)
    # Hashes password before storing
    # Checks for duplicate usernames/emails
    # Inserts user into database
```

### User Login

```python
@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handles user login."""
    # Retrieves user from database
    # Verifies password hash
    # Creates session if credentials are correct
```

## Security Considerations

### Password Hashing

Passwords are hashed using `werkzeug.security.generate_password_hash()` before storing in the database. This ensures:
- Passwords are never stored in plain text
- Passwords cannot be recovered even if database is compromised
- Password verification uses `check_password_hash()`

### Environment Variables

All sensitive information is stored in the `.env` file:
- Database credentials are never hardcoded
- Environment variables are loaded using `python-dotenv`
- `.env` file is excluded from version control (see `.gitignore`)

### Session Management

- User sessions are encrypted using `app.secret_key`
- Session data is stored on the client side (signed cookies)
- Sessions are cleared on logout

### Input Validation

- Email format validation using regex
- Password strength requirements (minimum 6 characters)
- SQL injection prevention using parameterized queries
- HTML escaping in templates prevents XSS attacks

## Troubleshooting

### Database Connection Error

**Error**: `pymysql.err.OperationalError: (2003, "Can't connect to MySQL server")`

**Solutions**:
1. Verify RDS instance is running
2. Check security group allows port 3306
3. Verify database credentials in `.env` file
4. Ensure your IP is whitelisted in RDS security group
5. Test connection with MySQL client

### Module Not Found Error

**Error**: `ModuleNotFoundError: No module named 'flask'`

**Solution**: Make sure virtual environment is activated and dependencies are installed:
```bash
pip install -r requirements.txt
```

### Port Already in Use

**Error**: `Address already in use`

**Solution**: Change the port in `app.py` or kill the process using port 5000:

On Windows:
```bash
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

On macOS/Linux:
```bash
lsof -i :5000
kill -9 <PID>
```

### Email/Username Already Exists

**Error**: "Email or username already exists"

**Solution**: The email or username is already registered. Use a different email/username or log in if you already have an account.

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | RDS endpoint | `mydb.abc123.us-east-1.rds.amazonaws.com` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_NAME` | Database name | `loginapp` |
| `DB_USER` | Database username | `admin` |
| `DB_PASSWORD` | Database password | `MySecurePassword123!` |

## Development Tips

### Enable Debug Mode

The application runs with `debug=True` by default. This enables:
- Automatic code reloading on file changes
- Detailed error pages in the browser
- Python debugger access

**Important**: Disable debug mode in production by changing `debug=False`

### View Database Records

Connect to your RDS database and query the users table:

```bash
mysql -h your-rds-endpoint.rds.amazonaws.com -u admin -p loginapp
SELECT * FROM users;
```

### Test Password Hashing

Python provides utilities to test password hashing:

```python
from werkzeug.security import generate_password_hash, check_password_hash

# Hash a password
hashed = generate_password_hash("password123")

# Verify password
check_password_hash(hashed, "password123")  # Returns True
check_password_hash(hashed, "wrongpassword")  # Returns False
```

## Future Enhancements

- Add email verification for registration
- Implement "Forgot Password" functionality
- Add user profile management
- Implement role-based access control (RBAC)
- Add two-factor authentication (2FA)
- Implement activity logging
- Add rate limiting for login attempts
- Create API endpoints for mobile applications

## Dependencies

- **Flask** (3.0.0): Web framework
- **PyMySQL** (1.1.0): MySQL database driver
- **python-dotenv** (1.0.0): Environment variable management
- **Werkzeug** (3.0.1): Security utilities for password hashing

## License

This project is provided as-is for educational and development purposes.

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Verify all configuration steps are completed
3. Ensure AWS RDS instance is properly configured
4. Review Flask and PyMySQL documentation

---

**Last Updated**: 2026
**Python Version**: 3.7+
**Flask Version**: 3.0.0
