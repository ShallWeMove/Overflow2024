#!/bin/sh

# Set the domain for the certificate
DOMAIN=localhost

# Check if SSL certificates already exist
if [ ! -f ./nginx/${DOMAIN}.key ] || [ ! -f ./nginx/${DOMAIN}.crt ]; then
  echo "Generating SSL certificates for ${DOMAIN}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./nginx/${DOMAIN}.key \
    -out ./nginx/${DOMAIN}.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=${DOMAIN}"
  echo "SSL certificates generated:"
  echo "Key: ./nginx/${DOMAIN}.key"
  echo "Certificate: ./nginx/${DOMAIN}.crt"
else
  echo "SSL certificates already exist:"
  echo "Key: ./nginx/${DOMAIN}.key"
  echo "Certificate: ./nginx/${DOMAIN}.crt"
fi
