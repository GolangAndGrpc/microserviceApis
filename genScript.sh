#!/bin/bash

SERVICE_NAME=$1
RELEASE_VERSION=$2d
USER_NAME=$3
EMAIL=$4

git config user.name "$USER_NAME"
git config user.email "$EMAIL"
git fetch --all

# Get protobuf-compiler and grpc dependencies
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
echo "Compiler and dependency istalled successfully ...."

ls -al $(go env GOPATH)/bin
export PATH="$PATH:$(go env GOPATH)/bin"
echo "$PATH:$(go env GOPATH)/bin" >> $GITHUB_PATH

rm -rf golang
mkdir golang
cd golang || exit
mkdir "${SERVICE_NAME}"
cd ..

#Generate proto code command
protoc --go_out=./golang \
  --go_opt=paths=source_relative \
  --go-grpc_out=./golang \
  --go-grpc_opt=paths=source_relative \
  protos/${SERVICE_NAME}/*.proto

cd golang/order/
ls -lrt

# Create sub package inside repo
cd golang/${SERVICE_NAME} || exit
go mod init github.com/GolangAndGrpc/microserviceApis/${SERVICE_NAME} || true
echo "Service name ${SERVICE_NAME}"
go mod tidy
cd ../../

