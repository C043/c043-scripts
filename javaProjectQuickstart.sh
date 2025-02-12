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
  -DgroupId="$username" \
  -DartifactId="$projectName" \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
