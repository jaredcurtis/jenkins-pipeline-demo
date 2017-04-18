BUILDDIR := build
FILES := src/html kube/thebest-aio.yaml Dockerfile

REPLICAS ?= 1
ENV ?= dev
PROJECT ?= local

TAG := $(shell git describe --tags --always)
NAMESPACE := thebest-${TAG}-${ENV}

.PHONY: clean

build:
	mkdir -p ${BUILDDIR}
	cp -R ${FILES} ${BUILDDIR}/
	cp ${BUILDDIR}/thebest-aio.yaml ${BUILDDIR}/${NAMESPACE}.yaml
	sed -i -e "s/\%IMAGE/us.gcr.io\/${PROJECT}\/thebest:${TAG}/g" ${BUILDDIR}/${NAMESPACE}.yaml
	sed -i -e "s/\%NAMESPACE/${NAMESPACE}/g" ${BUILDDIR}/${NAMESPACE}.yaml

docker: build
	gcloud container builds submit ${BUILDDIR} --tag=us.gcr.io/${PROJECT}/thebest:${TAG} --quiet

deploy: build
	kubectl --namespace ${NAMESPACE} create -f ${BUILDDIR}/${NAMESPACE}.yaml

scale: deploy
	kubectl --namespace ${NAMESPACE} scale --replicas=${REPLICAS} rc/thebest

clean:
	rm -rf ${BUILDDIR}

purge:
	-kubectl delete namespace thebest-${TAG}-dev
	-kubectl delete namespace thebest-${TAG}-tst
	-kubectl delete namespace thebest-${TAG}-prd
