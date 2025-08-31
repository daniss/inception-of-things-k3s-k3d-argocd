echo "[INFO] Adding project to GitLab..."

response=$(curl --write-out "%{http_code}" --silent --output /dev/null http://127.0.0.1:8181/root/new-project)
if [ $response -eq 200 ]; then
    echo "[WARNING] 'new-project' repo is already present. Skipping..." 
    exit 1
fi

git clone https://github.com/daniss/dcindrak.git
mkdir new-project
mv dcindrak/* new-project/
cd new-project
git init
git remote add origin http://127.0.0.1:8181/root/new-project.git
git add .
git config user.name "root"
git config user.email "root"
git commit -m "Initial commit"
git push -u origin master
rm -rf ../dcindrak

echo "[INFO] Project added successfully."
echo "[TODO] put the repo in public mode, if not already"