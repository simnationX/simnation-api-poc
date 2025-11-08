# Base image: Uses Python 3.9 on Alpine Linux 3.13
# Alpine is a lightweight Linux distribution that results in smaller Docker images
FROM python:3.9-alpine3.13

# Set environment variable to disable Python output buffering
# This ensures that Python output (like print statements) are immediately visible in Docker logs
# Without this, Python buffers output which can make debugging difficult in containerized environments
ENV PYTHONUNBUFFERED=1

# Copy the requirements.txt file from the host machine to /tmp/requirements.txt in the container
# This file contains all Python package dependencies needed for the application
COPY ./requirements.txt /tmp/requirements.txt

# Copy the requirements.dev.txt file from the host machine to /tmp/requirements.dev.txt in the container
# This file contains development-only dependencies (e.g., testing tools, linters, debuggers)
# These will only be installed if the DEV build argument is set to "true"
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the entire ./app directory from the host to /app in the container
# This includes all application code, modules, and files needed to run the application
COPY ./app /app

# Set the working directory to /app
# All subsequent commands will be executed from this directory
# This is where the application code lives and where commands will run
WORKDIR /app

# Expose port 8000 to the host machine
# This tells Docker that the container will listen on port 8000
# Note: This doesn't actually publish the port - you still need -p flag when running the container
EXPOSE 8000

# Build argument to control whether development dependencies should be installed
# Set to "true" when building for development: docker build --build-arg DEV=true
# Defaults to "false" for production builds
ARG DEV=false

# Multi-line RUN command that executes several operations in a single layer:
# 1. Create a Python virtual environment at /py
#    This isolates the application's Python packages from the system Python
# 2. Upgrade pip to the latest version for better package management
# 3. Install all Python packages listed in requirements.txt into the virtual environment
#    Note: If requirements.txt is empty or contains only comments, pip will succeed without installing anything
# 4. Conditionally install development dependencies if DEV build argument is set to "true"
#    Development dependencies are installed from /tmp/requirements.dev.txt
# 5. Remove the /tmp directory to clean up temporary files and reduce image size
# 6. Create a new user named 'django-user' with:
#    --disabled-password: User cannot log in with a password
#    --no-create-home: Don't create a home directory for this user
#    This follows security best practices by not running as root user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Add the virtual environment's bin directory to the system PATH
# This allows Python and pip commands to be executed directly without specifying the full path
# Any command like 'python' or 'pip' will now use the versions from the virtual environment
ENV PATH="/py/bin:$PATH"

# Switch to the non-root user 'django-user' for security
# All subsequent commands and the application will run as this user instead of root
# This minimizes the risk if the container is compromised
USER django-user
