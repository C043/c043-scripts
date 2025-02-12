#!/bin/zsh

# Prompt for username (groupId)
while [[ -z "$username" ]]; do
  echo "What is your name?"
  read -r username
done

# Prompt for project name (artifactId)
while [[ -z "$projectName" ]]; do
  echo "Choose a name for your project"
  read -r projectName
done

mvn archetype:generate \
  -DgroupId="com.$username" \
  -DartifactId="$projectName" \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false

# Navigate into the generated project directory
cd "$projectName" || exit

# Create .gitignore file with desired content
cat > .gitignore <<EOF
# Ignore target directory (compiled Java files)
target/

# Ignore IDE-related files
.idea/
*.iml
*.ipr
*.iws

# Ignore Maven output files
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
release.properties
dependency-reduced-pom.xml
buildNumber.properties

# Compiled class file
*.class

# Log file
/logs
*.log

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files #
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# virtual machine crash logs, see http://www.java.com/en/download/help/error_hotspot.xml
hs_err_pid*
replay_pid*
EOF

echo ".gitignore file has been created successfully!"
