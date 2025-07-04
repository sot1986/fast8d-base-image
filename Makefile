.PHONY: auth build push build-web build-worker push-web

include .env

auth:
	@echo "authenticating in aws..."
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

build-web:
	@echo "building web image from ${BASE_WEB_IMAGE}..."
	docker build \
	--platform ${BUILD_PLATFORM} \
	-t ${ECR_WEB_IMAGE}:${ECR_WEB_IMAGE_TAG} \
	-f Dockerfile \
	--target web \
	.
	@echo "web image built successfully"

run-web:
	@echo "running web image..."
	docker run -d \
	--name fast8d-web \
	-p 80:80 \
	-p 443:443 \
	${ECR_WEB_IMAGE}:${ECR_WEB_IMAGE_TAG}

build-worker:
	@echo "building worker image from ${BASE_WORKER_IMAGE}..."
	docker build \
	--platform ${BUILD_PLATFORM} \
	-t ${ECR_WORKER_IMAGE}:${ECR_WORKER_IMAGE_TAG} \
	-f Dockerfile \
	--target worker \
	.
	@echo "worker image built successfully"

run-worker:
	@echo "running worker image..."
	docker run -d \
	--name fast8d-worker \
	${ECR_WORKER_IMAGE}:${ECR_WORKER_IMAGE_TAG}

build:
	@echo "building image..."
	make build-web
	make build-worker

push-web:
	@echo "tagging web image..."
	docker tag ${ECR_WEB_IMAGE}:${ECR_WEB_IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WEB_IMAGE}:${ECR_WEB_IMAGE_TAG}
	@echo "pushing web image..."
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WEB_IMAGE}:${ECR_WEB_IMAGE_TAG}
	@echo "web image built successfully"

push-worker:
	@echo "pushing worker image..."
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WORKER_IMAGE}:${ECR_WORKER_IMAGE_TAG}
	@echo "tagging worker image..."
	docker tag ${ECR_WORKER_IMAGE}:${ECR_WORKER_IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WORKER_IMAGE}:${ECR_WORKER_IMAGE_TAG}
	@echo "worker image built successfully"

push:
	@echo "pushing images..."
	make push-web
	make push-worker

enter-web:
	@echo "entering web container..."
	docker exec -it ${WEB_CONTAINER_NAME} /bin/bash

build-development:
	@echo "building development image from ${BASE_WEB_IMAGE}..."
	docker build \
	--platform ${BUILD_PLATFORM} \
	-t ${ECR_DEVELOPMENT_IMAGE}:${ECR_DEVELOPMENT_IMAGE_TAG} \
	-f Dockerfile \
	--target development \
	.
	@echo "development image built successfully"
