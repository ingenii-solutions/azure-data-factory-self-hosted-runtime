.PHONY: build push build-and-push

-include .env

ifeq ($(OS),Windows_NT)
	CURRENT_DIRECTORY = ${CURDIR}
else
	CURRENT_DIRECTORY = $(PWD)
endif

update-env-individual:
ifeq ($(OS),Windows_NT)
	@for /f "tokens=2 delims=:" %%a in ('findstr /C:"$(readme_name):" README.md') DO sed -i "s/^$(env_var_name)=.*$$/$(env_var_name)=%%a/" .env
else
	@sed -i 's/^$(env_var_name)=.*$$/$(env_var_name)=$(shell grep '* $(readme_name):' README.md | awk -F ':' '{print $$2}' | sed 's/ //g')/g' .env
endif


setup:
ifeq ($(OS),Windows_NT)
	@copy .env-dist .env
else
	@cp .env-dist .env
endif
	@make -s update-env-individual env_var_name=REGISTRY readme_name=Registry
	@make -s update-env-individual env_var_name=REPOSITORY readme_name='Repository'
	@make -s update-env-individual env_var_name=VERSION readme_name='Current Version'
ifeq ($(OS),Windows_NT)
	@sed -i 's/= /=/g' .env
	@del sed*
endif

clean-image:
ifeq ($(OS),Windows_NT)
	for /f "delims=\r" %%a in ('docker images $(REGISTRY)/$(REPOSITORY):$(VERSION) -q --no-trunc') DO docker rmi -f %%a
else
	@docker rmi -f $$(docker images --filter=reference='$(REGISTRY)/$(REPOSITORY):$(VERSION)' -q --no-trunc)
endif

clean-dangling-images:
ifeq ($(OS),Windows_NT)
	@for /f "delims=\r" %%a in ('docker images -f "dangling=true" -q') DO docker rmi -f %%a
else
	@docker rmi -f $$(docker images -f "dangling=true" -q)
endif

# Docker

build:
	docker build \
	-t $(REGISTRY)/$(REPOSITORY):$(VERSION) .

push:
	docker push $(REGISTRY)/$(REPOSITORY):$(VERSION)
	docker tag $(REGISTRY)/$(REPOSITORY):$(VERSION) $(REGISTRY)/$(REPOSITORY):latest
	docker push $(REGISTRY)/$(REPOSITORY):latest

build-and-push: build push
