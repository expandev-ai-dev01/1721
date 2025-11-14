# LoveCakes Backend

Backend API for LoveCakes - Cake ordering and sales platform

## Project Structure

```
src/
├── api/                    # API Controllers
│   └── v1/                 # API Version 1
│       ├── external/       # Public endpoints
│       └── internal/       # Authenticated endpoints
├── routes/                 # Route definitions
│   └── v1/                 # Version 1 routes
├── middleware/             # Express middleware
│   └── crud/               # CRUD controller utilities
├── services/               # Business logic services
├── utils/                  # Utility functions
│   ├── database/           # Database utilities
│   └── zodValidation/      # Validation schemas
├── constants/              # Application constants
├── instances/              # Service instances
├── tests/                  # Global test utilities
├── config/                 # Configuration management
└── server.ts               # Application entry point
```

## Getting Started

### Prerequisites

- Node.js 18+
- SQL Server
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Configure database credentials in .env
```

### Development

```bash
# Run development server
npm run dev

# Run tests
npm test

# Run linter
npm run lint
```

### Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

## API Documentation

### Base URL

- Development: `http://localhost:3000/api/v1`
- Production: `https://api.lovecakes.com/api/v1`

### Endpoints

#### Health Check

```
GET /health
```

Returns server health status.

## Environment Variables

See `.env.example` for required environment variables.

## Database

Database migrations and stored procedures are located in the `database/` directory at the project root.

## Testing

Tests are colocated with source files using `.test.ts` suffix.

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch
```

## Contributing

Follow the established patterns in the codebase:

- Use TypeScript strict mode
- Follow ESLint rules
- Write tests for new features
- Document code with TSDoc comments
- Use path aliases (@/) for imports

## License

ISC