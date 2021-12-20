echo "[default]" > inventory.ini
public_domains=`aws ec2 describe-instances --filters 'Name=tag:Name,Values='"$1 $2"'' | grep -o "[ec0-9\-]*.us-west-2.compute.amazonaws.com" | uniq`
if [ ${#pubic_domains[@]} -eq 0 ]; then
    echo "Something went wrong, no instances found :("
    exit 1
fi
for domain in $public_domains
do
  echo -e "$domain\tansible_user=deployer\tansible_ssh_private_key_file=key" >> inventory.ini
done
