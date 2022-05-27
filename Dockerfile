FROM node:latest
WORKDIR /hexo
RUN	npm install -g npm@latest &&\
	npm install -g hexo-cli
COPY * /hexo/
RUN rm -rf node_modules &&\
	npm install --force
EXPOSE 4000
CMD hexo server -d -p 4000
