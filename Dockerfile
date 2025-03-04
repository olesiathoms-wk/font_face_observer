FROM drydock-prod.workiva.net/workiva/smithy-runner-generator:355624 as build

# Build Environment Vars
ARG BUILD_ID
ARG BUILD_NUMBER
ARG BUILD_URL
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG GIT_TAG
ARG GIT_COMMIT_RANGE
ARG GIT_HEAD_URL
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
WORKDIR /build/
ADD . /build/
ENV CODECOV_TOKEN='bQ4MgjJ0G2Y73v8JNX6L7yMK9679nbYB'
RUN echo "Starting the script sections" && \
	dart --version && \
	pub get && \
	# make a temp location to run pub publish dry run so it only looks at what is published
	# otherwise it fails with "Your package is 232.8 MB. Hosted packages must be smaller than 100 MB."
	tar czvf font_face_observer.pub.tgz LICENSE README.md pubspec.yaml analysis_options.yaml lib/ && \
	mkdir .temp && \
	tar xzvf font_face_observer.pub.tgz -C .temp && \
	cd .temp && \
	pub publish --dry-run && \
	cd .. && \
	dartanalyzer lib && \
	dartfmt -w --set-exit-if-changed lib example && \
	xvfb-run -s '-screen 0 1024x768x24' pub run test test/*_test.dart -p chrome && \
	dartdoc && \
	tar czvf api.tar.gz -C doc/api .
ARG BUILD_ARTIFACTS_DOCUMENTATION=/build/api.tar.gz
ARG BUILD_ARTIFACTS_DART-DEPENDENCIES=/build/pubspec.lock
ARG BUILD_ARTIFACTS_PUB=/build/font_face_observer.pub.tgz
FROM scratch
