DEPLOY_USER = root
DEPLOY_HOST = deneb

.PHONY: build deploy serve clean

build:
	hugo -D

serve:
	hugo server

deploy: 
	hugo
	rsync -rpt --delete public/ ${DEPLOY_USER}@${DEPLOY_HOST}:/var/www/deltaepsilon.ca/

clean:
	rm -r public
