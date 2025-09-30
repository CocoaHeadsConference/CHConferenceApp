# backend

💧 A project built with the Vapor web framework.

## Getting Started

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

## Deployment

**Note**: The production backend is hosted and managed by CocoaHeads Brasil on AWS infrastructure. Deployments are controlled by the CocoaHeads team and are triggered automatically upon merging to the main branch.

### For CocoaHeads Team Members

Deployment can be triggered manually via GitHub Actions or directly on the server.

#### Triggering a Deployment

1. Navigate to **Actions → Deploy Backend → Run workflow**

The deployment script will automatically:
1. Pull latest changes from GitHub
2. Stop existing Docker containers
3. Rebuild Docker images
4. Start containers with the new version

**Note**: Deployments cause brief downtime during rebuild.

#### Server Configuration

The production server requires these GitHub Secrets to be configured:
- `AWS_HOST`: AWS server hostname or IP address
- `AWS_USERNAME`: SSH username
- `AWS_SSH_KEY`: Private SSH key for server access
- `AWS_PORT`: SSH port (optional, defaults to 22)
- `REPO_PATH`: Repository path on server (optional, defaults to `/home/ubuntu/CHConferenceApp`)

### For Contributors

If you're contributing to the backend, simply create a pull request. Once approved and merged to the main branch, the CocoaHeads team will handle deployment to production. You can test your changes locally using Docker Compose:

```bash
cd backend
docker compose up --build
```

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)
