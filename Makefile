BUILDDIR := build
FILES := src/html kube/thebest-aio.yaml Dockerfile

REPLICAS ?= 1
ENV ?= dev

TAG := $(shell git describe --tags --always)
NAMESPACE := thebest-${TAG}-${ENV}

.PHONY: clean

build:
	mkdir -p ${BUILDDIR}
	cp -R ${FILES} ${BUILDDIR}/

docker: build
	gcloud container builds submit ${BUILDDIR} --tag=us.gcr.io/${PROJECT}/thebest:${TAG} --quiet

deploy: build
	sed -i -e "s/\%IMAGE/us.gcr.io\/${PROJECT}\/thebest:${TAG}/g" ${BUILDDIR}/thebest-aio.yaml
	sed -i -e "s/\%NAMESPACE/${NAMESPACE}/g" ${BUILDDIR}/thebest-aio.yaml
	kubectl --namespace ${NAMESPACE} create -f ${BUILDDIR}/thebest-aio.yaml

scale: deploy
	kubectl scale --replicas=${REPLICAS} rc/thebest

clean:
	rm -rf ${BUILDDIR}
