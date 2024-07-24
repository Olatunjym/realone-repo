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

    - name: Install Google Cloud SDK
      run: |
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update && sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin kubectl

    - name: Authenticate to Google Cloud
      run: gcloud auth activate-service-account --key-file=${{ secrets.GCP_SA_KEY }}

    - name: Configure kubectl
      run: gcloud container clusters get-credentials tg1 --zone us-central1-a --project ${{ secrets.GCP_PROJECT_ID }}

    - name: Deploy to GKE
      run: |
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml