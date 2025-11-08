# SIMNATION API POC

A Django-based API proof of concept project with Docker containerization support. This project is set up for easy development and deployment using Docker and Docker Compose.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Docker Configuration](#docker-configuration)
- [Running the Application](#running-the-application)
- [Development Tools](#development-tools)
- [GitHub Actions & Docker Hub Setup](#github-actions--docker-hub-setup)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project is a Django REST API proof of concept that demonstrates:

- Dockerized Django application
- Development and production environment configurations
- Code quality tools (Flake8)
- CI/CD readiness with GitHub Actions and Docker Hub integration

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Git** (for version control)

### Verify Installation

```bash
docker --version
docker-compose --version
git --version
```

## 📁 Project Structure

```
simnation-api-poc/
├── app/                          # Django application directory
│   ├── app/                      # Main Django project package
│   │   ├── __init__.py
│   │   ├── settings.py          # Django settings
│   │   ├── urls.py              # URL configuration
│   │   ├── wsgi.py              # WSGI configuration
│   │   └── asgi.py              # ASGI configuration
│   ├── manage.py                # Django management script
│   ├── db.sqlite3               # SQLite database (generated)
│   └── .flake8                  # Flake8 configuration
├── Dockerfile                    # Docker image configuration
├── docker-compose.yml           # Docker Compose configuration
├── requirements.txt             # Production dependencies
├── requirements.dev.txt         # Development dependencies
├── .dockerignore               # Files to exclude from Docker build
├── .gitignore                  # Files to exclude from Git
└── README.md                   # This file
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd simnation-api-poc
```

### 2. Build and Run with Docker Compose

```bash
# Build and start the application
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

The application will be available at `http://127.0.0.1:8000`

### 3. Stop the Application

```bash
docker-compose down
```

## 🛠 Development Setup

### Initial Setup

1. **Build the Docker image** (includes development dependencies):

   ```bash
   docker-compose build
   ```

2. **Run database migrations** (if needed):

   ```bash
   docker-compose run --rm app python manage.py migrate
   ```

3. **Create a superuser** (for Django admin access):
   ```bash
   docker-compose run --rm app python manage.py createsuperuser
   ```

### Running Django Commands

All Django management commands should be run through Docker Compose:

```bash
# Run migrations
docker-compose run --rm app python manage.py migrate

# Create a new app
docker-compose run --rm app python manage.py startapp <app_name>

# Collect static files
docker-compose run --rm app python manage.py collectstatic

# Access Django shell
docker-compose run --rm app python manage.py shell

# Run tests
docker-compose run --rm app python manage.py test
```

### Development Mode

The `docker-compose.yml` is configured with:

- **Volume mounting**: Your local `./app` directory is mounted to `/app` in the container, so code changes are reflected immediately
- **Development dependencies**: Flake8 and other dev tools are installed when `DEV=true`
- **Hot reload**: Django's development server automatically reloads on code changes

## 🐳 Docker Configuration

### Dockerfile

The Dockerfile is configured with:

- **Base Image**: Python 3.9 on Alpine Linux (lightweight)
- **Virtual Environment**: Isolated Python environment at `/py`
- **Security**: Runs as non-root user (`django-user`)
- **Build Arguments**: `DEV` argument to control development dependencies
- **Port**: Exposes port 8000

Key features:

- Python output is unbuffered for immediate log visibility
- Virtual environment for package isolation
- Non-root user for enhanced security
- Multi-stage optimization for smaller image size

### Docker Compose

The `docker-compose.yml` file defines:

- **Service**: `app` - The Django application
- **Build**: Builds from Dockerfile with `DEV=true` argument
- **Ports**: Maps port 8000 from container to host
- **Volumes**: Mounts local `./app` directory for live code updates
- **Command**: Runs Django development server

### Building Docker Images

#### Development Build (with dev dependencies):

```bash
docker-compose build
# or explicitly
docker build --build-arg DEV=true -t simnation-api-poc .
```

#### Production Build (without dev dependencies):

```bash
docker build -t simnation-api-poc .
```

## ▶️ Running the Application

### Start the Server

```bash
# Start in foreground (see logs)
docker-compose up

# Start in background
docker-compose up -d

# Start and rebuild
docker-compose up --build
```

### View Logs

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs app
```

### Stop the Server

```bash
# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes
docker-compose down -v
```

### Access the Application

- **API**: http://127.0.0.1:8000
- **Admin Panel**: http://127.0.0.1:8000/admin (requires superuser)

## 🔧 Development Tools

### Flake8 (Code Linting)

Flake8 is configured for code quality checks. Configuration is in `app/.flake8`.

**Run Flake8**:

```bash
docker-compose run --rm app flake8 .
```

**Flake8 Configuration**:

- Excludes: `migrations`, `__pycache__`, `manage.py`, `settings.py`

### Adding Dependencies

**Production Dependencies** (add to `requirements.txt`):

```txt
Django>=4.2.0,<5.0.0
djangorestframework>=3.14.0
```

**Development Dependencies** (add to `requirements.dev.txt`):

```txt
flake8>=3.9.2,<3.10
pytest>=7.0.0
```

After adding dependencies, rebuild the Docker image:

```bash
docker-compose build
```

## 🔐 GitHub Actions & Docker Hub Setup

### Docker Hub Credentials Setup

To enable GitHub Actions to push images to Docker Hub:

1. **Create Docker Hub Account** (if you don't have one):

   - Go to https://hub.docker.com
   - Create an account

2. **Configure GitHub Secrets**:
   - Go to your GitHub repository
   - Navigate to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Add the following secrets:
     - `DOCKER_HUB_USERNAME`: Your Docker Hub username
     - `DOCKER_HUB_TOKEN`: Your Docker Hub access token
       - Generate token: Docker Hub → Account Settings → Security → New Access Token

### GitHub Actions Workflow (Example)

Create `.github/workflows/docker-publish.yml`:

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKER_HUB_USERNAME }}/simnation-api-poc:latest
```

## 🐛 Troubleshooting

### Issue: `django-admin: not found`

**Solution**: Ensure Django is in `requirements.txt` and rebuild:

```bash
docker-compose build
```

### Issue: Port 8000 already in use

**Solution**: Change the port in `docker-compose.yml`:

```yaml
ports:
  - "8001:8000" # Use port 8001 on host
```

### Issue: Permission denied errors

**Solution**: The container runs as non-root user. If you need to create files, ensure proper permissions:

```bash
sudo chown -R $USER:$USER ./app
```

### Issue: Changes not reflecting

**Solution**:

1. Ensure volume mounting is working: Check `docker-compose.yml` volumes section
2. Restart the container: `docker-compose restart`
3. Check if file is in `.dockerignore`

### Issue: Database errors

**Solution**: Run migrations:

```bash
docker-compose run --rm app python manage.py migrate
```

### View Container Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs app

# Follow logs
docker-compose logs -f app
```

### Access Container Shell

```bash
# Access running container
docker-compose exec app sh

# Or run new container
docker-compose run --rm app sh
```

## 📝 Environment Variables

To use environment variables, create a `.env` file in the project root:

```env
DEBUG=True
SECRET_KEY=your-secret-key-here
DATABASE_URL=sqlite:///db.sqlite3
```

Update `docker-compose.yml` to load environment variables:

```yaml
services:
  app:
    env_file:
      - .env
```

## 🙏 Acknowledgments

- Adam Velma
- Rahul Umrao
