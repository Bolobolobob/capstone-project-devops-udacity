setup:
	python3 -m venv ~/.flaskapp

install:
	pip install --upgrade pip
	pip install --trusted-host pypi.python.org -r requirements.txt
	pip install git+https://github.com/gunthercox/chatterbot-corpus.git#egg=chatterbot-corpus
	pip install uwsgi

lint:
	hadolint --ignore=DL3025 Dockerfile
	pylint3 --disable=C0114,C0103,C0116 ./flask_app/app.py
	tidy --escape-scripts no -q -e flask_app/templates/*.html

run:
	python flask_app/app.py