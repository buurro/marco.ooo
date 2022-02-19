FROM klakegg/hugo:0.92.1-ext-onbuild AS hugo
ENV HUGO_ENV_ARG=production

FROM nginx
COPY --from=hugo /target /usr/share/nginx/html
