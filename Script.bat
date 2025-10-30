aws --version
aws configure
aws cloudformation create-stack --stack-name EliminaSoloEste --template-body file://acoplada.yaml
aws cloudformation create-stack --stack-name EliminaSoloEste --template-body file://desacoplada.yaml  

//solo ponemos --capabilities para roles o politicas IAM M