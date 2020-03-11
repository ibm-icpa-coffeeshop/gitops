export PASSWORD=""

# Create a private key
openssl genrsa -out tekton/dashboard/tekton-key.pem -passout pass:${PASSWORD} 2048
# Generate the root CA
openssl req -x509 -new -key tekton/dashboard/tekton-key.pem -out tekton/dashboard/tekton-cert.pem -passin pass:${PASSWORD} -subj //CN=root
# Extract public key
openssl rsa -in tekton/dashboard/tekton-key.pem -out tekton/dashboard/tekton-key.pem -passin pass:${PASSWORD}
