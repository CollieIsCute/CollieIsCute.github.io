FROM node:latest
WORKDIR /hexo
EXPOSE 4000
RUN	npm install -g npm@latest &&\
	npm install -g hexo-cli
COPY . .
RUN npm install --force
CMD hexo server -d -p 4000
