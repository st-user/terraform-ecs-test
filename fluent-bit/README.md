# fluent-bit container for testing


```bash
ACCOUNT_ID=....
REGION=ap-northeast-1
ECR_IMAGE_TAG=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/fluentbit-dev-my-firelens:latest

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker build --platform linux/amd64 -t fluentbit-dev-my-firelens .

docker tag fluentbit-dev-my-firelens:latest ${ECR_IMAGE_TAG}

docker push ${ECR_IMAGE_TAG}
```
