echo "[default]" > inventory.ini
public_domains=`aws ec2 describe-instances --filters 'Name=tag:type,Values='"$1 $2"'' | grep -o "[ec0-9\-]*.us-west-2.compute.amazonaws.com" | uniq`
if [ -n "$public_domains" ]; then
  for domain in $public_domains
  do
    echo -e "$domain\tansible_user=deployer\tansible_ssh_private_key_file=key" >> inventory.ini
  done
else
    echo "Something went wrong, no instances found :("
    exit 1
fi
