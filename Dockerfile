FROM ascotbe/medusa:latest
MAINTAINER ascotbe
RUN apt clean
RUN apt update
RUN apt install git -y
RUN apt install nodejs -y
RUN apt install npm -y
RUN apt install nginx -y
RUN apt install redis -y
RUN apt install python3 -y
RUN apt install python3-pip -y
RUN apt install mingw-w64 -y
RUN apt install golang-go -y
RUN apt install nim -y
RUN sed -i "s/I_will_always_like_AyanamiRei/redis_passwd123/g" /etc/redis/redis.conf
ADD ./Medusa.tat.gz /Medusa
#COPY ./*  ./Medusa/
RUN sed -i "s/medusa.ascotbe.com/this_is_you_domain_name/g" /etc/nginx/sites-enabled/default
WORKDIR /Medusa/Vue/
RUN rm -rf package-lock.json
RUN npm -v
RUN npm install highcharts --save  --registry=http://registry.cnpmjs.org
#RUN npm install
RUN npm run build
RUN mv dist/ /var/www/html/
WORKDIR /Medusa
RUN mv ssl.pem /etc/nginx/cert/
RUN mv ssl.key /etc/nginx/cert/
RUN python3 -m pip install -r Medusa.txt
RUN nohup redis-server /etc/redis/redis.conf &
RUN nohup python3 DomainNameSystemServer.py &
RUN nohup celery -A Web worker --loglevel=info --pool=solo &
RUN systemctl restart nginx
CMD python3 manage.py runserver 0.0.0.0:9999 --insecure --noreload