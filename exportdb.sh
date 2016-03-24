echo "dumping databases before shutting down..."

for db in `ls /var/www/dumps`
do
  if [ "$db" != "readme.md" ]
  then
    echo "dumping database for $db"
    IFS='.' read -a mydb <<< "$db"
    mysqldump --add-drop-database -u root -proot ${mydb[0]} > /var/www/dumps/$db
    echo "...done"
  fi
done