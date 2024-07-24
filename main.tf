name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up JDK 11
      uses: actions/setup-java@v2
      with:
        distribution: 'temurin'
        java-version: '11'

    - name: Build with Maven
      run: mvn clean package -DskipTests
      working-directory: ./SampleWebApp

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v2
      with:
        context: .
        file: ./Dockerfile
        push: true
        tags: olatunjym/sample-web-app:latest

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      with:
        version: 'latest'
        project_id: ${{ secrets.GCP_PROJECT_ID }}

    - name: Authenticate to Google Cloud
      run: gcloud auth activate-service-account --key-file=${{ secrets.GCP_SA_KEY }}

    - name: Configure kubectl
      run: gcloud container clusters get-credentials tg1 --zone us-central1-a --project ${{ secrets.GCP_PROJECT_ID }}

    - name: Deploy using gcloud
      run: |
        gcloud container images list-tags gcr.io/${{ secrets.GCP_PROJECT_ID }}/sample-web-app
        gcloud container images add-tag gcr.io/${{ secrets.GCP_PROJECT_ID }}/sample-web-app:latest gcr.io/${{ secrets.GCP_PROJECT_ID }}/sample-web-app:$GITHUB_SHA
        gcloud beta run deploy sample-web-app --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/sample-web-app:$GITHUB_SHA --region us-central1 --platform managed --allow-unauthenticated
