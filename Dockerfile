# Stage 1: Build
FROM node:20-alpine AS build

# Install git (required by npm install for husky/lint-staged)
RUN apk add --no-cache git

WORKDIR /app

# Copy dependency files
COPY package.json yarn.lock* package-lock.json* ./

# Install dependencies (skip husky git hooks in CI)
RUN npm install --ignore-scripts

# Copy source code
COPY . .

# Build for production
RUN npm run build:prod

# Stage 2: Serve with nginx
FROM nginx:stable-alpine

# Copy built files to nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
