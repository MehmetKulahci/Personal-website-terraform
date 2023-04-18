#! /bin/bash
yum update -y
yum install git -y
amazon-linux-extras install nginx1 -y
systemctl start nginx
cd /usr/share/nginx/html
chmod -R 777 /usr/share/nginx/html
rm index.html
git clone https://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@github.com/MehmetKulahci/personal-website.git
cd personal-website
cp -r /usr/share/nginx/html/personal-website/* /usr/share/nginx/html
systemctl restart nginx
systemctl enable nginx