echo "[RAID INIT] Starting"

# Partitions
# sudo parted -a optimal /dev/sdb
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary 1MiB 100MiB --script
sudo parted /dev/sdb mkpart primary 101MiB 200MiB --script
sudo parted /dev/sdb mkpart primary 201MiB 300MiB --script
sudo parted /dev/sdb mkpart primary 301MiB 400MiB --script
sudo parted /dev/sdb mkpart primary 401MiB 500MiB --script
sudo parted /dev/sdb mkpart primary 501MiB 600MiB --script
sudo parted /dev/sdb mkpart primary 601MiB 700MiB --script

# Installing mdadm
sudo yum install mdadm -y

# Creating RAID-1
printf "y\n" | sudo mdadm --create /dev/md0 -l 1 -n 7 /dev/sdb{1,2,3,4,5,6} /dev/sdc

# Failing one RAID element
sudo mdadm /dev/md0 --fail /dev/sdb3

# Adding new element to RAID array
sudo mdadm /dev/md0 --add /dev/sdb7

# Failing new element
sudo mdadm /dev/md0 --fail /dev/sdb7

# Re-adding old failed element
sudo mdadm /dev/md0 --re-add /dev/sdb3

echo "[RAID INIT] Initialized"
