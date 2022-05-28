FROM node:latest
WORKDIR /hexo
ENV OUTPUT_PORT 4000
EXPOSE ${OUTPUT_PORT}
RUN	npm install -g npm@latest &&\
	npm install -g hexo-cli
COPY . .
RUN npm install --force
CMD hexo server -d -p ${OUTPUT_PORT}
