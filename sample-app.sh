#!/bin/bash
set -euo pipefail

if [ ! -d "tempdir" ]; then
    mkdir tempdir
    mkdir tempdir/templates
    mkdir tempdir/static

    # Clone de repo als deze niet bestaat, anders voer een pull uit
    if [ ! -d "cicd-sample-app" ]; then
        git clone https://github.com/KevinBenoitt/cicd-sample-app.git
    else
        git -C cicd-sample-app pull origin main
    fi

    # Kopieer bestanden naar tempdir
    cp cicd-sample-app/sample_app.py tempdir/.
    cp -r cicd-sample-app/templates/* tempdir/templates/.
    cp -r cicd-sample-app/static/* tempdir/static/.

    # Docker-opbouw
    cat > tempdir/Dockerfile << _EOF_
    FROM python
    RUN pip install flask
    COPY  ./static /home/myapp/static/
    COPY  ./templates /home/myapp/templates/
    COPY  sample_app.py /home/myapp/
    EXPOSE 5050
    CMD python /home/myapp/sample_app.py
_EOF_
fi

# Navigeer naar tempdir
cd tempdir || exit

# Bouw de Docker-image en draai de container
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a
