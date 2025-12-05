Jeniks setup on EC2 AWS: https://www.jenkins.io/doc/book/installing/linux/

    apt update && apt install openjdk-21-jdk -y
    apt update && apt install openjdk-17-jdk -y
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
    sudo apt install jenkins -y
    apt install unzip zip -y 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install



    Jenkins -> Tools -> Maven
    Jenkins -> Tools -> JDK installationa path: /usr/lib/jvm/java-XX-openjdk-amd64

    Plugins: 
        S3 publisher
        Build Timestamp
        Pipeline Maven Integration
        Pipeline Utility Steps
        Amazon Web Services SDK::ALL  -> for aws credentials
        Pipeline: AWS Steps
        --------
        Amazon ECR 
        Docker pipeline
        CloudBees Docker Build and Publish
        Nexus Artifact Uploader
        SonarQube Scanner
        Sonar Quality Gates

    Access to repo:
        sudo su - jenkins
        ssh-keygen -t ed25519 -C "jenkins-ec2" -f ~/.ssh/github_jenkins
        ssh-keyscan github.com >> ~/.ssh/known_hosts
        cat ~/.ssh/github_jenkins.pub
        GitHub -> settings -> ssh -> add ssh key -> paste
        cat ~/.ssh/github_jenkins
        Manage Jenkins -> Credentials -> System -> Global Credential -> Add credential -> Kind -> SSH Username with ...
        
    For deploy to s3:
        IAM user with rights
        Install on host AWS CLI (sudo snap install aws-cli --classic)
        Manage Jenkins -> Credentials -> System -> Global Credential -> Add credential -> Kind -> AWS Credendials 


