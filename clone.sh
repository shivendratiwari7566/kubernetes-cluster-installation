#!/bin/bashi
workdir()
{
"cd" vizsense
sudo docker-compose build
kubectl apply -f deployment
kubectl apply -f deployment/keda
kubectl apply -f deployment/services
}
read -p "Please enter the branch name or Hit Enter to continue with default branch " branch

if [ $branch == ""]
then 
  echo "clonning default branch........."
  git clone https://shivendratiwari10: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@github.com/GathiAnalytics/vizsense.git
  echo "cloned successfully............Enjoy"
  workdir
else 
  echo "cloning branch $branch"
  git clone https://shivendratiwari10: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@github.com/GathiAnalytics/vizsense.git --branch $branch
  echo "successfully cloned branch $branch"
  workdir

fi
echo "Printing working dir"

pwd
