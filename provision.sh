set -e
set -x

# Generate locales
locale-gen en_GB.UTF-8

# Install debs:
cd /vagrant
sh ./apt-postgres.sh
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >> /etc/apt/sources.list.d/mongodb.list

# Update:
apt-get update
apt-get upgrade -y

# Install postgresql
apt-get install -y postgresql-9.4 postgresql-server-dev-9.4

# Setup Postgres Bits:
sudo -u postgres psql -f setup.sql
echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "hostssl hindquarters hindquarters all md5" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "hostssl hindquarters_test hindquarters_test all md5" >> /etc/postgresql/9.4/main/pg_hba.conf

# Install mongo:
apt-get install -y mongodb-org

# Configure mongo:
vim -E -s /etc/mongod.conf <<-EOF
  :%substitute/bind_ip = 127.0.0.1/# bind_ip = 127.0.0.1/g
  :update
  :quit
EOF

# Restart services:
service postgresql restart
service mongod restart
