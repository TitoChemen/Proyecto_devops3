# Etapa de construcción
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa de producción con Nginx
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Copia una configuración básica de nginx si es necesario para SPA
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]