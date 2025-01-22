# Kubernetes Application Project

## Overview
This project demonstrates a multi-tier application deployment in Kubernetes using Terraform for infrastructure management. The application consists of a React frontend, FastAPI backend, and Redis database, all containerized and orchestrated in a Kubernetes environment.

## Prerequisites
- Docker
- Kubernetes (Minikube or similar)
- Terraform
- kubectl
- Node.js (for local development)
- Python 3.9+

## Project Structure
```
└── butterski-terraform-train/
    ├── k8s/               # Terraform and Kubernetes configurations
    ├── nowatorski_backend/# Python FastAPI backend
    └── nowatorski_front/  # React frontend
```

## Components
### Frontend
- React.js application
- Displays visit statistics
- Auto-refreshing data every 5 seconds
- Multi-stage Docker build with Nginx

### Backend
- FastAPI (Python)
- RESTful API endpoints
- Redis integration
- Multi-stage Docker build

### Database
- Redis StatefulSet
- Persistent storage
- Password protection

## API Endpoints
- `GET /api` - API health check
- `GET /api/health` - System health status
- `GET /api/version` - Application version
- `GET /api/grade` - Application grade
- `GET /api/count/{url}` - URL visit counter
- `GET /api/stats` - All visit statistics

## Deployment

### 1. Start Minikube
```bash
minikube start
```

### 2. Initialize Terraform
```bash
cd k8s
terraform init
```

### 3. Deploy the Application
```bash
terraform apply
```

### 4. Access the Application
```bash
minikube tunnel
```
Access the application at `http://localhost`

## Configuration
The application can be configured through:
- Kubernetes ConfigMaps
- Kubernetes Secrets
- Environment variables

## Development

### Backend Development
```bash
cd nowatorski_backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend Development
```bash
cd nowatorski_front
npm install
npm start
```

## Features
- Multi-stage Docker builds
- Kubernetes namespace isolation
- Automatic cleanup jobs
- Resource management
- Service communication
- Persistent storage
- Health monitoring

## Cleanup
To remove all resources:
```bash
terraform destroy
```

## Architecture
```
Frontend (React) -> Ingress -> Backend (FastAPI) -> Redis
```

## Security
- Namespace isolation
- Secret management
- Resource limitations
- Internal service communication

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
[MIT License](LICENSE)

## Author
Miłosz Kucharski

## Acknowledgments
- FastAPI
- React
- Terraform
- Kubernetes
- Redis

For more detailed information about specific components, please refer to the documentation in respective directories.