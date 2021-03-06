echo "[default]" > inventory.ini
public_domain=`aws ec2 describe-instances --filters 'Name=tag:Name,Values='"$1 $2"'' | grep -m 1 -o "[ec0-9\-]*.us-west-2.compute.amazonaws.com"`
echo -e "$public_domain\tansible_user=deployer\tansible_ssh_private_key_file=key" >> inventory.ini
