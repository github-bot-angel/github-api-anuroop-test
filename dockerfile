name: PR Flow

on:
  pull_request:
    branches: 
      - master
      - hotfix-*

jobs:
  pr-checks:
    name: PR Build
    runs-on: aws-ec2
    steps:
      - name: Clean the workspace
        uses: docker://alpine:3
        with:
          args: /bin/sh -c "rm -rf /github/workspace/.* || rm -rf /github/workspace/*"
      - name: Checkout
        uses: actions/checkout@v3.1.0
        with:
          fetch-depth: 0

      - name: Checkout
        uses: actions/checkout@v3.1.0
        with:
          repository: 'angel-one/build-ecs-action'
          ref: '2.5.0'
          token: ${{ secrets.SRE_GIT_READ_TOKEN }}
          path: ./.github/workflows/  
          clean: 'false'
      
      - name: Copy custom action
        shell: bash
        run: |
          cp ./.github/workflows/pr-flow/action.yml ./.github/workflows/ 
        
      - name: Run Custom Build action
        uses: ./.github/workflows # Uses an action in the directory
        id: image
        with:
          MAJOR_VERSION: 0
          RUN_CODE_UNIT_TEST: 0 #Use flag 1 to enable and 0 to disable
          REGISTRY: ghcr.io
          IMAGE_NAME: ${{ github.event.repository.name }}
          ECR_REGISTRY: 732165046977.dkr.ecr.ap-south-1.amazonaws.com
          ECR_REPO_NAME: ${{ github.event.repository.name }}
          NEXUS_REGISTRY: docker.prod.angelcloud.in
          NEXUS_REPO_NAME: ${{ github.event.repository.name }}
          SERVICE_PORT: 8080
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SRE_NEXUS_USERNAME: ${{ secrets.SRE_NEXUS_USERNAME }}
          SRE_NEXUS_PASSWORD: ${{ secrets.SRE_NEXUS_PASSWORD }}
          AWS_ACCESS_KEY_ID: ${{ secrets.SRE_ECR_AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.SRE_ECR_AWS_SECRET_ACCESS_KEY }}
          RELEASE_TOKEN: ${{ secrets.SRE_GIT_READ_TOKEN }} #Personal access token to create releases
          CONTAINER_SCAN: 'false'
              
      - run: |
          echo "ECR Image URI for CD ${{ steps.image.outputs.ecr_uri }} "
          echo "Nexus Image URI for CD ${{ steps.image.outputs.nexus_uri }} "
        shell: bash
