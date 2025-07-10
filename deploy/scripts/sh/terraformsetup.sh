# Script that builds terraform configurations for Cloud Run.
# - Copies /terraform/cloudrun/ to corresponding new branch directory for setting up autodeployment
# - Generates variables.tf depending on the envs specified.
# - Generates .tfvars for automatic embedding of cloud build environment variables.

branch=$1
templatedir='./deploy/terraform/cloudrun'
newdir='./deploy/terraform/'$branch
basefile='./deploy/terraform/tfvars.yaml'
terraformyaml='./deploy/terraform/templatecloudbuild.yaml'
buildfile='./deploy/'$branch'cloudbuild.yaml'
SPACE='        '

# Creates new directory if not given.
if [ -d "$newdir" ]
then
    rm -rf "$newdir"
fi
mkdir "$newdir"
# Copies base terraform files to new directory for given branch.
cp $templatedir/* $newdir

# Checks and builds cloudbuild.yaml using template and environment variables (substitutions)
if [ -f "$buildfile" ]
then
    rm "$buildfile"
fi
cp "$basefile" "$buildfile"

# Creates tfvars from environment variables specified in .envs
if [ -f ".env" ]
then
    while IFS="=" read -r key value
    do
        echo $key=\"\" >> "$newdir/terraform.tfvars"
        echo "${SPACE}- '$key=\$_$key'" >> "$buildfile"
    done < ".env"
fi
echo >> $buildfile

cat "$terraformyaml" >> "$buildfile"
