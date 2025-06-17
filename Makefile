.PHONY: auth build push build-web build-worker push-web

include .env

auth:
	@echo "authenticating in aws..."
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

build-web:
	@echo "building web image from ${BASE_WEB_IMAGE}..."
	docker build \
	--platform ${BUILD_PLATFORM} \
	-t ${ECR_WEB_IMAGE} \
	--build-arg BASE_IMAGE=${BASE_WEB_IMAGE} \
	-f Dockerfile \
	--target web \
	.
	@echo "web image built successfully"

build-worker:
	@echo "building worker image from ${BASE_WORKER_IMAGE}..."
	docker build \
	--platform ${BUILD_PLATFORM} \
	-t ${ECR_WORKER_IMAGE} \
	--build-arg BASE_IMAGE=${BASE_WORKER_IMAGE} \
	-f Dockerfile \
	--target worker \
	.
	@echo "worker image built successfully"

build:
	@echo "building image..."
	make build-web
	make build-worker

push-web:
	@echo "tagging web image..."
	docker tag ${ECR_WEB_IMAGE} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WEB_IMAGE}
	@echo "pushing web image..."
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WEB_IMAGE}
	@echo "web image built successfully"
	docker images | grep ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WEB_IMAGE}

push-worker:
	@echo "pushing worker image..."
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WORKER_IMAGE}
	@echo "tagging worker image..."
	docker tag ${ECR_WORKER_IMAGE} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WORKER_IMAGE}
	@echo "worker image built successfully"
	docker images | grep ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_WORKER_IMAGE}

push:
	@echo "pushing images..."
	make push-web
	make push-worker
