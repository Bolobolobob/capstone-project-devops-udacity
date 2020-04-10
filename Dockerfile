FROM python:3.7.3-stretch

# Working Directory
WORKDIR /app

# Copy source code to working directory
COPY . flask_app/ /app/

# Install packages from requirements.txt
# hadolint ignore=DL3013
RUN pip install --upgrade pip &&\
    pip install --trusted-host pypi.python.org -r requirements.txt &&\
    pip install git+https://github.com/gunthercox/chatterbot-corpus.git#egg=chatterbot-corpus &&\
    pip install uwsgi

# Expose port 80
EXPOSE 80

# Run app.py at container launch
CMD uwsgi --http 0.0.0.0:5000 --wsgi-file flask_app/app.py --callable app --processes 4 --threads 1