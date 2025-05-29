.PHONY: auth build push

include .env

auth:
	@echo "authenticating in aws..."
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

build:
	@echo "building image..."
	docker build -t ${IMAGE} --build-arg PHP_VERSION=${PHP_VERSION} .
	@echo "tagging image..."
	docker tag ${IMAGE}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE}:${IMAGE_TAG}
	@echo "image built successfully"
	docker images | grep ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE}

push:
	@echo "pushing image..."
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE}:${IMAGE_TAG}

